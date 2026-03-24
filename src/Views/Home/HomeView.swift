import SwiftUI

// MARK: - Design Tokens
enum Design {
    // Colors
    enum Colors {
        static let primary = Color(hex: "#7CB97D")       // 鼠尾草绿
        static let accent = Color(hex: "#F4A261")      // 暖橙色
        static let background = Color(hex: "#FFFFFF")   // 纯白背景
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
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Home View
struct HomeView: View {
    @State private var selectedCuisineId: String? = nil
    @State private var isShowingResult = false
    @State private var recommendedDish: Dish?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: Design.Spacing.cardMargin) {
                    // Title
                    Text("今天吃什么？")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Design.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Design.Spacing.screenPadding)

                    Text("随机一道美食，开启美味之旅")
                        .font(.subheadline)
                        .foregroundColor(Design.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    // Decision Button
                    Button {
                        triggerRandomDecision()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Design.Colors.accent)
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("随机\n一道")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(isLoading)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, Design.Spacing.screenPadding)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingResult) {
                if let dish = recommendedDish {
                    DishResultSheet(dish: dish) {
                        isShowingResult = false
                    }
                }
            }
        }
    }

    private func triggerRandomDecision() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // V1: Random cuisine recommendation
                // TODO: In future, pick a random cuisineId first, or let user pick
                // For now, we need at least one cuisine to call recommend
                let cuisines = try await APIService.shared.getCuisines()
                guard let randomCuisine = cuisines.randomElement() else {
                    throw APIError.serverError(code: 50001, message: "暂无菜系数据")
                }

                let dish = try await APIService.shared.recommendDish(cuisineId: randomCuisine.id)
                await MainActor.run {
                    recommendedDish = dish
                    isLoading = false
                    isShowingResult = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Dish Result Sheet
struct DishResultSheet: View {
    let dish: Dish
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, Design.Spacing.standard)

            ScrollView {
                VStack(spacing: Design.Spacing.cardMargin) {
                    // Food Image
                    AsyncImage(url: dish.imageUrl) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .clipped()
                    .cornerRadius(Design.CornerRadius.card)

                    // Dish Info
                    VStack(alignment: .leading, spacing: Design.Spacing.standard) {
                        Text(dish.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Design.Colors.primaryText)

                        HStack(spacing: Design.Spacing.element) {
                            Text(dish.cuisineName)
                                .font(.subheadline)
                                .foregroundColor(Design.Colors.secondaryText)

                            if let calories = dish.calories {
                                Text("\(calories.min)-\(calories.max) \(calories.unit)")
                                    .font(.caption)
                                    .foregroundColor(Design.Colors.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Design.Colors.primary.opacity(0.12))
                                    )
                            }
                        }

                        if let recommendation = dish.aiRecommendation {
                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(Design.Colors.secondaryText)
                                .padding(.top, Design.Spacing.element)
                        }

                        // Tags
                        if !dish.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Design.Spacing.element) {
                                    ForEach(dish.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .foregroundColor(Design.Colors.primaryText)
                                            .padding(.horizontal, Design.Spacing.standard)
                                            .padding(.vertical, Design.Spacing.compact)
                                            .background(
                                                RoundedRectangle(cornerRadius: Design.CornerRadius.tag)
                                                    .fill(Design.Colors.cardBackground)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Design.CornerRadius.tag)
                                                    .stroke(Design.Colors.border, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.top, Design.Spacing.element)
                        }

                        // Action Buttons
                        HStack(spacing: Design.Spacing.standard) {
                            Button {
                                onDismiss()
                            } label: {
                                Text("再试一次")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Design.Colors.accent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Design.Spacing.cardPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: Design.CornerRadius.button)
                                            .stroke(Design.Colors.accent, lineWidth: 1.5)
                                    )
                            }

                            Button {
                                // TODO: Navigate to detail
                            } label: {
                                Text("查看详情")
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
                        }
                        .padding(.top, Design.Spacing.cardMargin)
                    }
                    .padding(.horizontal, Design.Spacing.screenPadding)
                }
                .padding(.bottom, Design.Spacing.cardMargin)
            }
        }
        .background(Design.Colors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
