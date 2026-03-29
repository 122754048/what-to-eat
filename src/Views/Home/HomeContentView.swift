import SwiftUI

// MARK: - Home Content View (Featured + Cuisine Grid)
struct HomeContentView: View {
    @State private var featuredDishes: [Dish] = []
    @State private var cuisines: [Cuisine] = []
    @State private var isLoading = false

    private let columns = [
        GridItem(.flexible(), spacing: Design.Spacing.cardMargin),
        GridItem(.flexible(), spacing: Design.Spacing.cardMargin)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Design.Spacing.cardMargin * 2) {
                // Featured Carousel
                if !featuredDishes.isEmpty {
                    featuredSection
                }

                // Cuisine Grid
                if !cuisines.isEmpty {
                    cuisineGridSection
                }

                // Quick Actions
                quickActionsSection
            }
            .padding(.horizontal, Design.Spacing.screenPadding)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadData()
        }
        .onAppear {
            if cuisines.isEmpty {
                loadDataAsync()
            }
        }
    }

    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "Featured", icon: "star.fill", color: Design.Colors.accent)

            TabView {
                ForEach(featuredDishes) { dish in
                    FeaturedDishCard(dish: dish)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 200)
        }
    }

    // MARK: - Cuisine Grid Section
    private var cuisineGridSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "Explore Cuisines", icon: "fork.knife", color: Design.Colors.primary)

            LazyVGrid(columns: columns, spacing: Design.Spacing.cardMargin) {
                ForEach(cuisines.prefix(8)) { cuisine in
                    NavigationLink(destination: CuisineDetailView(cuisine: cuisine)) {
                        CuisineGridCard(cuisine: cuisine)
                    }
                }
            }
        }
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "Quick Access", icon: "bolt.fill", color: Design.Colors.accent)

            HStack(spacing: Design.Spacing.cardMargin) {
                QuickActionButton(
                    icon: "flame.fill",
                    title: "Random Dish",
                    color: Design.Colors.accent
                ) {
                    // Trigger random recommendation
                }

                QuickActionButton(
                    icon: "heart.fill",
                    title: "My Favorites",
                    color: .red
                ) {
                    // Navigate to favorites
                }

                QuickActionButton(
                    icon: "clock.fill",
                    title: "History",
                    color: Design.Colors.primary
                ) {
                    // Navigate to history
                }
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: Design.Spacing.element) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)
        }
    }

    // MARK: - Data Loading
    private func loadDataAsync() {
        Task {
            await loadData()
        }
    }

    private func loadData() async {
        isLoading = true

        do {
            let cuisineList = try await fetchCuisines()
            var featured: [Dish] = []
            for cuisine in cuisineList.prefix(3) {
                let dish = try await fetchRecommendDish(cuisineId: cuisine.id)
                featured.append(dish)
            }

            await MainActor.run {
                cuisines = cuisineList
                featuredDishes = featured
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
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

// MARK: - Featured Dish Card
struct FeaturedDishCard: View {
    let dish: Dish

    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
            .frame(height: 200)
            .clipped()
            .cornerRadius(Design.CornerRadius.card)

            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Info
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text(dish.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: Design.Spacing.element) {
                    Label(dish.cuisineName, systemImage: "fork.knife")
                    if let calories = dish.calories {
                        Label("\(calories.min)-\(calories.max) kcal", systemImage: "flame.fill")
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(Design.Spacing.cardPadding)
        }
    }
}

// MARK: - Cuisine Grid Card
struct CuisineGridCard: View {
    let cuisine: Cuisine

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: cuisine.coverImageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Design.Colors.primary.opacity(0.2))
                }
            }
            .frame(height: 100)
            .clipped()

            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text(cuisine.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                Text("\(cuisine.dishCount)道菜")
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(Design.Spacing.standard)
        }
        .background(Design.Colors.cardBackground)
        .cornerRadius(Design.CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Design.Spacing.element) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(Design.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Design.Spacing.cardPadding)
            .background(Design.Colors.cardBackground)
            .cornerRadius(Design.CornerRadius.card)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
