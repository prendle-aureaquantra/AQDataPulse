import SwiftUI

struct ConnectMicrosoftView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Microsoft Fabric & Power BI", systemImage: "chart.bar.doc.horizontal.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.brandPrimary)

                    Text("Connect your Microsoft account to monitor workspace refresh health with live data in a future release.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Status") {
                switch viewModel.connectionState {
                case .disconnected:
                    statusRow(title: "Not connected", detail: "Demo data is shown throughout the app.", color: .secondary)
                case .connecting:
                    HStack {
                        ProgressView()
                        Text("Opening Microsoft sign-in…")
                    }
                case .connected(let name, let email):
                    statusRow(title: name, detail: email, color: .green)
                case .error(let message):
                    statusRow(title: "Sign-in failed", detail: message, color: .red)
                }
            }

            Section {
                if viewModel.connectionState.isConnected {
                    Button(role: .destructive) {
                        viewModel.signOutMicrosoft()
                    } label: {
                        Label("Disconnect", systemImage: "link.badge.minus")
                    }
                } else {
                    Button {
                        Task { await viewModel.signInMicrosoft() }
                    } label: {
                        Label("Sign in with Microsoft", systemImage: "person.crop.circle.badge.checkmark")
                    }
                    .disabled(viewModel.connectionState == .connecting)
                }
            }

            if !MicrosoftAuthConfig.isConfigured {
                Section("Developer Setup") {
                    Text("Register an app in Azure Portal, add the mobile redirect URI `aqdatapulse://auth`, then set `MicrosoftClientID` in Info.plist.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Link(destination: URL(string: "https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app")!) {
                        Label("Azure app registration guide", systemImage: "safari")
                    }
                }
            }

            Section("Version 2 Preview") {
                Label("Live workspace sync", systemImage: "arrow.triangle.2.circlepath")
                Label("Failed refresh alerts", systemImage: "bell.badge")
                Label("Push notifications", systemImage: "iphone.and.arrow.forward")
            }
            .foregroundStyle(.secondary)
        }
        .navigationTitle("Connect Microsoft")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusRow(title: String, detail: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        ConnectMicrosoftView()
            .environmentObject(AppViewModel())
    }
}
