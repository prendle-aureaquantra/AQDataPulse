import Foundation

enum MockDataService {
    static let lastSync = Date().addingTimeInterval(-12 * 60)

    static let workspaces: [Workspace] = [
        Workspace(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000001")!,
            name: "Executive Sales",
            healthStatus: .healthy,
            semanticModels: [
                makeModel(
                    name: "Sales Performance",
                    status: .succeeded,
                    lastRefresh: hoursAgo(2),
                    history: successHistory(baseMinutes: 8)
                ),
                makeModel(
                    name: "Pipeline Analytics",
                    status: .succeeded,
                    lastRefresh: hoursAgo(3),
                    history: successHistory(baseMinutes: 12)
                ),
                makeModel(
                    name: "Regional Targets",
                    status: .succeeded,
                    lastRefresh: hoursAgo(4),
                    history: successHistory(baseMinutes: 6)
                )
            ],
            lastSync: lastSync
        ),
        Workspace(
            id: UUID(uuidString: "A1000002-0000-0000-0000-000000000002")!,
            name: "Finance Reporting",
            healthStatus: .critical,
            semanticModels: [
                makeModel(
                    name: "General Ledger",
                    status: .failed,
                    lastRefresh: hoursAgo(6),
                    history: failedHistory(
                        error: "Connection timeout: Unable to reach SQL endpoint 'finance-prod.database.windows.net' after 30 seconds."
                    )
                ),
                makeModel(
                    name: "Budget vs Actual",
                    status: .succeeded,
                    lastRefresh: hoursAgo(5),
                    history: successHistory(baseMinutes: 15)
                ),
                makeModel(
                    name: "Cash Flow Forecast",
                    status: .running,
                    lastRefresh: hoursAgo(1),
                    history: successHistory(baseMinutes: 20)
                )
            ],
            lastSync: lastSync
        ),
        Workspace(
            id: UUID(uuidString: "A1000003-0000-0000-0000-000000000003")!,
            name: "Operations Analytics",
            healthStatus: .warning,
            semanticModels: [
                makeModel(
                    name: "Supply Chain KPIs",
                    status: .succeeded,
                    lastRefresh: hoursAgo(8),
                    history: successHistory(baseMinutes: 22)
                ),
                makeModel(
                    name: "Production Metrics",
                    status: .running,
                    lastRefresh: minutesAgo(45),
                    history: longRunningHistory()
                ),
                makeModel(
                    name: "Quality Dashboard",
                    status: .succeeded,
                    lastRefresh: hoursAgo(7),
                    history: successHistory(baseMinutes: 10)
                )
            ],
            lastSync: lastSync
        ),
        Workspace(
            id: UUID(uuidString: "A1000004-0000-0000-0000-000000000004")!,
            name: "Inventory Forecasting",
            healthStatus: .warning,
            semanticModels: [
                makeModel(
                    name: "Stock Levels",
                    status: .succeeded,
                    lastRefresh: hoursAgo(26),
                    history: successHistory(baseMinutes: 18)
                ),
                makeModel(
                    name: "Demand Planning",
                    status: .never,
                    lastRefresh: nil,
                    history: []
                ),
                makeModel(
                    name: "Reorder Analytics",
                    status: .succeeded,
                    lastRefresh: hoursAgo(10),
                    history: successHistory(baseMinutes: 14)
                )
            ],
            lastSync: lastSync
        ),
        Workspace(
            id: UUID(uuidString: "A1000005-0000-0000-0000-000000000005")!,
            name: "Customer Insights",
            healthStatus: .healthy,
            semanticModels: [
                makeModel(
                    name: "Customer 360",
                    status: .succeeded,
                    lastRefresh: hoursAgo(1),
                    history: successHistory(baseMinutes: 25)
                ),
                makeModel(
                    name: "Churn Analysis",
                    status: .succeeded,
                    lastRefresh: hoursAgo(2),
                    history: successHistory(baseMinutes: 11)
                ),
                makeModel(
                    name: "NPS Tracking",
                    status: .succeeded,
                    lastRefresh: hoursAgo(3),
                    history: successHistory(baseMinutes: 7)
                )
            ],
            lastSync: lastSync
        )
    ]

    static let alerts: [PulseAlert] = [
        PulseAlert(
            id: UUID(uuidString: "B1000001-0000-0000-0000-000000000001")!,
            type: .failedRefresh,
            severity: .critical,
            title: "Refresh Failed",
            message: "General Ledger model refresh failed due to database connection timeout.",
            workspaceName: "Finance Reporting",
            modelName: "General Ledger",
            timestamp: hoursAgo(6),
            isResolved: false
        ),
        PulseAlert(
            id: UUID(uuidString: "B1000002-0000-0000-0000-000000000002")!,
            type: .longRunningRefresh,
            severity: .warning,
            title: "Long Running Refresh",
            message: "Production Metrics refresh has been running for 45 minutes, exceeding the 30-minute threshold.",
            workspaceName: "Operations Analytics",
            modelName: "Production Metrics",
            timestamp: minutesAgo(45),
            isResolved: false
        ),
        PulseAlert(
            id: UUID(uuidString: "B1000003-0000-0000-0000-000000000003")!,
            type: .noRefreshIn24Hours,
            severity: .warning,
            title: "Stale Refresh",
            message: "Stock Levels has not refreshed in over 24 hours. Last successful refresh was yesterday.",
            workspaceName: "Inventory Forecasting",
            modelName: "Stock Levels",
            timestamp: hoursAgo(26),
            isResolved: false
        ),
        PulseAlert(
            id: UUID(uuidString: "B1000004-0000-0000-0000-000000000004")!,
            type: .noRefreshIn24Hours,
            severity: .info,
            title: "No Refresh Scheduled",
            message: "Demand Planning has never been refreshed. Consider scheduling an initial refresh.",
            workspaceName: "Inventory Forecasting",
            modelName: "Demand Planning",
            timestamp: daysAgo(3),
            isResolved: false
        ),
        PulseAlert(
            id: UUID(uuidString: "B1000005-0000-0000-0000-000000000005")!,
            type: .longRunningRefresh,
            severity: .warning,
            title: "Refresh In Progress",
            message: "Cash Flow Forecast refresh started 58 minutes ago and is still processing.",
            workspaceName: "Finance Reporting",
            modelName: "Cash Flow Forecast",
            timestamp: minutesAgo(58),
            isResolved: false
        ),
        PulseAlert(
            id: UUID(uuidString: "B1000006-0000-0000-0000-000000000006")!,
            type: .failedRefresh,
            severity: .critical,
            title: "Refresh Failed",
            message: "Previous General Ledger refresh attempt failed with authentication error.",
            workspaceName: "Finance Reporting",
            modelName: "General Ledger",
            timestamp: daysAgo(1),
            isResolved: false
        )
    ]

    static let pricingTiers: [PricingTier] = [
        PricingTier(
            name: "Free",
            price: "$0",
            period: nil,
            description: "Demo Access",
            features: [
                "Interactive demo environment",
                "Sample workspaces and alerts",
                "Dashboard preview",
                "Beta signup access"
            ]
        ),
        PricingTier(
            name: "Pro",
            price: "$19",
            description: "For individual administrators",
            features: [
                "Up to 10 workspaces",
                "Real-time refresh monitoring",
                "Email alerts",
                "30-day refresh history",
                "Mobile push notifications"
            ],
            isHighlighted: true
        ),
        PricingTier(
            name: "Business",
            price: "$99",
            description: "For teams and departments",
            features: [
                "Unlimited workspaces",
                "Advanced alerting rules",
                "Team collaboration",
                "90-day refresh history",
                "Priority support",
                "Custom health thresholds"
            ]
        ),
        PricingTier(
            name: "Consultant",
            price: "$249",
            description: "For MSPs and consultants",
            features: [
                "Multi-tenant monitoring",
                "Client workspace grouping",
                "White-label reports",
                "API access",
                "Dedicated account manager",
                "Unlimited team members"
            ]
        )
    ]

    static func dashboardMetrics(
        from workspaces: [Workspace],
        alerts: [PulseAlert],
        lastSync: Date = lastSync
    ) -> DashboardMetrics {
        let totalModels = workspaces.flatMap(\.semanticModels).count
        let failed = workspaces.flatMap(\.semanticModels).filter { $0.refreshStatus == .failed }.count
        let warnings = alerts.filter { !$0.isResolved && $0.severity != .critical }.count
        let activeCritical = alerts.filter { !$0.isResolved && $0.severity == .critical }.count

        let score = max(0, min(100, 100 - (failed * 12) - (activeCritical * 8) - (warnings * 3)))

        return DashboardMetrics(
            healthScore: score,
            failedRefreshCount: failed,
            warningCount: warnings + activeCritical,
            workspacesMonitored: workspaces.count,
            lastSync: lastSync,
            healthTrend: [92, 88, 85, 90, 87, 84, score]
        )
    }

    // MARK: - Helpers

    private static func makeModel(
        name: String,
        status: RefreshStatus,
        lastRefresh: Date?,
        history: [RefreshHistoryEntry],
        error: String? = nil
    ) -> SemanticModel {
        SemanticModel(
            id: UUID(),
            name: name,
            refreshStatus: status,
            lastRefresh: lastRefresh,
            refreshHistory: history,
            errorMessage: error ?? history.first(where: { $0.status == .failed })?.errorMessage
        )
    }

    private static func successHistory(baseMinutes: Int) -> [RefreshHistoryEntry] {
        (0..<7).map { index in
            let variance = Double.random(in: -120...180)
            let duration = TimeInterval(baseMinutes * 60) + variance
            return RefreshHistoryEntry(
                id: UUID(),
                timestamp: daysAgo(index).addingTimeInterval(-Double(index) * 3600),
                status: .succeeded,
                duration: max(60, duration),
                errorMessage: nil
            )
        }.sorted { $0.timestamp > $1.timestamp }
    }

    private static func failedHistory(error: String) -> [RefreshHistoryEntry] {
        var entries = successHistory(baseMinutes: 12)
        entries.insert(
            RefreshHistoryEntry(
                id: UUID(),
                timestamp: hoursAgo(6),
                status: .failed,
                duration: TimeInterval(30 * 60),
                errorMessage: error
            ),
            at: 0
        )
        entries.insert(
            RefreshHistoryEntry(
                id: UUID(),
                timestamp: daysAgo(1),
                status: .failed,
                duration: TimeInterval(15 * 60),
                errorMessage: "Authentication failed: Token expired for service principal 'sp-finance-reporting'."
            ),
            at: 1
        )
        return entries
    }

    private static func longRunningHistory() -> [RefreshHistoryEntry] {
        var entries = successHistory(baseMinutes: 18)
        entries.insert(
            RefreshHistoryEntry(
                id: UUID(),
                timestamp: minutesAgo(45),
                status: .running,
                duration: TimeInterval(45 * 60),
                errorMessage: nil
            ),
            at: 0
        )
        return entries
    }

    private static func minutesAgo(_ minutes: Int) -> Date {
        Date().addingTimeInterval(-Double(minutes * 60))
    }

    private static func hoursAgo(_ hours: Int) -> Date {
        Date().addingTimeInterval(-Double(hours * 3600))
    }

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
