import SwiftUI

struct CuisineSelectionPage: View {
    @State private var selectedCuisine: String? = nil
    
    let cuisines = [
        ("中餐", "🍜"),
        ("日料", "🍣"),
        ("韩餐", "🥘"),
        ("泰餐", "🍛"),
        ("意餐", "🍕"),
        ("法餐", "🥐"),
        ("美式", "🍔"),
        ("印度", "🍛")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("探索菜系")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Text("选择你今天想吃的菜系")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#86868B"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Cuisine Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(cuisines, id: \.0) { cuisine in
                    CuisineCard(
                        name: cuisine.0,
                        emoji: cuisine.1,
                        isSelected: selectedCuisine == cuisine.0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCuisine = cuisine.0
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom Button
            Button {
                // Random dish action
            } label: {
                if let selected = selectedCuisine {
                    Text("随机一道\(selected)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#F4A261"))
                        .cornerRadius(16)
                } else {
                    Text("随机一道")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#CCCCCC"))
                        .cornerRadius(16)
                }
            }
            .disabled(selectedCuisine == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(Color.white)
    }
}

struct CuisineCard: View {
    let name: String
    let emoji: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Text(emoji)
                    .font(.system(size: 48))
                    .padding(.top, 24)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
                .padding(.bottom, 20)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Design.Colors.primary : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    CuisineSelectionPage()
}
