import SwiftUI

struct WorkspacesView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DemoBanner(isDemoMode: viewModel.isDemoMode)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                ForEach(viewModel.workspaces) { workspace in
                    NavigationLink(value: workspace) {
                        WorkspaceRowView(workspace: workspace)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Workspaces")
            .navigationDestination(for: Workspace.self) { workspace in
                WorkspaceDetailView(workspace: workspace)
            }
            .navigationDestination(for: ModelRoute.self) { route in
                ModelDetailView(workspaceId: route.workspaceId, modelId: route.modelId)
            }
        }
    }
}

struct WorkspaceRowView: View {
    let workspace: Workspace

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.brandPrimary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(workspace.name)
                    .font(.headline)

                Text("\(workspace.modelCount) semantic models")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(text: workspace.healthStatus.label, color: workspace.healthStatus.color)
        }
        .padding(.vertical, 4)
    }
}

struct WorkspaceDetailView: View {
    let workspace: Workspace

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Health Status")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        StatusBadge(text: workspace.healthStatus.label, color: workspace.healthStatus.color)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Last Sync")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(workspace.lastSync.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline.weight(.medium))
                    }
                }
            }

            Section("Semantic Models") {
                ForEach(workspace.semanticModels) { model in
                    NavigationLink(value: ModelRoute(workspaceId: workspace.id, modelId: model.id)) {
                        ModelRowView(model: model)
                    }
                }
            }
        }
        .navigationTitle(workspace.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ModelRowView: View {
    let model: SemanticModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: model.refreshStatus.icon)
                .foregroundStyle(model.refreshStatus.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)

                Text("Last refresh: \(model.lastRefreshFormatted)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(text: model.refreshStatus.label, color: model.refreshStatus.color)
        }
        .padding(.vertical, 2)
    }
}

struct ModelRoute: Hashable {
    let workspaceId: UUID
    let modelId: UUID
}

#Preview {
    WorkspacesView()
        .environmentObject(AppViewModel())
}
