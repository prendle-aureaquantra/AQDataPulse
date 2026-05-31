import SwiftUI

@main
struct AQDataPulseApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var microsoftAuth = MicrosoftAuthService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(microsoftAuth)
        }
    }
}
