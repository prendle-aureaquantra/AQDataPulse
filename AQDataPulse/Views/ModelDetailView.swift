import SwiftUI

struct ModelDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let workspaceId: UUID
    let modelId: UUID

    @State private var copied = false

    private var model: SemanticModel? {
        viewModel.model(workspaceId: workspaceId, modelId: modelId)
    }

    var body: some View {
        Group {
            if let model {
                content(for: model)
            } else {
                ContentUnavailableView("Model Not Found", systemImage: "cube.transparent")
            }
        }
        .navigationTitle(model?.name ?? "Model")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func content(for model: SemanticModel) -> some View {
        List {
            statusSection(model)
            if let error = model.errorMessage {
                errorSection(error)
            }
            historySection(model)
        }
    }

    private func statusSection(_ model: SemanticModel) -> some View {
        Section("Refresh Status") {
            LabeledContent("Status") {
                StatusBadge(text: model.refreshStatus.label, color: model.refreshStatus.color)
            }
            LabeledContent("Last Refresh") {
                Text(model.lastRefreshFormatted)
            }
            LabeledContent("Avg Duration") {
                Text(model.formattedAverageDuration)
            }
        }
    }

    private func errorSection(_ error: String) -> some View {
        Section("Error Message") {
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.red)
                .textSelection(.enabled)

            Button {
                UIPasteboard.general.string = error
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copied = false
                }
            } label: {
                Label(copied ? "Copied!" : "Copy Error", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(copied ? .green : AppTheme.brandPrimary)
        }
    }

    private func historySection(_ model: SemanticModel) -> some View {
        Section("Refresh History") {
            if model.refreshHistory.isEmpty {
                Text("No refresh history available")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.refreshHistory) { entry in
                    HStack {
                        Image(systemName: entry.status.icon)
                            .foregroundStyle(entry.status.color)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline.weight(.medium))
                            Text(entry.formattedDuration)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        StatusBadge(text: entry.status.label, color: entry.status.color)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModelDetailView(
            workspaceId: MockDataService.workspaces[1].id,
            modelId: MockDataService.workspaces[1].semanticModels[0].id
        )
    }
    .environmentObject(AppViewModel())
}
