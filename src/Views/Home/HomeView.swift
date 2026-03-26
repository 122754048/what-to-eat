import SwiftUI

// MARK: - Design Tokens
enum Design {
    enum Colors {
        static let primary = Color(hex: "#7CB97D")
        static let accent = Color(hex: "#F4A261")
        static let background = Color(hex: "#FFFFFF")
        static let cardBackground = Color(hex: "#F8F8F8")
        static let primaryText = Color(hex: "#2D2D2D")
        static let secondaryText = Color(hex: "#8E8E93")
        static let border = Color(hex: "#E8E8E8")
    }

    enum Spacing {
        static let screenPadding: CGFloat = 20
        static let cardPadding: CGFloat = 16
        static let cardMargin: CGFloat = 16
        static let compact: CGFloat = 4
        static let element: CGFloat = 8
        static let standard: CGFloat = 12
    }

    enum CornerRadius {
        static let card: CGFloat = 20
        static let button: CGFloat = 12
        static let tag: CGFloat = 10
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Home View
struct HomeView: View {
    @State private var dishes: [Dish] = []
    @State private var currentIndex = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var lastAction: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: Design.Spacing.cardMargin) {
                    // Header
                    headerView

                    Spacer()

                    // Card Stack or Empty State
                    if isLoading {
                        loadingView
                    } else if dishes.isEmpty {
                        emptyStateView
                    } else if currentIndex < dishes.count {
                        cardStackView
                    } else {
                        allDoneView
                    }

                    Spacer()

                    // Action Buttons
                    if !dishes.isEmpty && currentIndex < dishes.count {
                        actionButtonsView
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .navigationBarHidden(true)
            .alert("出错了", isPresented: $showAlert) {
                Button("重试") { loadDishes() }
                Button("取消", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "未知错误")
            }
            .onAppear {
                if dishes.isEmpty {
                    loadDishes()
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.element) {
            Text("今天吃什么？")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Text("滑动卡片，探索美食")
                .font(.subheadline)
                .foregroundColor(Design.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Design.Spacing.screenPadding)
    }

    private var loadingView: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Design.Colors.primary))
            Text("正在加载...")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
        }
        .frame(height: 480)
    }

    private var emptyStateView: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(Design.Colors.secondaryText)

            Text("暂无菜品推荐")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Design.Colors.primaryText)

            Text("稍后再试")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)

            Button {
                loadDishes()
            } label: {
                Text("刷新")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Design.Spacing.cardMargin)
                    .padding(.vertical, Design.Spacing.standard)
                    .background(
                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                            .fill(Design.Colors.accent)
                    )
            }
            .padding(.top, Design.Spacing.standard)
        }
        .frame(height: 480)
    }

    private var allDoneView: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Design.Colors.primary)

            Text("今日推荐已全部完成！")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Design.Colors.primaryText)

            Text("明天再来发现更多美食吧")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)

            Button {
                currentIndex = 0
                loadDishes()
            } label: {
                Text("重新开始")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Design.Spacing.cardMargin)
                    .padding(.vertical, Design.Spacing.standard)
                    .background(
                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                            .fill(Design.Colors.accent)
                    )
            }
            .padding(.top, Design.Spacing.standard)
        }
        .frame(height: 480)
    }

    private var cardStackView: some View {
        ZStack {
            ForEach(visibleDishes.reversed()) { dish in
                SwipeCardView(
                    dish: dish,
                    onSwipeLeft: { handleSwipeLeft(dish) },
                    onSwipeRight: { handleSwipeRight(dish) },
                    onSwipeUp: { handleSwipeUp(dish) }
                )
                .zIndex(zIndex(for: dish))
            }
        }
        .frame(height: 480)
    }

    private var actionButtonsView: some View {
        HStack(spacing: Design.Spacing.cardMargin) {
            // Nope Button
            actionButton(
                icon: "xmark",
                color: .red,
                size: 50,
                action: { swipeCurrentCard(direction: .left) }
            )

            // Super Like Button
            actionButton(
                icon: "star.fill",
                color: .yellow,
                size: 44,
                action: { swipeCurrentCard(direction: .up) }
            )

            // Like Button
            actionButton(
                icon: "heart.fill",
                color: Design.Colors.primary,
                size: 50,
                action: { swipeCurrentCard(direction: .right) }
            )
        }
        .padding(.bottom, Design.Spacing.cardMargin)
    }

    private func actionButton(icon: String, color: Color, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Computed Properties

    private var visibleDishes: [Dish] {
        let endIndex = min(currentIndex + 3, dishes.count)
        guard currentIndex < endIndex else { return [] }
        return Array(dishes[currentIndex..<endIndex])
    }

    private func zIndex(for dish: Dish) -> Double {
        guard let index = visibleDishes.firstIndex(where: { $0.id == dish.id }) else {
            return 0
        }
        return Double(visibleDishes.count - index)
    }

    // MARK: - Actions

    private func loadDishes() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let cuisines = try await fetchCuisines()
                guard let randomCuisine = cuisines.randomElement() else {
                    throw APIError.serverError(code: 50001, message: "暂无菜系数据")
                }

                // Load multiple dishes for the card stack
                var loadedDishes: [Dish] = []
                for _ in 0..<5 {
                    let dish = try await fetchRecommendDish(cuisineId: randomCuisine.id)
                    loadedDishes.append(dish)
                }

                await MainActor.run {
                    dishes = loadedDishes
                    currentIndex = 0
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    showAlert = true
                }
            }
        }
    }

    private func handleSwipeLeft(_ dish: Dish) {
        lastAction = "跳过 \(dish.name)"
        currentIndex += 1
    }

    private func handleSwipeRight(_ dish: Dish) {
        lastAction = "喜欢 \(dish.name)"
        // TODO: Send feedback to backend
        currentIndex += 1
    }

    private func handleSwipeUp(_ dish: Dish) {
        lastAction = "超级喜欢 \(dish.name)"
        // TODO: Send super like feedback to backend
        currentIndex += 1
    }

    private enum SwipeDirection {
        case left, right, up
    }

    private func swipeCurrentCard(direction: SwipeDirection) {
        guard currentIndex < dishes.count else { return }
        let dish = dishes[currentIndex]

        switch direction {
        case .left: handleSwipeLeft(dish)
        case .right: handleSwipeRight(dish)
        case .up: handleSwipeUp(dish)
        }
    }

    // MARK: - Data Access (supports mock)
    private func fetchCuisines() async throws -> [Cuisine] {
        if APIConfig.useMock {
            return try await MockAPIService.shared.getCuisines()
        } else {
            return try await APIService.shared.getCuisines()
        }
    }

    private func fetchRecommendDish(cuisineId: String) async throws -> Dish {
        if APIConfig.useMock {
            return try await MockAPIService.shared.recommendDish(cuisineId: cuisineId)
        } else {
            return try await APIService.shared.recommendDish(cuisineId: cuisineId)
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
