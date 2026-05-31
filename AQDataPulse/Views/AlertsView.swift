import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DemoBanner(
                    isDemoMode: viewModel.isDemoMode,
                    isLiveData: viewModel.isLiveData,
                    isSyncing: viewModel.isSyncing
                )
                    .padding(.horizontal)
                    .padding(.top, 8)

                filterBar

                if viewModel.filteredAlerts.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.filteredAlerts) { alert in
                            AlertRowView(alert: alert, showResolve: true) {
                                withAnimation {
                                    viewModel.resolveAlert(alert)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Alerts")
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AlertFilter.allCases) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.alertFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.alertFilter == filter ? AppTheme.brandPrimary : AppTheme.cardBackground)
                            .foregroundStyle(viewModel.alertFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(AppTheme.screenBackground)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("No alerts match this filter")
                .font(.headline)
            Text("Try selecting a different filter to view alerts.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.screenBackground)
    }
}

struct AlertRowView: View {
    let alert: PulseAlert
    var showResolve: Bool
    var onResolve: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: alert.type.icon)
                    .foregroundStyle(alert.type.color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(alert.title)
                            .font(.headline)
                            .strikethrough(alert.isResolved, color: .secondary)

                        if alert.isResolved {
                            StatusBadge(text: "Resolved", color: .green)
                        }
                    }

                    Text(alert.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                Label(alert.workspaceName, systemImage: "folder")
                Text("·")
                Label(alert.modelName, systemImage: "cube")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)

            HStack {
                StatusBadge(text: alert.type.rawValue, color: alert.type.color)
                StatusBadge(text: alert.severity.label, color: alert.severity.color)
                Spacer()
                Text(alert.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if showResolve && !alert.isResolved, let onResolve {
                Button(action: onResolve) {
                    Label("Resolve", systemImage: "checkmark.circle")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .opacity(alert.isResolved ? 0.7 : 1)
    }
}

#Preview {
    AlertsView()
        .environmentObject(AppViewModel())
}
