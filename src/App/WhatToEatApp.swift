import SwiftUI

@main
struct WhatToEatApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedCuisines") private var selectedCuisines: String = ""
    @AppStorage("selectedDiets") private var selectedDiets: String = ""
    @AppStorage("selectedTastes") private var selectedTastes: String = ""

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingContainerView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    selectedCuisines: $selectedCuisines,
                    selectedDiets: $selectedDiets,
                    selectedTastes: $selectedTastes
                )
            }
        }
    }
}

// MARK: - Onboarding Container
struct OnboardingContainerView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var selectedCuisines: String
    @Binding var selectedDiets: String
    @Binding var selectedTastes: String
    @State private var currentStep = 0

    private let cuisines = [
        ("川菜", "🌶️"), ("粤菜", "🥮"), ("湘菜", "🔥"), ("鲁菜", "🥬"),
        ("苏菜", "🍳"), ("浙菜", "🦐"), ("闽菜", "🦑"), ("徽菜", "🍄")
    ]

    private let dietOptions = ["辣", "清淡", "素食", "海鲜", "甜食", "麻辣", "酸辣", "清淡"]

    private let tasteOptions = ["微辣", "中辣", "不辣", "酸", "甜", "咸", "鲜"]

    var body: some View {
        ZStack {
            Design.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with skip
                HStack {
                    Spacer()
                    Button("跳过") {
                        hasCompletedOnboarding = true
                    }
                    .font(.body)
                    .foregroundColor(Design.Colors.secondaryText)
                    .padding(.top, 8)
                    .padding(.trailing, Design.Spacing.screenPadding)
                }
                .padding(.top, 8)

                // Progress indicator
                progressIndicator
                    .padding(.top, Design.Spacing.standard)

                // Step content
                TabView(selection: $currentStep) {
                    step1View.tag(0)
                    step2View.tag(1)
                    step3View.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom CTA
                ctaButton
                    .padding(.horizontal, Design.Spacing.screenPadding)
                    .padding(.bottom, Design.Spacing.cardMargin)
            }
        }
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: Design.Spacing.element) {
            HStack(spacing: Design.Spacing.standard) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Design.Colors.primary : Design.Colors.border)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, Design.Spacing.screenPadding)

            Text("\(currentStep + 1)/3")
                .font(.caption)
                .foregroundColor(Design.Colors.secondaryText)
        }
    }

    // MARK: - Step 1: Cuisine Selection
    private var step1View: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text("欢迎使用「吃什么」")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Design.Colors.primaryText)

                Text("选择你喜欢的菜系（可多选）")
                    .font(.body)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(.horizontal, Design.Spacing.screenPadding)
            .padding(.top, Design.Spacing.cardMargin)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Design.Spacing.element),
                    GridItem(.flexible(), spacing: Design.Spacing.element)
                ], spacing: Design.Spacing.element) {
                    ForEach(cuisines, id: \.0) { cuisine in
                        CuisineChip(name: cuisine.0, isSelected: selectedCuisines.contains(cuisine.0)) {
                            toggleSelection(cuisine: cuisine.0, key: "cuisines")
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .padding(.top, Design.Spacing.standard)
        }
    }

    // MARK: - Step 2: Dietary Filter
    private var step2View: View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text("有什么忌口？")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Design.Colors.primaryText)

                Text("选择你的饮食偏好（可多选）")
                    .font(.body)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(.horizontal, Design.Spacing.screenPadding)
            .padding(.top, Design.Spacing.cardMargin)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Design.Spacing.element),
                    GridItem(.flexible(), spacing: Design.Spacing.element),
                    GridItem(.flexible(), spacing: Design.Spacing.element)
                ], spacing: Design.Spacing.element) {
                    ForEach(dietOptions, id: \.self) { diet in
                        DietChip(name: diet, isSelected: selectedDiets.contains(diet)) {
                            toggleSelection(cuisine: diet, key: "diets")
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .padding(.top, Design.Spacing.standard)
        }
    }

    // MARK: - Step 3: Taste Preference
    private var step3View: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text("口味偏好")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Design.Colors.primaryText)

                Text("选择你喜欢的口味（可多选）")
                    .font(.body)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(.horizontal, Design.Spacing.screenPadding)
            .padding(.top, Design.Spacing.cardMargin)

            ScrollView {
                VStack(spacing: Design.Spacing.element) {
                    ForEach(tasteOptions, id: \.self) { taste in
                        TasteRow(
                            name: taste,
                            isSelected: selectedTastes.contains(taste)
                        ) {
                            toggleSelection(cuisine: taste, key: "tastes")
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .padding(.top, Design.Spacing.standard)
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            if currentStep < 2 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                        .fill(Design.Colors.accent)
                )
        }
    }

    // MARK: - Helpers
    private func toggleSelection(cuisine: String, key: String) {
        switch key {
        case "cuisines":
            var list = selectedCuisines.split(separator: ",").map(String.init)
            if list.contains(cuisine) {
                list.removeAll { $0 == cuisine }
            } else {
                list.append(cuisine)
            }
            selectedCuisines = list.joined(separator: ",")
        case "diets":
            var list = selectedDiets.split(separator: ",").map(String.init)
            if list.contains(cuisine) {
                list.removeAll { $0 == cuisine }
            } else {
                list.append(cuisine)
            }
            selectedDiets = list.joined(separator: ",")
        case "tastes":
            var list = selectedTastes.split(separator: ",").map(String.init)
            if list.contains(cuisine) {
                list.removeAll { $0 == cuisine }
            } else {
                list.append(cuisine)
            }
            selectedTastes = list.joined(separator: ",")
        default:
            break
        }
    }
}

// MARK: - Cuisine Chip
struct CuisineChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.caption)
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : Design.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .fill(isSelected ? Design.Colors.primary : Design.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .stroke(isSelected ? Design.Colors.primary : Design.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Diet Chip
struct DietChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Design.Colors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Design.CornerRadius.tag)
                        .fill(isSelected ? Design.Colors.primary : Design.Colors.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Design.CornerRadius.tag)
                        .stroke(isSelected ? Design.Colors.primary : Design.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Taste Row
struct TasteRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.body)
                    .foregroundColor(Design.Colors.primaryText)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Design.Colors.primary : Design.Colors.border)
                    .font(.title3)
            }
            .padding(.horizontal, Design.Spacing.cardPadding)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .fill(Design.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .stroke(isSelected ? Design.Colors.primary : Design.Colors.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Content View (5-Tab Navigation)
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
            FavoritesView()
                .tabItem {
                    Label("收藏", systemImage: "heart.fill")
                }
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock.fill")
                }
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Design.Colors.tabActive)
    }
}
