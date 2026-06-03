import Foundation

enum ClientIdStore {
    private static let key = "com.aureaquantra.datapulse.clientId"

    static var id: String {
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let created = UUID().uuidString
        UserDefaults.standard.set(created, forKey: key)
        return created
    }
}
