import SwiftUI

@main
struct AQDataPulseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var microsoftAuth = MicrosoftAuthService.shared
    @StateObject private var pushService = PushNotificationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(microsoftAuth)
                .environmentObject(pushService)
                .onAppear {
                    AppRefreshCoordinator.shared.bind(viewModel: viewModel)
                    BackgroundRefreshManager.schedule()
                }
        }
    }
}
