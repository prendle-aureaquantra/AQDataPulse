import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var showPrivacy = false

    var body: some View {
        NavigationStack {
            List {
                Section("Environment") {
                    HStack {
                        Label("Demo Mode", systemImage: viewModel.isDemoMode ? "play.circle.fill" : "link.circle.fill")
                        Spacer()
                        Text(viewModel.isDemoMode ? "Enabled" : "Disabled")
                            .foregroundStyle(viewModel.isDemoMode ? .orange : .green)
                            .fontWeight(.medium)
                    }
                }

                Section("Data Pulse API") {
                    NavigationLink {
                        BackendSettingsView()
                    } label: {
                        Label("Backend URL", systemImage: "server.rack")
                    }
                }

                Section("Connect") {
                    NavigationLink {
                        ConnectMicrosoftView()
                    } label: {
                        HStack {
                            Label("Connect Microsoft", systemImage: "link")
                            Spacer()
                            connectionBadge
                        }
                    }
                }

                Section("Product") {
                    NavigationLink {
                        PricingView()
                    } label: {
                        Label("Pricing", systemImage: "dollarsign.circle")
                    }
                }

                Section("Support") {
                    Link(destination: URL(string: "mailto:therendle@gmail.com?subject=AQ%20Data%20Pulse%20Support")!) {
                        Label("Support Email", systemImage: "envelope")
                    }

                    BetaSignupButton()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aurea Quantra")
                            .font(.headline)
                        Text("AQ Data Pulse helps data professionals monitor analytics environments and quickly identify operational issues before users are impacted.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    Button {
                        showPrivacy = true
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppInfo.versionLabel)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
        }
    }

    @ViewBuilder
    private var connectionBadge: some View {
        switch viewModel.connectionState {
        case .connected:
            StatusBadge(text: "Connected", color: .green)
        case .connecting:
            StatusBadge(text: "Connecting", color: .orange)
        case .error:
            StatusBadge(text: "Error", color: .red)
        case .disconnected:
            StatusBadge(text: "Not Connected", color: .secondary)
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title2.weight(.bold))

                    Group {
                        policySection(
                            title: "Overview",
                            body: "AQ Data Pulse monitors Microsoft Fabric and Power BI refresh health. In demo mode, sample data stays on your device. Optional Microsoft sign-in loads live workspace data using Microsoft APIs."
                        )
                        policySection(
                            title: "Microsoft Sign-In",
                            body: "If you connect Microsoft, OAuth tokens are stored in your device Keychain. The app reads workspace and refresh metadata from Power BI. We do not operate a separate backend for your Fabric data."
                        )
                        policySection(
                            title: "Data Collection",
                            body: "We do not use advertising or analytics SDKs. Beta and support requests open your Mail app and are not processed inside the app."
                        )
                        policySection(
                            title: "Demo Mode",
                            body: "When signed out, all workspace, model, and alert data is sample data for demonstration only."
                        )
                        policySection(
                            title: "Contact",
                            body: "Privacy questions: therendle@gmail.com. Full policy: see App Store listing or aureaquantra.com."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
