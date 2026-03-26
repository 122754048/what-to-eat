import SwiftUI

struct ExploreView: View {
    @State private var cuisines: [Cuisine] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    VStack(spacing: Design.Spacing.cardMargin) {
                        Image(systemName: "wifi.slash")
                            .font(.largeTitle)
                            .foregroundColor(Design.Colors.secondaryText)
                        Text(error)
                            .font(.body)
                            .foregroundColor(Design.Colors.secondaryText)
                        Button("重试") {
                            loadCuisines()
                        }
                        .foregroundColor(Design.Colors.accent)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Design.Spacing.cardMargin),
                            GridItem(.flexible(), spacing: Design.Spacing.cardMargin)
                        ], spacing: Design.Spacing.cardMargin) {
                            ForEach(cuisines) { cuisine in
                                NavigationLink(destination: CuisineDetailView(cuisine: cuisine)) {
                                    CuisineCard(cuisine: cuisine)
                                }
                            }
                        }
                        .padding(Design.Spacing.screenPadding)
                    }
                    .refreshable {
                        await refreshCuisines()
                    }
                }
            }
            .navigationTitle("探索菜系")
            .onAppear {
                if cuisines.isEmpty {
                    loadCuisines()
                }
            }
        }
    }

    private func loadCuisines() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await fetchCuisines()
                await MainActor.run {
                    cuisines = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func refreshCuisines() async {
        do {
            let result = try await fetchCuisines()
            await MainActor.run {
                cuisines = result
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Cuisine Card
struct CuisineCard: View {
    let cuisine: Cuisine

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            AsyncImage(url: cuisine.coverImageUrl) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundColor(Design.Colors.secondaryText)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                }
            }
            .frame(height: 120)
            .clipped()

            // Info
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text(cuisine.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                Text("\(cuisine.dishCount) 道菜")
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(Design.Spacing.standard)
        }
        .background(Design.Colors.cardBackground)
        .cornerRadius(Design.CornerRadius.card)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

// MARK: - Cuisine Detail View
struct CuisineDetailView: View {
    let cuisine: Cuisine
    @State private var recommendedDish: Dish?
    @State private var isLoading = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            Design.Colors.background
                .ignoresSafeArea()

            VStack(spacing: Design.Spacing.cardMargin) {
                // Header Image
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
                .frame(height: 200)
                .clipped()

                // Cuisine Info
                VStack(alignment: .leading, spacing: Design.Spacing.standard) {
                    Text(cuisine.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Design.Colors.primaryText)

                    Text("\(cuisine.dishCount) 道菜可选")
                        .font(.body)
                        .foregroundColor(Design.Colors.secondaryText)

                    if !cuisine.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Design.Spacing.element) {
                                ForEach(cuisine.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(Design.Colors.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Design.Colors.primary.opacity(0.12))
                                        )
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Design.Spacing.screenPadding)

                Spacer()

                // Recommend Button
                Button {
                    recommendRandomDish()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("随机一道")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Design.Spacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                            .fill(Design.Colors.accent)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isLoading)
                .padding(.horizontal, Design.Spacing.screenPadding)
                .padding(.bottom, Design.Spacing.cardMargin)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResult) {
            if let dish = recommendedDish {
                DishResultSheet(dish: dish) {
                    showResult = false
                }
            }
        }
    }

    private func recommendRandomDish() {
        isLoading = true
        Task {
            do {
                let dish = try await fetchRecommendDish(cuisineId: cuisine.id)
                await MainActor.run {
                    recommendedDish = dish
                    isLoading = false
                    showResult = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
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
