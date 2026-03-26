import SwiftUI

struct HealthView: View {
    @State private var selectedGoal: String? = nil
    @State private var recommendedDishes: [Dish] = []
    @State private var isLoading = false
    @State private var showResults = false
    @State private var errorMessage: String?

    private let goals = [
        ("减脂", "leaf.fill"),
        ("高蛋白", "figure.strengthtraining.traditional"),
        ("清淡", "drop.fill"),
        ("低碳水", "bolt.fill")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: Design.Spacing.cardMargin) {
                    // Title
                    Text("健康饮食")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Design.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Design.Spacing.screenPadding)

                    // Goal Selection
                    Text("选择你的健康目标")
                        .font(.subheadline)
                        .foregroundColor(Design.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Design.Spacing.cardMargin) {
                        ForEach(goals, id: \.0) { goal in
                            HealthGoalButton(
                                title: goal.0,
                                icon: goal.1,
                                isSelected: selectedGoal == goal.0
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedGoal = goal.0
                                }
                            }
                        }
                    }

                    Spacer()

                    // Suggest Button
                    Button {
                        triggerSuggestion()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("开始推荐")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Design.Spacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                                .fill(selectedGoal != nil ? Design.Colors.primary : Design.Colors.secondaryText)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(selectedGoal == nil || isLoading)
                    .padding(.bottom, Design.Spacing.cardMargin)
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showResults) {
                HealthResultSheet(dishes: recommendedDishes) {
                    showResults = false
                }
            }
        }
    }

    private func triggerSuggestion() {
        guard let goal = selectedGoal else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let dish = try await fetchHealthyDish(goal: goal)
                await MainActor.run {
                    recommendedDishes = [dish]
                    isLoading = false
                    showResults = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    // MARK: - Data Access (supports mock)
    private func fetchHealthyDish(goal: String) async throws -> Dish {
        if APIConfig.useMock {
            // In mock mode, just return a random healthy dish
            let cuisines = try await MockAPIService.shared.getCuisines()
            if let randomCuisine = cuisines.randomElement() {
                return try await MockAPIService.shared.recommendDish(cuisineId: randomCuisine.id)
            }
            throw APIError.serverError(code: 50001, message: "暂无数据")
        } else {
            return try await AIService.shared.suggestHealthy(goal: goal)
        }
    }
}

// MARK: - Health Goal Button
struct HealthGoalButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Design.Spacing.standard) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : Design.Colors.primary)
                    .symbolRenderingMode(.hierarchical)

                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Design.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Design.Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .fill(isSelected ? Design.Colors.primary : Design.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                    .stroke(isSelected ? Color.clear : Design.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Health Result Sheet
struct HealthResultSheet: View {
    let dishes: [Dish]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                if dishes.isEmpty {
                    VStack(spacing: Design.Spacing.cardMargin) {
                        Image(systemName: "leaf")
                            .font(.largeTitle)
                            .foregroundColor(Design.Colors.secondaryText)
                        Text("暂无推荐")
                            .font(.body)
                            .foregroundColor(Design.Colors.secondaryText)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: Design.Spacing.cardMargin) {
                            ForEach(dishes) { dish in
                                HealthDishCard(dish: dish)
                            }
                        }
                        .padding(Design.Spacing.screenPadding)
                    }
                }
            }
            .navigationTitle("健康推荐")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        onDismiss()
                    }
                    .foregroundColor(Design.Colors.accent)
                }
            }
        }
    }
}

// MARK: - Health Dish Card
struct HealthDishCard: View {
    let dish: Dish

    var body: some View {
        HStack(spacing: Design.Spacing.standard) {
            // Image
            AsyncImage(url: dish.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Design.Colors.secondaryText)
                        )
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(Design.CornerRadius.card)

            // Info
            VStack(alignment: .leading, spacing: Design.Spacing.element) {
                Text(dish.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                Text(dish.cuisineName)
                    .font(.subheadline)
                    .foregroundColor(Design.Colors.secondaryText)

                if let calories = dish.calories {
                    HStack(spacing: Design.Spacing.compact) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(Design.Colors.primary)
                        Text("\(calories.min)-\(calories.max) \(calories.unit)")
                            .font(.caption)
                            .foregroundColor(Design.Colors.primary)
                    }
                }
            }

            Spacer()
        }
        .padding(Design.Spacing.standard)
        .background(Design.Colors.cardBackground)
        .cornerRadius(Design.CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
