import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationService: NSObject, ObservableObject {
    static let shared = PushNotificationService()

    @Published private(set) var deviceTokenHex: String?
    @Published private(set) var registrationError: String?

    private override init() {
        super.init()
    }

    func requestAuthorizationAndRegister() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else {
                registrationError = "Notification permission denied."
                return
            }
            registrationError = nil
            await UIApplication.shared.registerForRemoteNotifications()
        } catch {
            registrationError = error.localizedDescription
        }
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) async {
        let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
        deviceTokenHex = hex
        registrationError = nil

        let email: String?
        if case .connected(_, let mail) = MicrosoftAuthService.shared.connectionState {
            email = mail
        } else {
            email = nil
        }

        do {
            try await DataPulseAPIClient.shared.registerDevice(
                platform: "ios",
                pushToken: hex,
                email: email
            )
        } catch {
            registrationError = error.localizedDescription
        }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        registrationError = error.localizedDescription
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
