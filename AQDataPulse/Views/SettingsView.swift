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
                            body: "AQ Data Pulse Version 1 operates entirely on your device using demonstration data. No personal data is collected, stored, or transmitted."
                        )
                        policySection(
                            title: "Data Collection",
                            body: "This app does not collect analytics, usage data, or personal information. Beta signup requests are handled through your device's email client and are not processed by the app."
                        )
                        policySection(
                            title: "Demo Mode",
                            body: "All workspace, model, and alert data displayed in Version 1 is sample data for demonstration purposes only."
                        )
                        policySection(
                            title: "Future Versions",
                            body: "When Microsoft Fabric integration is added, this policy will be updated to describe authentication, data handling, and retention practices."
                        )
                        policySection(
                            title: "Contact",
                            body: "For privacy questions, contact therendle@gmail.com."
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
