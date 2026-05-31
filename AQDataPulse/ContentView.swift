import SwiftUI

private enum AppTab: Int {
    case dashboard = 0
    case workspaces = 1
    case alerts = 2
    case settings = 3
}

struct ContentView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var selectedTab: AppTab = ContentView.initialTab

    private static var initialTab: AppTab {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-ScreenshotTab"),
              index + 1 < arguments.count,
              let rawValue = Int(arguments[index + 1]),
              let tab = AppTab(rawValue: rawValue) else {
            return .dashboard
        }
        return tab
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                }
                .tag(AppTab.dashboard)

            WorkspacesView()
                .tabItem {
                    Label("Workspaces", systemImage: "folder.fill")
                }
                .tag(AppTab.workspaces)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .modifier(ActiveAlertBadge(count: viewModel.activeAlertCount))
                .tag(AppTab.alerts)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(AppTheme.brandPrimary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}

private struct ActiveAlertBadge: ViewModifier {
    let count: Int

    func body(content: Content) -> some View {
        if count > 0 {
            content.badge(count)
        } else {
            content
        }
    }
}
