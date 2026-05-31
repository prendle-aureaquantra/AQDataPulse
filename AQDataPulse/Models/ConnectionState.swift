import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected(displayName: String, email: String)
    case error(String)

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var statusLabel: String {
        switch self {
        case .disconnected:
            return "Not Connected"
        case .connecting:
            return "Connecting…"
        case .connected(let name, _):
            return name
        case .error:
            return "Connection Error"
        }
    }
}
