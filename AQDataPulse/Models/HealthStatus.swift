import SwiftUI

enum HealthStatus: String, CaseIterable, Codable {
    case healthy
    case warning
    case critical

    var label: String {
        switch self {
        case .healthy: return "Healthy"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .healthy: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }

    var icon: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}

enum RefreshStatus: String, Codable {
    case succeeded
    case failed
    case running
    case never

    var label: String {
        switch self {
        case .succeeded: return "Succeeded"
        case .failed: return "Failed"
        case .running: return "Running"
        case .never: return "Never Refreshed"
        }
    }

    var color: Color {
        switch self {
        case .succeeded: return .green
        case .failed: return .red
        case .running: return .blue
        case .never: return .gray
        }
    }

    var icon: String {
        switch self {
        case .succeeded: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .running: return "arrow.triangle.2.circlepath"
        case .never: return "minus.circle.fill"
        }
    }
}

enum AlertType: String, CaseIterable, Codable {
    case failedRefresh = "Failed Refresh"
    case longRunningRefresh = "Long Running Refresh"
    case noRefreshIn24Hours = "No Refresh in 24 Hours"

    var icon: String {
        switch self {
        case .failedRefresh: return "xmark.circle.fill"
        case .longRunningRefresh: return "clock.badge.exclamationmark.fill"
        case .noRefreshIn24Hours: return "calendar.badge.exclamationmark"
        }
    }

    var color: Color {
        switch self {
        case .failedRefresh: return .red
        case .longRunningRefresh: return .orange
        case .noRefreshIn24Hours: return .yellow
        }
    }
}

enum AlertSeverity: String, Codable {
    case critical
    case warning
    case info

    var label: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
