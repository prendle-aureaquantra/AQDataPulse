import BackgroundTasks
import Foundation

enum BackgroundRefreshManager {
    static let taskIdentifier = "com.aureaquantra.datapulse.refresh"

    static func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(refreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Simulator or missing entitlement — ignore
        }
    }

    private static func handle(_ task: BGAppRefreshTask) {
        schedule()
        let operation = Task {
            await AppRefreshCoordinator.shared.performBackgroundRefresh()
        }
        task.expirationHandler = {
            operation.cancel()
        }
        Task {
            await operation.value
            task.setTaskCompleted(success: true)
        }
    }
}

@MainActor
final class AppRefreshCoordinator {
    static let shared = AppRefreshCoordinator()
    private var viewModel: AppViewModel?

    func bind(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }

    func performBackgroundRefresh() async {
        guard MicrosoftAuthService.shared.connectionState.isConnected else { return }
        do {
            _ = try await MicrosoftAuthService.shared.validAccessToken()
            await viewModel?.refreshDashboard()
        } catch {
            // Session may require interactive sign-in
        }
    }
}
