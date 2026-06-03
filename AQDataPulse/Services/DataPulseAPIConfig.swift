import Foundation

enum DataPulseAPIConfig {
    private static let baseURLKey = "DataPulseAPIBaseURL"
    private static let apiKeyKey = "DataPulseAPIKey"

    static var baseURL: URL {
        let raw = UserDefaults.standard.string(forKey: baseURLKey)
            ?? Bundle.main.object(forInfoDictionaryKey: "DataPulseAPIBaseURL") as? String
            ?? "http://127.0.0.1:8020"
        return URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines))!
    }

    static var apiKey: String? {
        let stored = UserDefaults.standard.string(forKey: apiKeyKey)
        if let stored, !stored.isEmpty { return stored }
        return Bundle.main.object(forInfoDictionaryKey: "DataPulseAPIKey") as? String
    }

    static func setBaseURL(_ value: String) {
        UserDefaults.standard.set(value, forKey: baseURLKey)
    }

    static func setAPIKey(_ value: String) {
        UserDefaults.standard.set(value, forKey: apiKeyKey)
    }
}
