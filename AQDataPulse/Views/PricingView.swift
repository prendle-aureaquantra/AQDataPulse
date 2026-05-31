import SwiftUI

struct PricingView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                ForEach(viewModel.pricingTiers) { tier in
                    PricingTierCard(tier: tier)
                }

                footerNote
            }
            .padding()
        }
        .background(AppTheme.screenBackground)
        .navigationTitle("Pricing")
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Choose Your Plan")
                .font(.title2.weight(.bold))

            Text("Start with the free demo today. Upgrade when Microsoft Fabric integration launches.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 4)
    }

    private var footerNote: some View {
        VStack(spacing: 12) {
            Text("Payment processing coming in a future release.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            BetaSignupButton()
        }
        .padding(.top, 8)
    }
}

struct PricingTierCard: View {
    let tier: PricingTier

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.name)
                        .font(.title3.weight(.bold))

                    Text(tier.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(tier.price)
                        .font(.title2.weight(.bold))
                    if let period = tier.period {
                        Text(period)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if tier.isHighlighted {
                Text("Most Popular")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.brandPrimary.opacity(0.15))
                    .foregroundStyle(AppTheme.brandPrimary)
                    .clipShape(Capsule())
            }

            Divider()

            ForEach(tier.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                    Text(feature)
                        .font(.subheadline)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay {
            if tier.isHighlighted {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.brandPrimary, lineWidth: 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PricingView()
            .environmentObject(AppViewModel())
    }
}
