import Foundation

struct MonitoringSnapshot {
    let workspaces: [Workspace]
    let alerts: [PulseAlert]
    let lastSync: Date
}

enum PowerBIError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Sign in to Microsoft to load live workspace data."
        case .invalidResponse:
            return "Unexpected response from Power BI."
        case .apiError(let statusCode, let message):
            if statusCode == 401 {
                return "Power BI session expired. Sign out and sign in again."
            }
            return "Power BI error (\(statusCode)): \(message)"
        }
    }
}

actor PowerBIService {
    static let shared = PowerBIService()

    private let baseURL = URL(string: "https://api.powerbi.com/v1.0/myorg")!
    private let session: URLSession
    private let isoFormatter: ISO8601DateFormatter

    init(session: URLSession = .shared) {
        self.session = session
        self.isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    func fetchMonitoringSnapshot() async throws -> MonitoringSnapshot {
        let token = try await MainActor.run {
            try await MicrosoftAuthService.shared.validAccessToken()
        }

        let groups: [PowerBIGroup] = try await getList("/groups", token: token)
        let syncDate = Date()

        var workspaces: [Workspace] = []
        var alerts: [PulseAlert] = []

        try await withThrowingTaskGroup(of: (Workspace, [PulseAlert]).self) { group in
            for powerGroup in groups.prefix(25) {
                group.addTask {
                    try await self.loadWorkspace(powerGroup, token: token, syncDate: syncDate)
                }
            }

            for try await result in group {
                workspaces.append(result.0)
                alerts.append(contentsOf: result.1)
            }
        }

        workspaces.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        alerts.sort { $0.timestamp > $1.timestamp }

        return MonitoringSnapshot(workspaces: workspaces, alerts: alerts, lastSync: syncDate)
    }

    private func loadWorkspace(
        _ group: PowerBIGroup,
        token: String,
        syncDate: Date
    ) async throws -> (Workspace, [PulseAlert]) {
        guard let workspaceID = UUID(uuidString: group.id) else {
            throw PowerBIError.invalidResponse
        }

        let datasets: [PowerBIDataset] = try await getList("/groups/\(group.id)/datasets", token: token)
        var models: [SemanticModel] = []
        var workspaceAlerts: [PulseAlert] = []

        for dataset in datasets.prefix(20) {
            let refreshes: [PowerBIRefresh] = (
                try? await getList("/groups/\(group.id)/datasets/\(dataset.id)/refreshes", token: token)
            ) ?? []

            let model = mapDataset(dataset, refreshes: refreshes)
            models.append(model)
            workspaceAlerts.append(contentsOf: alerts(for: model, workspaceName: group.name))
        }

        let health = healthStatus(for: models)
        let workspace = Workspace(
            id: workspaceID,
            name: group.name,
            healthStatus: health,
            semanticModels: models,
            lastSync: syncDate
        )

        return (workspace, workspaceAlerts)
    }

    private func mapDataset(_ dataset: PowerBIDataset, refreshes: [PowerBIRefresh]) -> SemanticModel {
        let modelID = UUID(uuidString: dataset.id) ?? UUID()
        let sortedRefreshes = refreshes.sorted {
            parseDate($0.startTime) ?? .distantPast > parseDate($1.startTime) ?? .distantPast
        }

        let history = sortedRefreshes.prefix(7).map { refresh in
            RefreshHistoryEntry(
                id: UUID(uuidString: refresh.id ?? refresh.requestId ?? UUID().uuidString) ?? UUID(),
                timestamp: parseDate(refresh.startTime) ?? Date(),
                status: mapRefreshStatus(refresh),
                duration: refreshDuration(refresh),
                errorMessage: refreshError(refresh)
            )
        }

        let latest = sortedRefreshes.first
        let status = latest.map(mapRefreshStatus) ?? (dataset.isRefreshable == false ? .never : .never)
        let lastRefresh = latest.flatMap { parseDate($0.endTime) ?? parseDate($0.startTime) }

        return SemanticModel(
            id: modelID,
            name: dataset.name,
            refreshStatus: status,
            lastRefresh: lastRefresh,
            refreshHistory: Array(history),
            errorMessage: latest.flatMap(refreshError)
        )
    }

    private func mapRefreshStatus(_ refresh: PowerBIRefresh) -> RefreshStatus {
        switch refresh.status?.lowercased() {
        case "completed":
            return .succeeded
        case "failed", "disabled":
            return .failed
        case "unknown":
            if refresh.endTime == nil, let start = parseDate(refresh.startTime), start > Date().addingTimeInterval(-6 * 3600) {
                return .running
            }
            return .failed
        default:
            if refresh.endTime == nil, parseDate(refresh.startTime) != nil {
                return .running
            }
            return .never
        }
    }

    private func refreshDuration(_ refresh: PowerBIRefresh) -> TimeInterval {
        guard let start = parseDate(refresh.startTime) else { return 0 }
        let end = parseDate(refresh.endTime) ?? Date()
        return max(0, end.timeIntervalSince(start))
    }

    private func refreshError(_ refresh: PowerBIRefresh) -> String? {
        guard let json = refresh.serviceExceptionJson, !json.isEmpty else { return nil }
        if let data = json.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = object["errorDescription"] as? String { return message }
            if let message = object["message"] as? String { return message }
        }
        return json
    }

    private func healthStatus(for models: [SemanticModel]) -> HealthStatus {
        if models.contains(where: { $0.refreshStatus == .failed }) { return .critical }
        if models.contains(where: { $0.refreshStatus == .running || $0.refreshStatus == .never }) {
            return .warning
        }
        if models.contains(where: { model in
            guard let last = model.lastRefresh else { return true }
            return last < Date().addingTimeInterval(-24 * 3600)
        }) {
            return .warning
        }
        return .healthy
    }

    private func alerts(for model: SemanticModel, workspaceName: String) -> [PulseAlert] {
        var results: [PulseAlert] = []

        if model.refreshStatus == .failed {
            results.append(makeAlert(
                type: .failedRefresh,
                severity: .critical,
                title: "Refresh Failed",
                message: model.errorMessage ?? "\(model.name) refresh failed.",
                workspaceName: workspaceName,
                modelName: model.name,
                timestamp: model.lastRefresh ?? Date()
            ))
        }

        if model.refreshStatus == .running,
           let start = model.refreshHistory.first?.timestamp,
           start < Date().addingTimeInterval(-30 * 60) {
            results.append(makeAlert(
                type: .longRunningRefresh,
                severity: .warning,
                title: "Long Running Refresh",
                message: "\(model.name) has been running for over 30 minutes.",
                workspaceName: workspaceName,
                modelName: model.name,
                timestamp: start
            ))
        }

        if model.refreshStatus == .never {
            results.append(makeAlert(
                type: .noRefreshIn24Hours,
                severity: .info,
                title: "No Refresh Scheduled",
                message: "\(model.name) has no refresh history yet.",
                workspaceName: workspaceName,
                modelName: model.name,
                timestamp: Date()
            ))
        } else if let last = model.lastRefresh, last < Date().addingTimeInterval(-24 * 3600) {
            results.append(makeAlert(
                type: .noRefreshIn24Hours,
                severity: .warning,
                title: "Stale Refresh",
                message: "\(model.name) has not refreshed in over 24 hours.",
                workspaceName: workspaceName,
                modelName: model.name,
                timestamp: last
            ))
        }

        return results
    }

    private func makeAlert(
        type: AlertType,
        severity: AlertSeverity,
        title: String,
        message: String,
        workspaceName: String,
        modelName: String,
        timestamp: Date
    ) -> PulseAlert {
        let key = PulseAlert.stableKey(workspaceName: workspaceName, modelName: modelName, type: type)
        return PulseAlert(
            id: UUID(stableKey: key),
            type: type,
            severity: severity,
            title: title,
            message: message,
            workspaceName: workspaceName,
            modelName: modelName,
            timestamp: timestamp,
            isResolved: false
        )
    }

    private func getList<T: Decodable>(_ path: String, token: String) async throws -> [T] {
        let url = apiURL(for: path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw PowerBIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Request failed."
            throw PowerBIError.apiError(statusCode: http.statusCode, message: message)
        }

        let envelope = try JSONDecoder().decode(PowerBIListResponse<T>.self, from: data)
        return envelope.value
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = isoFormatter.date(from: value) { return date }
        isoFormatter.formatOptions = [.withInternetDateTime]
        defer { isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] }
        return isoFormatter.date(from: value)
    }

    private func apiURL(for path: String) -> URL {
        let components = path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .split(separator: "/")
            .map(String.init)

        return components.reduce(baseURL) { url, component in
            url.appendingPathComponent(component)
        }
    }
}

private struct PowerBIListResponse<T: Decodable>: Decodable {
    let value: [T]
}

private struct PowerBIGroup: Decodable {
    let id: String
    let name: String
}

private struct PowerBIDataset: Decodable {
    let id: String
    let name: String
    let isRefreshable: Bool?
}

private struct PowerBIRefresh: Decodable {
    let requestId: String?
    let id: String?
    let startTime: String?
    let endTime: String?
    let status: String?
    let serviceExceptionJson: String?
}

extension PulseAlert {
    static func stableKey(workspaceName: String, modelName: String, type: AlertType) -> String {
        "\(workspaceName)|\(modelName)|\(type.rawValue)"
    }
}

extension UUID {
    init(stableKey: String) {
        var bytes = [UInt8](repeating: 0, count: 16)
        for (index, byte) in stableKey.utf8.enumerated() {
            bytes[index % 16] = bytes[index % 16] &+ byte
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        self.init(uuid: uuid_t(
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
