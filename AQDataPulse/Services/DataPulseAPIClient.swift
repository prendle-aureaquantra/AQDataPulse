import Foundation

enum DataPulseAPIError: LocalizedError {
    case badStatus(Int, String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .badStatus(let code, let msg): return "API \(code): \(msg)"
        case .invalidURL: return "Invalid API URL"
        }
    }
}

struct EntitlementResponse: Decodable {
    let tier: String
    let alertChecksUsed: Int
    let alertChecksRemaining: Int?

    enum CodingKeys: String, CodingKey {
        case tier
        case alertChecksUsed = "alert_checks_used"
        case alertChecksRemaining = "alert_checks_remaining"
    }
}

final class DataPulseAPIClient {
    static let shared = DataPulseAPIClient()

    private func headers(json: Bool = true) -> [String: String] {
        var h = ["X-DataPulse-Client-Id": ClientIdStore.id]
        if json { h["Content-Type"] = "application/json" }
        if let key = DataPulseAPIConfig.apiKey { h["X-API-Key"] = key }
        return h
    }

    private func request(path: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: trimmed, relativeTo: DataPulseAPIConfig.baseURL) else {
            throw DataPulseAPIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        headers().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = body
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw DataPulseAPIError.badStatus(-1, "No response")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw DataPulseAPIError.badStatus(
                http.statusCode,
                String(data: data, encoding: .utf8) ?? ""
            )
        }
        return data
    }

    func registerDevice(platform: String, pushToken: String, email: String?) async throws {
        var payload: [String: Any] = [
            "platform": platform,
            "push_token": pushToken
        ]
        if let email { payload["email"] = email }
        let body = try JSONSerialization.data(withJSONObject: payload)
        _ = try await request(path: "api/v1/devices/register", method: "POST", body: body)
    }

    func reportAlert(
        workspaceId: String,
        workspaceName: String,
        datasetId: String,
        datasetName: String,
        alertType: String,
        severity: String = "critical"
    ) async throws {
        let payload: [String: Any] = [
            "workspace_id": workspaceId,
            "workspace_name": workspaceName,
            "dataset_id": datasetId,
            "dataset_name": datasetName,
            "alert_type": alertType,
            "severity": severity
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        _ = try await request(path: "api/v1/alerts/webhook", method: "POST", body: body)
    }

    func fetchEntitlement() async throws -> EntitlementResponse {
        let data = try await request(path: "api/v1/billing/entitlement")
        return try JSONDecoder().decode(EntitlementResponse.self, from: data)
    }
}
