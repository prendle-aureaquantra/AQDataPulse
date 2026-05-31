import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DemoBanner(isDemoMode: viewModel.isDemoMode)

                    healthOverviewCard

                    metricsGrid

                    trendCard

                    recentAlertsSection

                    BetaSignupButton()
                }
                .padding()
            }
            .background(AppTheme.screenBackground)
            .refreshable {
                await viewModel.refreshDashboard()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var healthOverviewCard: some View {
        let metrics = viewModel.dashboardMetrics

        return VStack(spacing: 16) {
            HStack(spacing: 20) {
                HealthScoreRing(score: metrics.healthScore, status: metrics.healthStatus)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Overall Health")
                        .font(.title3.weight(.semibold))

                    StatusBadge(text: metrics.healthStatus.label, color: metrics.healthStatus.color)

                    Text("Last sync \(metrics.lastSync.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var metricsGrid: some View {
        let metrics = viewModel.dashboardMetrics

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(
                title: "Failed Refreshes",
                value: "\(metrics.failedRefreshCount)",
                icon: "xmark.circle.fill",
                accent: .red
            )
            MetricCard(
                title: "Warnings",
                value: "\(metrics.warningCount)",
                icon: "exclamationmark.triangle.fill",
                accent: .orange
            )
            MetricCard(
                title: "Workspaces",
                value: "\(metrics.workspacesMonitored)",
                icon: "folder.fill",
                accent: AppTheme.brandPrimary
            )
            MetricCard(
                title: "Active Alerts",
                value: "\(viewModel.activeAlertCount)",
                icon: "bell.badge.fill",
                accent: AppTheme.brandSecondary
            )
        }
    }

    private var trendCard: some View {
        let metrics = viewModel.dashboardMetrics

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "7-Day Health Trend")

            SimpleLineChart(values: metrics.healthTrend, color: metrics.healthStatus.color)

            HStack {
                Text("7 days ago")
                Spacer()
                Text("Today")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var recentAlertsSection: some View {
        let recent = viewModel.alerts.filter { !$0.isResolved }.prefix(3)

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Alerts")

            if recent.isEmpty {
                Text("No active alerts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(recent)) { alert in
                    AlertRowView(alert: alert, showResolve: false)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppViewModel())
}
