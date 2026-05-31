import Combine
import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var workspaces: [Workspace]
    @Published private(set) var alerts: [PulseAlert]
    @Published var alertFilter: AlertFilter = .all

    let pricingTiers: [PricingTier]
    private let microsoftAuth: MicrosoftAuthService
    private var cancellables = Set<AnyCancellable>()

    init(microsoftAuth: MicrosoftAuthService = .shared) {
        self.microsoftAuth = microsoftAuth
        workspaces = MockDataService.workspaces
        alerts = MockDataService.alerts
        pricingTiers = MockDataService.pricingTiers

        microsoftAuth.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var connectionState: ConnectionState {
        microsoftAuth.connectionState
    }

    var isDemoMode: Bool {
        !connectionState.isConnected
    }

    var dashboardMetrics: DashboardMetrics {
        MockDataService.dashboardMetrics(from: workspaces, alerts: alerts)
    }

    var filteredAlerts: [PulseAlert] {
        switch alertFilter {
        case .all:
            return alerts
        case .active:
            return alerts.filter { !$0.isResolved }
        case .resolved:
            return alerts.filter { $0.isResolved }
        case .critical:
            return alerts.filter { !$0.isResolved && $0.severity == .critical }
        case .warning:
            return alerts.filter { !$0.isResolved && $0.severity == .warning }
        }
    }

    var activeAlertCount: Int {
        alerts.filter { !$0.isResolved }.count
    }

    func resolveAlert(_ alert: PulseAlert) {
        guard let index = alerts.firstIndex(where: { $0.id == alert.id }) else { return }
        alerts[index].isResolved = true
    }

    func workspace(for id: UUID) -> Workspace? {
        workspaces.first { $0.id == id }
    }

    func model(workspaceId: UUID, modelId: UUID) -> SemanticModel? {
        workspace(for: workspaceId)?.semanticModels.first { $0.id == modelId }
    }

    func signInMicrosoft() async {
        await microsoftAuth.signIn()
    }

    func signOutMicrosoft() {
        microsoftAuth.signOut()
    }

    func refreshDashboard() async {
        try? await Task.sleep(for: .milliseconds(600))
    }
}

enum AlertFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case resolved = "Resolved"
    case critical = "Critical"
    case warning = "Warning"

    var id: String { rawValue }
}
