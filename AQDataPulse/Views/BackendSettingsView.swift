import SwiftUI

struct BackendSettingsView: View {
    @State private var baseURL: String = DataPulseAPIConfig.baseURL.absoluteString
    @State private var apiKey: String = DataPulseAPIConfig.apiKey ?? ""
    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("datapulse_api") {
                TextField("Base URL", text: $baseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("API key (optional)", text: $apiKey)
            }

            Section {
                Button("Save") {
                    DataPulseAPIConfig.setBaseURL(baseURL)
                    DataPulseAPIConfig.setAPIKey(apiKey)
                    statusMessage = "Saved."
                }
                Button("Test entitlement") {
                    Task { await testAPI() }
                }
            }

            if let statusMessage {
                Section {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Backend")
    }

    private func testAPI() async {
        do {
            let ent = try await DataPulseAPIClient.shared.fetchEntitlement()
            statusMessage = "Connected — tier: \(ent.tier)"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
