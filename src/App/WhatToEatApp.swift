import SwiftUI

@main
struct WhatToEatApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0

    var body: some View {
        ZStack {
            Design.Colors.background
                .ignoresSafeArea()

            VStack {
                TabView(selection: $currentStep) {
                    OnboardingStep1()
                        .tag(0)
                    OnboardingStep2()
                        .tag(1)
                    OnboardingStep3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if currentStep < 2 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentStep < 2 ? "下一步" : "开始探索")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Design.Spacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                                .fill(Design.Colors.primary)
                        )
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
                .padding(.bottom, Design.Spacing.cardMargin)
            }
        }
    }
}

// MARK: - Onboarding Step 1
struct OnboardingStep1: View {
    var body: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Spacer()

            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 120))
                .foregroundColor(Design.Colors.primary)

            Text("今天吃什么？")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("告别选择困难症\nAI 帮你决定")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(Design.Spacing.screenPadding)
    }
}

// MARK: - Onboarding Step 2
struct OnboardingStep2: View {
    var body: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Spacer()

            Image(systemName: "hand.draw.fill")
                .font(.system(size: 120))
                .foregroundColor(Design.Colors.accent)

            Text("滑动探索美食")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("左右滑动卡片\n喜欢就收藏，不喜欢就跳过")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(Design.Spacing.screenPadding)
    }
}

// MARK: - Onboarding Step 3
struct OnboardingStep3: View {
    var body: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 120))
                .foregroundColor(Design.Colors.accent)

            Text("升级 Pro 会员")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("解锁无限滑动\n享受更多特权")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(Design.Spacing.screenPadding)
    }
}

// MARK: - ContentView (Main Tab Bar)
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "safari.fill")
                }
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Design.Colors.primary)
    }
}
