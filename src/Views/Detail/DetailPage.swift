import SwiftUI

struct DetailPage: View {
    let dish: Dish
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
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
                .frame(height: 320)
                .clipped()
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dish.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            
                            HStack(spacing: 8) {
                                Text(dish.cuisineName)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#86868B"))
                                
                                ForEach(Array(dish.rating), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#F4A261"))
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    // AI Recommendation
                    if let recommendation = dish.aiRecommendation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("推荐理由")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                            
                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                                .lineSpacing(6)
                        }
                    }
                    
                    // Calories
                    if let calories = dish.calories {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("热量")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                            
                            HStack(spacing: 8) {
                                Text("\(calories.min)-\(calories.max)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                                Text(calories.unit)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#86868B"))
                            }
                        }
                    }
                    
                    // Tags
                    if !dish.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标签")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                            
                            FlowLayout(spacing: 8) {
                                ForEach(dish.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#8B9A6D"))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#8B9A6D").opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // Paired Dishes
                    if !dish.pairedDishes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("配菜推荐")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(dish.pairedDishes) { pairedDish in
                                        VStack(alignment: .leading, spacing: 8) {
                                            AsyncImage(url: pairedDish.imageUrl) { phase in
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
                                            
                                            Text(pairedDish.name)
                                                .font(.caption)
                                                .foregroundColor(Color(hex: "#1A1A1A"))
                                            
                                            if let cal = pairedDish.calories {
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
                    // Retry
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
                    // Go eat
                } label: {
                    Text("去吃！")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#F4A261"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .background(Color.white)
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    DetailPage(dish: Dish(
        id: "1",
        name: "凯撒沙拉",
        cuisineName: "轻食主义",
        imageUrl: URL(string: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800"),
        rating: 5,
        calories: CaloriesInfo(min: 350, max: 450, unit: "kcal"),
        tags: ["高蛋白", "低卡路里"],
        aiRecommendation: "这道沙拉富含膳食纤维和优质蛋白质，搭配清爽的酱汁，非常适合想要保持健康饮食的你。",
        pairedDishes: [],
        pairedDrinks: []
    ))
}
