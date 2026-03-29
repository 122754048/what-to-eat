import SwiftUI

// MARK: - Paywall View
struct PaywallView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.Spacing.cardMargin * 2) {
                    // Header
                    headerSection

                    // Features
                    featuresSection

                    // Plans
                    plansSection

                    // Restore
                    restoreSection
                }
                .padding(Design.Spacing.screenPadding)
            }
            .background(Design.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Design.Colors.secondaryText)
                    }
                }
            }
        }
        .task {
            await subscriptionManager.loadProducts()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: Design.Spacing.standard) {
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundColor(Design.Colors.accent)

            Text("解锁全部功能")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("升级 Pro 享受无限滑动和更多特权")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Design.Spacing.cardMargin)
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: Design.Spacing.standard) {
            FeatureRow(icon: "die.face.5.fill", title: "无限滑动", subtitle: "每天100次推荐机会", color: Design.Colors.accent)
            FeatureRow(icon: "DNA.fill", title: "口味DNA", subtitle: "AI学习你的偏好", color: Design.Colors.primary)
            FeatureRow(icon: "clock.fill", title: "永久历史", subtitle: "回顾所有推荐记录", color: Design.Colors.primary)
            FeatureRow(icon: "chart.bar.fill", title: "每周报告", subtitle: "饮食数据分析", color: Design.Colors.primary)
        }
    }

    // MARK: - Plans
    private var plansSection: some View {
        VStack(spacing: Design.Spacing.standard) {
            // Pro Monthly
            PlanCard(
                title: "Pro 月卡",
                price: "¥9.9",
                period: "/月",
                features: ["每天100次滑动", "口味DNA", "永久历史", "每周报告"],
                isRecommended: false
            ) {
                Task {
                    try? await subscriptionManager.purchase(.proMonthly)
                }
            }

            // Pro Yearly
            PlanCard(
                title: "Pro 年卡",
                price: "¥79",
                period: "/年",
                features: ["每天100次滑动", "口味DNA", "永久历史", "每周报告", "省¥40"],
                isRecommended: true,
                badge: "最划算"
            ) {
                Task {
                    try? await subscriptionManager.purchase(.proYearly)
                }
            }

            // Family Monthly
            PlanCard(
                title: "Family 月卡",
                price: "¥19.9",
                period: "/月",
                features: ["5人共享", "每天100次/人", "口味DNA", "永久历史"],
                isRecommended: false
            ) {
                Task {
                    try? await subscriptionManager.purchase(.familyMonthly)
                }
            }

            // Family Yearly
            PlanCard(
                title: "Family 年卡",
                price: "¥159",
                period: "/年",
                features: ["5人共享", "每天100次/人", "口味DNA", "永久历史", "省¥79"],
                isRecommended: false
            ) {
                Task {
                    try? await subscriptionManager.purchase(.familyYearly)
                }
            }
        }
    }

    // MARK: - Restore
    private var restoreSection: some View {
        Button {
            Task {
                await subscriptionManager.restorePurchases()
            }
        } label: {
            Text("恢复购买")
                .font(.subheadline)
                .foregroundColor(Design.Colors.secondaryText)
        }
        .padding(.top, Design.Spacing.standard)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: Design.Spacing.cardPadding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Design.Colors.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Design.Colors.primary)
        }
        .padding(Design.Spacing.standard)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Design.Colors.cardBackground)
        )
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let features: [String]
    let isRecommended: Bool
    var badge: String? = nil
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: Design.Spacing.standard) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(Design.Colors.primaryText)

                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Design.Colors.accent)
                                )
                        }
                    }

                    if isRecommended {
                        Text("推荐")
                            .font(.caption)
                            .foregroundColor(Design.Colors.accent)
                    }
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(price)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Design.Colors.primaryText)
                    Text(period)
                        .font(.caption)
                        .foregroundColor(Design.Colors.secondaryText)
                }
            }

            // Features
            VStack(alignment: .leading, spacing: Design.Spacing.element) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: Design.Spacing.element) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(Design.Colors.primary)

                        Text(feature)
                            .font(.caption)
                            .foregroundColor(Design.Colors.secondaryText)
                    }
                }
            }

            // Button
            Button(action: onPurchase) {
                Text("Subscribe Now")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Design.Spacing.standard)
                    .background(
                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                            .fill(isRecommended ? Design.Colors.accent : Design.Colors.primary)
                    )
            }
        }
        .padding(Design.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Color.white)
                .shadow(color: .black.opacity(isRecommended ? 0.15 : 0.05), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .stroke(isRecommended ? Design.Colors.accent : Design.Colors.border, lineWidth: isRecommended ? 2 : 1)
        )
    }
}

// MARK: - Swipe Limit Warning
struct SwipeLimitWarningView: View {
    let remainingSwipes: Int
    @Binding var showPaywall: Bool

    var body: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Design.Colors.accent)

            Text("今日滑动次数已用完")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("明天将重置为 \(remainingSwipes) 次")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)

            Button {
                showPaywall = true
            } label: {
                Text("升级 Pro 解锁无限滑动")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Design.Spacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                            .fill(Design.Colors.accent)
                    )
            }
            .padding(.top, Design.Spacing.standard)

            Button("稍后") {
                showPaywall = false
            }
            .font(.subheadline)
            .foregroundColor(Design.Colors.secondaryText)
        }
        .padding(Design.Spacing.screenPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Color.white)
        )
        .padding(.horizontal, Design.Spacing.screenPadding)
    }
}
