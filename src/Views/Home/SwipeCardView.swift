import SwiftUI

// MARK: - Swipe Card View
struct SwipeCardView: View {
    let dish: Dish
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let onSwipeUp: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isDragging = false

    // Thresholds
    private let swipeThreshold: CGFloat = 100
    private let rotationDegrees: CGFloat = 15

    // MARK: - Computed Properties

    private var rotation: Double {
        Double(offset.width / 20)
    }

    private var cardOpacity: Double {
        let progress = abs(offset.width) / swipeThreshold
        return 1 - (progress * 0.3).clamped(to: 0...0.7)
    }

    private var indicatorOpacity: Double {
        let progress = abs(offset.width) / swipeThreshold
        return progress.clamped(to: 0...1)
    }

    var body: some View {
        ZStack {
            // Background Image
            AsyncImage(url: dish.imageUrl) { phase in
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
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(Design.Colors.secondaryText)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            // Gradient Overlay
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)

                // Info Section
                VStack(alignment: .leading, spacing: Design.Spacing.element) {
                    Text(dish.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack(spacing: Design.Spacing.standard) {
                        Label(dish.cuisineName, systemImage: "fork.knife")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))

                        if let calories = dish.calories {
                            Label("\(calories.min)-\(calories.max) \(calories.unit)", systemImage: "flame.fill")
                                .font(.caption)
                                .foregroundColor(Design.Colors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.2))
                                )
                        }
                    }

                    if let recommendation = dish.aiRecommendation {
                        Text(recommendation)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }

                    // Tags
                    if !dish.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Design.Spacing.element) {
                                ForEach(dish.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.2))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(Design.Spacing.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Swipe Indicators
            HStack {
                // Left - Nope
                Image(systemName: "xmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                    .background(Circle().fill(.white).padding(8))
                    .opacity(offset.width < -20 ? indicatorOpacity * 3 : 0)
                    .scaleEffect(offset.width < -20 ? 1 : 0.5)

                Spacer()

                // Right - Like
                Image(systemName: "heart.fill")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()
                    .background(Circle().fill(.white).padding(8))
                    .opacity(offset.width > 20 ? indicatorOpacity * 3 : 0)
                    .scaleEffect(offset.width > 20 ? 1 : 0.5)
            }
            .padding(.horizontal, Design.Spacing.cardMargin)
            .padding(.top, 60)

            // Up - Super Like
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding()
                    .background(Circle().fill(.white).padding(6))
                    .opacity(offset.height < -20 ? indicatorOpacity * 3 : 0)
                    .scaleEffect(offset.height < -20 ? 1 : 0.5)

                Spacer()
            }
            .padding(.top, 100)
        }
        .frame(width: 320, height: 480)
        .clipShape(RoundedRectangle(cornerRadius: Design.CornerRadius.card))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .opacity(cardOpacity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    offset = value.translation
                }
                .onEnded { value in
                    isDragging = false
                    handleSwipeEnd(value.translation)
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDragging)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset == .zero)
    }

    private func handleSwipeEnd(_ translation: CGSize) {
        let horizontalAmount = translation.width
        let verticalAmount = translation.height

        if abs(horizontalAmount) > abs(verticalAmount) {
            // Horizontal swipe
            if horizontalAmount > swipeThreshold {
                // Swipe right - Like
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = CGSize(width: 500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeRight()
                    offset = .zero
                }
            } else if horizontalAmount < -swipeThreshold {
                // Swipe left - Nope
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = CGSize(width: -500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeLeft()
                    offset = .zero
                }
            } else {
                // Return to center
                offset = .zero
            }
        } else {
            // Vertical swipe
            if verticalAmount < -swipeThreshold {
                // Swipe up - Super Like
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = CGSize(width: 0, height: -600)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipeUp()
                    offset = .zero
                }
            } else {
                // Return to center
                offset = .zero
            }
        }
    }
}

// MARK: - Card Stack View
struct CardStackView: View {
    let dishes: [Dish]
    let onSwipeLeft: (Dish) -> Void
    let onSwipeRight: (Dish) -> Void
    let onSwipeUp: (Dish) -> Void

    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            ForEach(visibleDishes.reversed()) { dish in
                SwipeCardView(
                    dish: dish,
                    onSwipeLeft: { onSwipeLeft(dish) },
                    onSwipeRight: { onSwipeRight(dish) },
                    onSwipeUp: { onSwipeUp(dish) }
                )
                .zIndex(zIndex(for: dish))
            }
        }
    }

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
}

// MARK: - Double Extension
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
