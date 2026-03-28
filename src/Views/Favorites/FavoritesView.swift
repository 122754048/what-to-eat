import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: Design.Spacing.element),
                        GridItem(.flexible(), spacing: Design.Spacing.element)
                    ], spacing: Design.Spacing.element) {
                        ForEach(0..<6) { index in
                            FavoriteCard(index: index)
                        }
                    }
                    .padding(.horizontal, Design.Spacing.screenPadding)
                    .padding(.top, Design.Spacing.standard)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("收藏")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FavoriteCard: View {
    let index: Int

    private var dishName: String {
        ["麻婆豆腐", "白切鸡", "糖醋里脊", "宫保鸡丁", "清蒸鲈鱼", "红烧肉"][index % 6]
    }

    private var cuisineName: String {
        ["川菜", "粤菜", "鲁菜", "川菜", "浙菜", "湘菜"][index % 6]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Design.Colors.cardBackground)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(Design.Colors.secondaryText)
                )
                .cornerRadius(Design.CornerRadius.button, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                Text(dishName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Design.Colors.primaryText)
                    .lineLimit(1)

                Text(cuisineName)
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(Design.Spacing.element)
        }
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Design.Colors.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    FavoritesView()
}
