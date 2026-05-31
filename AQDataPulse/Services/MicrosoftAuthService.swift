import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

@MainActor
final class MicrosoftAuthService: NSObject, ObservableObject {
    static let shared = MicrosoftAuthService()

    @Published private(set) var connectionState: ConnectionState = .disconnected

    private var authSession: ASWebAuthenticationSession?
    private var codeVerifier: String?

    private override init() {
        super.init()
        restoreSession()
    }

    func signIn() async {
        guard MicrosoftAuthConfig.isConfigured else {
            connectionState = .error(
                "Add your Azure app client ID to Info.plist (MicrosoftClientID) before signing in."
            )
            return
        }

        connectionState = .connecting

        let verifier = Self.randomURLSafeString(length: 64)
        codeVerifier = verifier
        let challenge = Self.codeChallenge(for: verifier)

        guard var components = URLComponents(url: MicrosoftAuthConfig.authorizationURL!, resolvingAgainstBaseURL: false) else {
            connectionState = .error("Unable to build sign-in URL.")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: MicrosoftAuthConfig.clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: MicrosoftAuthConfig.redirectURI),
            URLQueryItem(name: "response_mode", value: "query"),
            URLQueryItem(name: "scope", value: MicrosoftAuthConfig.scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "prompt", value: "select_account")
        ]

        guard let authURL = components.url else {
            connectionState = .error("Unable to build sign-in URL.")
            return
        }

        do {
            let callbackURL = try await startWebAuthenticationSession(url: authURL)
            try await handleCallback(callbackURL)
        } catch MicrosoftAuthError.userCancelled {
            connectionState = .disconnected
        } catch {
            connectionState = .error(error.localizedDescription)
        }
    }

    func signOut() {
        authSession?.cancel()
        authSession = nil
        codeVerifier = nil
        KeychainStore.clearAuth()
        connectionState = .disconnected
    }

    private func restoreSession() {
        guard let name = KeychainStore.read(account: KeychainStore.Accounts.displayName),
              let email = KeychainStore.read(account: KeychainStore.Accounts.email),
              KeychainStore.read(account: KeychainStore.Accounts.accessToken) != nil else {
            connectionState = .disconnected
            return
        }
        connectionState = .connected(displayName: name, email: email)
    }

    private func startWebAuthenticationSession(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            authSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: MicrosoftAuthConfig.redirectScheme
            ) { callbackURL, error in
                if let error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: MicrosoftAuthError.userCancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }

                guard let callbackURL else {
                    continuation.resume(throwing: MicrosoftAuthError.missingCallback)
                    return
                }

                continuation.resume(returning: callbackURL)
            }

            authSession?.presentationContextProvider = self
            authSession?.prefersEphemeralWebBrowserSession = false
            authSession?.start()
        }
    }

    private func handleCallback(_ url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw MicrosoftAuthError.invalidCallback
        }

        if let errorDescription = components.queryItems?.first(where: { $0.name == "error_description" })?.value {
            throw MicrosoftAuthError.server(errorDescription.replacingOccurrences(of: "+", with: " "))
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw MicrosoftAuthError.missingAuthorizationCode
        }

        guard let verifier = codeVerifier else {
            throw MicrosoftAuthError.missingCodeVerifier
        }

        try await exchangeCodeForTokens(code: code, verifier: verifier)
    }

    private func exchangeCodeForTokens(code: String, verifier: String) async throws {
        guard let tokenURL = MicrosoftAuthConfig.tokenURL() else {
            throw MicrosoftAuthError.invalidTokenURL
        }

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyItems = [
            URLQueryItem(name: "client_id", value: MicrosoftAuthConfig.clientID),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: MicrosoftAuthConfig.redirectURI),
            URLQueryItem(name: "code_verifier", value: verifier),
            URLQueryItem(name: "scope", value: MicrosoftAuthConfig.scopes.joined(separator: " "))
        ]

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = bodyItems
        request.httpBody = bodyComponents.percentEncodedQuery?.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Token exchange failed."
            throw MicrosoftAuthError.server(message)
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        try KeychainStore.save(tokenResponse.accessToken, account: KeychainStore.Accounts.accessToken)
        if let refreshToken = tokenResponse.refreshToken {
            try KeychainStore.save(refreshToken, account: KeychainStore.Accounts.refreshToken)
        }

        let profile = profileFromIDToken(tokenResponse.idToken) ?? UserProfile(
            displayName: "Microsoft Account",
            email: "Signed in"
        )
        try KeychainStore.save(profile.displayName, account: KeychainStore.Accounts.displayName)
        try KeychainStore.save(profile.email, account: KeychainStore.Accounts.email)

        connectionState = .connected(displayName: profile.displayName, email: profile.email)
        codeVerifier = nil
    }

    private func profileFromIDToken(_ idToken: String?) -> UserProfile? {
        guard let claims = Self.decodeJWTPayload(idToken) else { return nil }

        let email = (claims["email"] as? String)
            ?? (claims["preferred_username"] as? String)
            ?? (claims["upn"] as? String)

        let displayName = (claims["name"] as? String) ?? email

        guard displayName != nil || email != nil else { return nil }

        return UserProfile(
            displayName: displayName ?? email ?? "Microsoft Account",
            email: email ?? displayName ?? "Signed in"
        )
    }

    private static func decodeJWTPayload(_ jwt: String?) -> [String: Any]? {
        guard let jwt else { return nil }
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }

        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64.append("=")
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }

    private static func randomURLSafeString(length: Int) -> String {
        let bytes = (0..<length).map { _ in UInt8.random(in: 0...255) }
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .prefix(length)
            .description
    }

    private static func codeChallenge(for verifier: String) -> String {
        let hash = SHA256.hash(data: Data(verifier.utf8))
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension MicrosoftAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first?.keyWindow ?? ASPresentationAnchor()
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
}

private struct UserProfile {
    let displayName: String
    let email: String
}

enum MicrosoftAuthError: LocalizedError {
    case userCancelled
    case missingCallback
    case invalidCallback
    case missingAuthorizationCode
    case missingCodeVerifier
    case invalidTokenURL
    case server(String)

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Sign-in was cancelled."
        case .missingCallback:
            return "Microsoft sign-in did not return a callback URL."
        case .invalidCallback:
            return "Microsoft sign-in callback was invalid."
        case .missingAuthorizationCode:
            return "Microsoft sign-in did not return an authorization code."
        case .missingCodeVerifier:
            return "Sign-in state expired. Please try again."
        case .invalidTokenURL:
            return "Unable to build token URL."
        case .server(let message):
            return message
        }
    }
}
