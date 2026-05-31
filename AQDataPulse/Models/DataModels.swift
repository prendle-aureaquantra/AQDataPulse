import Foundation

struct RefreshHistoryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let status: RefreshStatus
    let duration: TimeInterval
    let errorMessage: String?

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

struct SemanticModel: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let refreshStatus: RefreshStatus
    let lastRefresh: Date?
    let refreshHistory: [RefreshHistoryEntry]
    let errorMessage: String?

    var lastRefreshFormatted: String {
        guard let lastRefresh else { return "Never" }
        return lastRefresh.formatted(date: .abbreviated, time: .shortened)
    }

    var averageDuration: TimeInterval {
        let successful = refreshHistory.filter { $0.status == .succeeded }
        guard !successful.isEmpty else { return 0 }
        return successful.map(\.duration).reduce(0, +) / Double(successful.count)
    }

    var formattedAverageDuration: String {
        let minutes = Int(averageDuration) / 60
        let seconds = Int(averageDuration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

struct Workspace: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let healthStatus: HealthStatus
    let semanticModels: [SemanticModel]
    let lastSync: Date

    var modelCount: Int { semanticModels.count }

    var failedModelCount: Int {
        semanticModels.filter { $0.refreshStatus == .failed }.count
    }

    var warningModelCount: Int {
        semanticModels.filter { $0.refreshStatus == .running || $0.refreshStatus == .never }.count
    }
}

struct PulseAlert: Identifiable, Codable, Hashable {
    let id: UUID
    let type: AlertType
    let severity: AlertSeverity
    let title: String
    let message: String
    let workspaceName: String
    let modelName: String
    let timestamp: Date
    var isResolved: Bool

    var timestampFormatted: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
}

struct PricingTier: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let period: String?
    let description: String
    let features: [String]
    let isHighlighted: Bool

    init(
        name: String,
        price: String,
        period: String? = "/month",
        description: String,
        features: [String],
        isHighlighted: Bool = false
    ) {
        self.name = name
        self.price = price
        self.period = period
        self.description = description
        self.features = features
        self.isHighlighted = isHighlighted
    }
}

struct DashboardMetrics {
    let healthScore: Int
    let failedRefreshCount: Int
    let warningCount: Int
    let workspacesMonitored: Int
    let lastSync: Date
    let healthTrend: [Int]

    var healthStatus: HealthStatus {
        if healthScore >= 85 { return .healthy }
        if healthScore >= 70 { return .warning }
        return .critical
    }
}
