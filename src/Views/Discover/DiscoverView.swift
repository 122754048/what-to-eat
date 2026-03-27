<<<<<<< HEAD
import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    
    let cuisines = [
        ("川菜", "🌶️", "辣"),
        ("粤菜", "🥮", "清淡"),
        ("湘菜", "🔥", "酸辣"),
        ("鲁菜", "🥬", "鲜香"),
        ("苏菜", "🍳", "清淡"),
        ("浙菜", "🦐", "鲜甜"),
        ("闽菜", "🦑", "鲜香"),
        ("徽菜", "🍄", "原汁原味")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("发现")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#86868B"))
                    
                    TextField("搜索菜品或菜系", text: $searchText)
                        .font(.body)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "#C7C7CC"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "#F5F5F7"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Cuisine Categories
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("菜系分类")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .padding(.horizontal, 24)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(filteredCuisines, id: \.0) { cuisine in
                            DiscoverCuisineCard(name: cuisine.0, emoji: cuisine.1, tag: cuisine.2)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .background(Color.white)
    }
    
    var filteredCuisines: [(String, String, String)] {
        if searchText.isEmpty {
            return cuisines
        }
        return cuisines.filter { cuisine in
            cuisine.0.contains(searchText) || cuisine.2.contains(searchText)
        }
    }
}

struct DiscoverCuisineCard: View {
    let name: String
    let emoji: String
    let tag: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(emoji)
                .font(.system(size: 40))
                .padding(.top, 16)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Text(tag)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#86868B"))
            }
            .padding(.bottom, 16)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#F5F5F7"))
        .cornerRadius(16)
    }
}

#Preview {
    DiscoverView()
}
||||||| merged common ancestors
=======
import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var featuredDishes: [Dish] = []
    @State private var seasonalDishes: [Dish] = []
    @State private var newDishes: [Dish] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Design.Spacing.cardMargin * 1.5) {
                        // Search Bar
                        searchBar

                        if isLoading {
                            ProgressView()
                                .frame(height: 200)
                        } else {
                            // 🔥 Hot This Week
                            if !featuredDishes.isEmpty {
                                hotSection
                            }

                            // 🍃 Seasonal
                            if !seasonalDishes.isEmpty {
                                seasonalSection
                            }

                            // ✨ New Dishes
                            if !newDishes.isEmpty {
                                newSection
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("发现")
            .onAppear {
                loadData()
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: Design.Spacing.element) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Design.Colors.secondaryText)

            TextField("搜索菜品或菜系", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Design.Colors.secondaryText)
                }
            }
        }
        .padding(Design.Spacing.standard)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                .fill(Design.Colors.cardBackground)
        )
        .padding(.horizontal, Design.Spacing.screenPadding)
        .padding(.top, Design.Spacing.standard)
    }

    // MARK: - Hot Section
    private var hotSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "本周热门", icon: "flame.fill", color: Design.Colors.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.cardMargin) {
                    ForEach(featuredDishes) { dish in
                        NavigationLink(destination: DishDetailSheet(dish: dish)) {
                            DiscoverCardH(dish: dish, tag: "热门", tagColor: Design.Colors.accent)
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Seasonal Section
    private var seasonalSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "应季推荐", icon: "leaf.fill", color: Design.Colors.primary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Design.Spacing.cardMargin),
                GridItem(.flexible(), spacing: Design.Spacing.cardMargin)
            ], spacing: Design.Spacing.cardMargin) {
                ForEach(seasonalDishes.prefix(4)) { dish in
                    NavigationLink(destination: DishDetailSheet(dish: dish)) {
                        DiscoverCardV(dish: dish, tag: "应季", tagColor: Design.Colors.primary)
                    }
                }
            }
            .padding(.horizontal, Design.Spacing.screenPadding)
        }
    }

    // MARK: - New Section
    private var newSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            sectionHeader(title: "新菜上架", icon: "sparkles", color: Design.Colors.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.cardMargin) {
                    ForEach(newDishes) { dish in
                        NavigationLink(destination: DishDetailSheet(dish: dish)) {
                            DiscoverCardH(dish: dish, tag: "新品", tagColor: Design.Colors.accent)
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Design.Colors.primaryText)

            Spacer()

            Button {
                // Navigate to full list
            } label: {
                Text("查看更多")
                    .font(.subheadline)
                    .foregroundColor(Design.Colors.secondaryText)
            }
        }
        .padding(.horizontal, Design.Spacing.screenPadding)
    }

    // MARK: - Data Loading
    private func loadData() {
        isLoading = true

        Task {
            do {
                let cuisines = try await fetchCuisines()
                var featured: [Dish] = []
                var seasonal: [Dish] = []
                var newDishList: [Dish] = []

                for cuisine in cuisines.prefix(3) {
                    let dish = try await fetchRecommendDish(cuisineId: cuisine.id)
                    featured.append(dish)
                }

                for cuisine in cuisines.suffix(2) {
                    let dish = try await fetchRecommendDish(cuisineId: cuisine.id)
                    seasonal.append(dish)
                }

                for cuisine in cuisines.prefix(2) {
                    let dish = try await fetchRecommendDish(cuisineId: cuisine.id)
                    newDishList.append(dish)
                }

                await MainActor.run {
                    featuredDishes = featured
                    seasonalDishes = seasonal
                    newDishes = newDishList
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
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

// MARK: - Discover Card (Horizontal)
struct DiscoverCardH: View {
    let dish: Dish
    let tag: String
    let tagColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
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
                .frame(width: 140, height: 100)
                .clipped()

                Text(tag)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tagColor)
                    .cornerRadius(4)
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(dish.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                if let calories = dish.calories {
                    Text("\(calories.min) kcal")
                        .font(.caption2)
                        .foregroundColor(Design.Colors.secondaryText)
                }
            }
            .padding(Design.Spacing.element)
            .frame(width: 140, alignment: .leading)
        }
        .background(Design.Colors.cardBackground)
        .cornerRadius(Design.CornerRadius.button)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Discover Card (Vertical)
struct DiscoverCardV: View {
    let dish: Dish
    let tag: String
    let tagColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
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
                .frame(height: 120)
                .clipped()

                Text(tag)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tagColor)
                    .cornerRadius(4)
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                HStack {
                    if let calories = dish.calories {
                        Text("\(calories.min) kcal")
                            .font(.caption)
                            .foregroundColor(Design.Colors.secondaryText)
                    }

                    Spacer()

                    Text(dish.cuisineName)
                        .font(.caption)
                        .foregroundColor(tagColor)
                }
            }
            .padding(Design.Spacing.standard)
        }
        .background(Design.Colors.cardBackground)
        .cornerRadius(Design.CornerRadius.button)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
>>>>>>> feat: add DiscoverView, ProfileView, HistoryView; set useMock=true for demo
