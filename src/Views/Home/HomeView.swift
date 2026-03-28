
// MARK: - Home View (Container)
struct HomeView: View {
    @State private var selectedMode: HomeMode = .swipe

    enum HomeMode: String, CaseIterable {
        case swipe = "滑动"
        case browse = "浏览"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Mode Picker
                    modePicker

                    // Content
                    switch selectedMode {
                    case .swipe:
                        SwipeCardContainer()
                    case .browse:
                        HomeContentView()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("今天吃什么？")
                        .font(.headline)
                        .foregroundColor(Design.Colors.primaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: selectedFilters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(Design.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showFilter) {
                DietFilterSheet(selectedFilters: $selectedFilters) {
                    // Apply filters - in production, would refetch dishes
                }
            }
        }
    }

    private var modePicker: some View {
        Picker("", selection: $selectedMode) {
            ForEach(HomeMode.allCases, id: \.self) { mode in
                Text(mode.rawValue)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Design.Spacing.screenPadding)
        .padding(.vertical, Design.Spacing.standard)
    }
}

// MARK: - Swipe Card Container
struct SwipeCardContainer: View {
    @State private var dishes: [Dish] = []
    @State private var currentIndex = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var showDetail = false
    @State private var selectedDish: Dish?
    @State private var showFilter = false
    @State private var selectedFilters: Set<DietFilter> = []
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            if isLoading {
                loadingView
            } else if dishes.isEmpty {
                emptyStateView
            } else if currentIndex >= dishes.count {
                allDoneView
            } else {
                cardStackView
            }
        }
        .onAppear {
            if dishes.isEmpty {
                loadDishes()
            }
        }
        .alert("出错了", isPresented: $showAlert) {
            Button("重试") { loadDishes() }
            Button("取消", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "未知错误")
        }
        .sheet(isPresented: $showDetail) {
            if let dish = selectedDish {
                DishDetailSheet(dish: dish)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Design.Colors.primary))
            Text("正在加载...")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
        }
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
        }
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
        }
    }

    private var cardStackView: some View {
        VStack {
            Spacer()

            ZStack {
                ForEach(visibleDishes.reversed()) { dish in
                    SwipeCardView(
                        dish: dish,
                        onSwipeLeft: { handleSwipe(dish, direction: .left) },
                        onSwipeRight: { handleSwipe(dish, direction: .right) },
                        onSwipeUp: { handleSwipe(dish, direction: .up) }
                    )
                    .zIndex(zIndex(for: dish))
                    .onTapGesture {
                        selectedDish = dish
                        showDetail = true
                    }
                }
            }
            .frame(height: 500)

            Spacer()

            actionButtons
        }
        .padding(.horizontal, Design.Spacing.screenPadding)
    }

    private var actionButtons: some View {
        HStack(spacing: Design.Spacing.cardMargin * 2) {
            actionButton(icon: "xmark", color: .red, size: 50) {
                swipeCurrentCard(direction: .left)
            }

            actionButton(icon: "star.fill", color: .yellow, size: 44) {
                swipeCurrentCard(direction: .up)
            }

            actionButton(icon: "heart.fill", color: Design.Colors.primary, size: 50) {
                swipeCurrentCard(direction: .right)
            }
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

    // MARK: - Computed

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

    private enum SwipeDirection { case left, right, up }

    private func handleSwipe(_ dish: Dish, direction: SwipeDirection) {
        switch direction {
        case .left: currentIndex += 1
        case .right: currentIndex += 1
        case .up: currentIndex += 1
        }
    }

    private func swipeCurrentCard(direction: SwipeDirection) {
        guard currentIndex < dishes.count else { return }

        // Check subscription swipe limit
        if !SubscriptionManager.shared.checkSwipe() {
            showPaywall = true
            return
        }

        let dish = dishes[currentIndex]
        handleSwipe(dish, direction: direction)
    }

    // MARK: - Data Access

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

// MARK: - Dish Detail Sheet
struct DishDetailSheet: View {
    let dish: Dish
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image
                    AsyncImage(url: dish.imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Design.Colors.cardBackground)
                        }
                    }
                    .frame(height: 300)
                    .clipped()

                    VStack(alignment: .leading, spacing: Design.Spacing.cardMargin) {
                        // Title
                        Text(dish.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Design.Colors.primaryText)

                        // Cuisine & Calories
                        HStack(spacing: Design.Spacing.standard) {
                            Label(dish.cuisineName, systemImage: "fork.knife")
                                .font(.subheadline)
                                .foregroundColor(Design.Colors.secondaryText)

                            if let calories = dish.calories {
                                Label("\(calories.min)-\(calories.max) \(calories.unit)", systemImage: "flame.fill")
                                    .font(.subheadline)
                                    .foregroundColor(Design.Colors.primary)
                            }
                        }

                        // Recommendation
                        if let recommendation = dish.aiRecommendation {
                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(Design.Colors.primaryText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                                        .fill(Design.Colors.cardBackground)
                                )
                        }

                        // Tags
                        if !dish.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Design.Spacing.element) {
                                    ForEach(dish.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .foregroundColor(Design.Colors.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Design.Colors.primary.opacity(0.12))
                                            )
                                    }
                                }
                            }
                        }

                        // Meta Info
                        if let difficulty = dish.difficulty {
                            metaRow(icon: "chart.bar", label: "难度", value: difficulty)
                        }

                        if let cookTime = dish.cookTime {
                            metaRow(icon: "clock", label: "烹饪时间", value: cookTime)
                        }
                    }
                    .padding(Design.Spacing.screenPadding)
                }
            }
            .background(Design.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Design.Colors.accent)
                }
            }
        }
    }

    private func metaRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Design.Colors.secondaryText)
                .frame(width: 24)

            Text(label)
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Design.Colors.primaryText)
        }
        .padding(.vertical, Design.Spacing.element)
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
