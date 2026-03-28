import SwiftUI

struct DetailPage: View {
    @Environment(\.dismiss) var dismiss
    let dish: Dish

    @State private var showPaywall = false
    @State private var relatedDishes: [Dish] = []

    private let mockRelatedDishes: [Dish] = [
        Dish(id: "related_1", name: "田园沙拉", cuisineId: "healthy_salad", cuisineName: "轻食",
             imageUrl: URL(string: "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400"),
             thumbnailUrl: nil, calories: CalorieRange(min: 250, max: 350, unit: "kcal"),
             aiRecommendation: nil, tags: ["新鲜", "健康"], difficulty: "简单", cookTime: "10分钟"),
        Dish(id: "related_2", name: "鸡胸肉沙拉", cuisineId: "healthy_salad", cuisineName: "轻食",
             imageUrl: URL(string: "https://images.unsplash.com/photo-1534595030-7e2a8d1a1b5a?w=400"),
             thumbnailUrl: nil, calories: CalorieRange(min: 300, max: 400, unit: "kcal"),
             aiRecommendation: nil, tags: ["高蛋白"], difficulty: "简单", cookTime: "15分钟"),
        Dish(id: "related_3", name: "金枪鱼沙拉", cuisineId: "healthy_salad", cuisineName: "轻食",
             imageUrl: URL(string: "https://images.unsplash.com/photo-1551248429-40975aa4de74?w=400"),
             thumbnailUrl: nil, calories: CalorieRange(min: 280, max: 380, unit: "kcal"),
             aiRecommendation: nil, tags: ["低脂"], difficulty: "简单", cookTime: "12分钟")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Hero Image
                AsyncImage(url: dish.imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color(hex: "#F5F5F7"))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .onAppear {
                    relatedDishes = mockRelatedDishes
                }

                // Content
                VStack(alignment: .leading, spacing: 20) {

                    // Title & Rating
                    HStack {
                        Text(dish.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#1A1A1A"))

                        Spacer()
                    }

                    // Cuisine Tag
                    HStack(spacing: 12) {
                        Text(dish.cuisineName)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#86868B"))

                        if let calories = dish.calories {
                            Text("\(calories.min)-\(calories.max) \(calories.unit)")
                                .font(.subheadline)
                                .foregroundColor(Design.Colors.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Design.Colors.primary.opacity(0.15))
                                )
                        }
                    }

                    // AI Recommendation
                    if let recommendation = dish.aiRecommendation {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Color(hex: "#F4A261"))
                                Text("小 AI 推荐")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                            }

                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(Color(hex: "#3A3A3C"))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#F4A261").opacity(0.1))
                        )
                    }

                    // Tags
                    if !dish.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dish.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#1A1A1A"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: "#F5F5F7"))
                                        )
                                }
                            }
                        }
                    }

                    // Meta Info
                    if let difficulty = dish.difficulty {
                        HStack {
                            Label(difficulty, systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                            Spacer()
                        }
                    }

                    if let cookTime = dish.cookTime {
                        HStack {
                            Label(cookTime, systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                            Spacer()
                        }
                    }

                    Divider()

                    // Related Dishes
                    if !relatedDishes.isEmpty {
                        Text("你可能也喜欢")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#1A1A1A"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(relatedDishes) { related in
                                    VStack(alignment: .leading, spacing: 8) {
                                        AsyncImage(url: related.imageUrl) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            default:
                                                Rectangle()
                                                    .fill(Color(hex: "#F5F5F7"))
                                            }
                                        }
                                        .frame(width: 120, height: 90)
                                        .cornerRadius(12)

                                        Text(related.name)
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#1A1A1A"))
                                            .lineLimit(1)

                                        if let cal = related.calories {
                                            Text("\(cal.min) kcal")
                                                .font(.caption2)
                                                .foregroundColor(Color(hex: "#86868B"))
                                        }
                                    }
                                    .frame(width: 120)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .padding(12)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
            }
            .padding(.top, 47)
            .padding(.leading, 16)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("再来一次")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#F5F5F7"))
                        .cornerRadius(12)
                }

                Button {
                    dismiss()
                } label: {
                    Text("去吃！")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Design.Colors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            )
        }
    }
}

#Preview {
    DetailPage(dish: Dish(
        id: "dish_001",
        name: "凯撒沙拉",
        cuisineId: "healthy_salad",
        cuisineName: "轻食主义",
        imageUrl: URL(string: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800"),
        thumbnailUrl: nil,
        calories: CalorieRange(min: 350, max: 450, unit: "kcal"),
        aiRecommendation: "这道沙拉富含膳食纤维和优质蛋白质，搭配清爽的酱汁，非常适合想要保持健康饮食的你。",
        tags: ["高蛋白", "低卡路里"],
        difficulty: "简单",
        cookTime: "15分钟"
    ))
}
