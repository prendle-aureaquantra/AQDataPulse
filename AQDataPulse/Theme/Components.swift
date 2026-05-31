import SwiftUI

enum AppTheme {
    static let brandPrimary = Color(red: 0.12, green: 0.35, blue: 0.72)
    static let brandSecondary = Color(red: 0.08, green: 0.55, blue: 0.78)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let screenBackground = Color(.systemGroupedBackground)

    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                Spacer()
            }

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct HealthScoreRing: View {
    let score: Int
    let status: HealthStatus

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 12)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    status.color,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: score)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("Health")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
    }
}

struct SimpleLineChart: View {
    let values: [Int]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let maxValue = max(values.max() ?? 100, 1)
            let minValue = min(values.min() ?? 0, maxValue - 1)
            let range = CGFloat(max(maxValue - minValue, 1))
            let stepX = geometry.size.width / CGFloat(max(values.count - 1, 1))

            ZStack {
                Path { path in
                    for (index, value) in values.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalized = CGFloat(value - minValue) / range
                        let y = geometry.size.height - (normalized * geometry.size.height)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    let x = CGFloat(index) * stepX
                    let normalized = CGFloat(value - minValue) / range
                    let y = geometry.size.height - (normalized * geometry.size.height)

                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: 80)
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.medium))
            }
        }
    }
}

struct DemoBanner: View {
    var isDemoMode: Bool = true

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isDemoMode ? "play.circle.fill" : "link.circle.fill")
                .foregroundStyle(isDemoMode ? AppTheme.brandSecondary : .green)
            Text(isDemoMode ? "Demo Mode — Sample data shown" : "Connected — Live sync coming in v2")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background((isDemoMode ? AppTheme.brandSecondary : Color.green).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct BetaSignupButton: View {
    var body: some View {
        Link(destination: URL(string: "mailto:therendle@gmail.com?subject=AQ%20Data%20Pulse%20Beta%20Access%20Request&body=Hi%2C%0A%0AI%27d%20like%20to%20request%20beta%20access%20for%20AQ%20Data%20Pulse.%0A%0AThank%20you!")!) {
            HStack {
                Image(systemName: "envelope.fill")
                Text("Request Beta Access")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.brandPrimary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }
}
