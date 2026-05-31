import Combine
import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var workspaces: [Workspace]
    @Published private(set) var alerts: [PulseAlert]
    @Published var alertFilter: AlertFilter = .all
    @Published private(set) var isSyncing = false
    @Published private(set) var lastLiveSync: Date?
    @Published var syncError: String?

    let pricingTiers: [PricingTier]
    private let microsoftAuth: MicrosoftAuthService
    private var resolvedAlertKeys: Set<String> = []
    private var cancellables = Set<AnyCancellable>()

    init(microsoftAuth: MicrosoftAuthService = .shared) {
        self.microsoftAuth = microsoftAuth
        workspaces = MockDataService.workspaces
        alerts = MockDataService.alerts
        pricingTiers = MockDataService.pricingTiers

        microsoftAuth.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        if microsoftAuth.connectionState.isConnected {
            Task { await refreshDashboard() }
        }
    }

    var connectionState: ConnectionState {
        microsoftAuth.connectionState
    }

    var isDemoMode: Bool {
        !connectionState.isConnected
    }

    var isLiveData: Bool {
        connectionState.isConnected && lastLiveSync != nil
    }

    var dashboardMetrics: DashboardMetrics {
        MockDataService.dashboardMetrics(
            from: workspaces,
            alerts: alerts,
            lastSync: lastLiveSync ?? MockDataService.lastSync
        )
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
        let key = PulseAlert.stableKey(
            workspaceName: alert.workspaceName,
            modelName: alert.modelName,
            type: alert.type
        )
        resolvedAlertKeys.insert(key)
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
        syncError = nil
        await microsoftAuth.signIn()
        if connectionState.isConnected {
            await refreshDashboard()
        }
    }

    func signOutMicrosoft() {
        microsoftAuth.signOut()
        resetToDemoData()
    }

    func refreshDashboard() async {
        guard connectionState.isConnected else { return }

        isSyncing = true
        syncError = nil
        defer { isSyncing = false }

        do {
            let snapshot = try await PowerBIService.shared.fetchMonitoringSnapshot()
            workspaces = snapshot.workspaces
            alerts = applyResolvedState(to: snapshot.alerts)
            lastLiveSync = snapshot.lastSync
        } catch {
            syncError = error.localizedDescription
        }
    }

    private func applyResolvedState(to alerts: [PulseAlert]) -> [PulseAlert] {
        alerts.map { alert in
            var updated = alert
            let key = PulseAlert.stableKey(
                workspaceName: alert.workspaceName,
                modelName: alert.modelName,
                type: alert.type
            )
            updated.isResolved = resolvedAlertKeys.contains(key)
            return updated
        }
    }

    private func resetToDemoData() {
        workspaces = MockDataService.workspaces
        alerts = MockDataService.alerts
        resolvedAlertKeys.removeAll()
        lastLiveSync = nil
        syncError = nil
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
