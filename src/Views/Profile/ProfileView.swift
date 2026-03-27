import SwiftUI

struct ProfileView: View {
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Design.Spacing.cardMargin) {
                        // Profile Header
                        profileHeader

                        // Subscription Status
                        subscriptionCard

                        // Menu Items
                        menuSection
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("我的")
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Design.Spacing.standard) {
            // Avatar
            Circle()
                .fill(Design.Colors.primary.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundColor(Design.Colors.primary)
                )

            Text("美食探索者")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Design.Colors.primaryText)

            Text("今天也要好好吃饭")
                .font(.subheadline)
                .foregroundColor(Design.Colors.secondaryText)
        }
        .padding(.vertical, Design.Spacing.cardMargin)
    }

    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(spacing: Design.Spacing.standard) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: Design.Spacing.element) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Design.Colors.accent)
                        Text(subscriptionTierName)
                            .font(.headline)
                            .foregroundColor(Design.Colors.primaryText)
                    }

                    Text(subscriptionDesc)
                        .font(.caption)
                        .foregroundColor(Design.Colors.secondaryText)
                }

                Spacer()

                if subscriptionManager.state.tier == .free {
                    Button {
                        // Show paywall
                    } label: {
                        Text("升级")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Design.Spacing.cardPadding)
                            .padding(.vertical, Design.Spacing.element)
                            .background(
                                RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                                    .fill(Design.Colors.accent)
                            )
                    }
                } else {
                    Text("已激活")
                        .font(.caption)
                        .foregroundColor(Design.Colors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Design.Colors.primary.opacity(0.12))
                        )
                }
            }
        }
        .padding(Design.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .padding(.horizontal, Design.Spacing.screenPadding)
    }

    private var subscriptionTierName: String {
        switch subscriptionManager.state.tier {
        case .free: return "Free 用户"
        case .pro: return "Pro 会员"
        case .family: return "Family 会员"
        }
    }

    private var subscriptionDesc: String {
        switch subscriptionManager.state.tier {
        case .free: return "今日剩余 \(subscriptionManager.state.remainingSwipes) 次滑动"
        case .pro: return "Pro 会员 · \(subscriptionManager.state.remainingSwipes)/100 次"
        case .family: return "Family 会员 · \(subscriptionManager.state.remainingSwipes)/100 次"
        }
    }

    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: Design.Spacing.standard) {
            MenuRow(icon: "clock.arrow.circlepath", title: "历史记录", color: Design.Colors.primary) {
                // Navigate to history
            }

            MenuRow(icon: "heart.fill", title: "我的收藏", color: Design.Colors.accent) {
                // Navigate to favorites
            }

            MenuRow(icon: "gearshape.fill", title: "设置", color: Design.Colors.secondaryText) {
                // Navigate to settings
            }

            MenuRow(icon: "doc.text.fill", title: "关于", color: Design.Colors.secondaryText) {
                // Navigate to about
            }

            MenuRow(icon: "hand.raised.fill", title: "隐私政策", color: Design.Colors.secondaryText) {
                // Navigate to privacy
            }
        }
        .padding(.horizontal, Design.Spacing.screenPadding)
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.cardPadding) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32)

                Text(title)
                    .font(.body)
                    .foregroundColor(Design.Colors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(Design.Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
    }
}
