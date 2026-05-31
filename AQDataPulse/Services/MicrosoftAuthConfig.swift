import Foundation

enum MicrosoftAuthConfig {
    static let redirectScheme = "aqdatapulse"
    static let redirectPath = "auth"
    static let redirectURI = "\(redirectScheme)://\(redirectPath)"
    static let tenant = "common"
    static let authorityHost = "login.microsoftonline.com"

    static let scopes = [
        "openid",
        "profile",
        "offline_access",
        "https://analysis.windows.net/powerbi/api/.default"
    ]

    static var clientID: String {
        Bundle.main.object(forInfoDictionaryKey: "MicrosoftClientID") as? String ?? ""
    }

    static var isConfigured: Bool {
        !clientID.isEmpty && clientID != "YOUR_AZURE_CLIENT_ID"
    }

    static var authorizationURL: URL? {
        guard isConfigured else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        components.host = authorityHost
        components.path = "/\(tenant)/oauth2/v2.0/authorize"
        return components.url
    }

    static func tokenURL(for tenantHint: String? = nil) -> URL? {
        let resolvedTenant = tenantHint ?? tenant
        return URL(string: "https://\(authorityHost)/\(resolvedTenant)/oauth2/v2.0/token")
    }
}
