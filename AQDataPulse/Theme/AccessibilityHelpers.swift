import SwiftUI

enum AccessibilityHelpers {
    static func trendSummary(values: [Int]) -> String {
        guard !values.isEmpty else { return "No trend data available." }
        let formatted = values.map(String.init).joined(separator: ", ")
        if values.count == 1 {
            return "Health score \(values[0])."
        }
        return "Health scores over 7 days, oldest to newest: \(formatted)."
    }
}

extension View {
    @ViewBuilder
    func animationIfAllowed<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(ReduceMotionAnimationModifier(animation: animation, value: value))
    }
}

private struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
