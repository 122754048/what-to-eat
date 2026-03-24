import SwiftUI

// MARK: - Design Tokens
enum Design {
    // Colors
    enum Colors {
        static let primary = Color(hex: "#7CB97D")       // 鼠尾草绿
        static let accent = Color(hex: "#F4A261")        // 暖橙色
        static let background = Color(hex: "#FFFFFF")    // 纯白背景
        static let cardBackground = Color(hex: "#F8F8F8") // 极淡灰卡片
        static let primaryText = Color(hex: "#2D2D2D")   // 深灰黑
        static let secondaryText = Color(hex: "#8E8E93")  // 次级灰
        static let border = Color(hex: "#E8E8E8")         // 边框灰
    }

    // Spacing
    enum Spacing {
        static let screenPadding: CGFloat = 20
        static let cardPadding: CGFloat = 16
        static let cardMargin: CGFloat = 16
        static let compact: CGFloat = 4
        static let element: CGFloat = 8
        static let standard: CGFloat = 12
    }

    // Corner Radius
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
    @State private var selectedMood: String? = nil
    @State private var isShowingResult = false
    @State private var recommendedDish: Dish?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let moods = ["辣", "清淡", "肉食", "素食", "随便"]

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

                    // Mood Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Design.Spacing.standard) {
                            ForEach(moods, id: \.self) { mood in
                                MoodButton(
                                    title: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedMood = mood
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Design.Spacing.screenPadding)
                    }

                    Spacer()

                    // Decision Button
                    Button {
                        triggerDecision()
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
                    DishResultSheet(dish: dish, onDismiss: {
                        isShowingResult = false
                    })
                }
            }
        }
    }

    private func triggerDecision() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let dish = try await AIService.shared.decide(mood: selectedMood ?? "随便")
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

// MARK: - Mood Button
struct MoodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Design.Colors.primaryText)
                .padding(.horizontal, Design.Spacing.cardPadding)
                .padding(.vertical, Design.Spacing.standard)
                .background(
                    Capsule()
                        .fill(isSelected ? Design.Colors.primary : Design.Colors.cardBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Design.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
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
