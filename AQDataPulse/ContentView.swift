import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                }

            WorkspacesView()
                .tabItem {
                    Label("Workspaces", systemImage: "folder.fill")
                }

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .modifier(ActiveAlertBadge(count: viewModel.activeAlertCount))

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
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
