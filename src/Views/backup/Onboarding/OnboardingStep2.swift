import SwiftUI

struct OnboardingStep2: View {
    var onComplete: () -> Void
    @State private var selectedCuisines: Set<String> = []
    
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
            // Status Bar Height Spacer
            Color.clear.frame(height: 47)
            
            // Progress Indicator
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#8B9A6D"))
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Color(hex: "#8B9A6D"))
                        .frame(width: 10, height: 10)
                    Circle()
                        .stroke(Color(hex: "#CCCCCC"), lineWidth: 2)
                        .frame(width: 10, height: 10)
                }
                Text("2/3")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#86868B"))
            }
            .padding(.top, 32)
            
            // Skip Button
            HStack {
                Spacer()
                Button("跳过") {
                    onComplete()
                }
                .font(.body)
                .foregroundColor(Color(hex: "#999999"))
                .padding(.trailing, 24)
            }
            .padding(.top, 16)
            
            // Title
            VStack(spacing: 8) {
                Text("选择你的口味")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Text("可多选，我们会为你推荐更合适的菜品")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#86868B"))
            }
            .padding(.top, 32)
            .padding(.bottom, 32)
            
            // Cuisine Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(cuisines, id: \.0) { cuisine in
                    VStack(spacing: 8) {
                        Text(cuisine.1)
                            .font(.system(size: 32))
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedCuisines.contains(cuisine.0) 
                                          ? Color(hex: "#8B9A6D").opacity(0.15) 
                                          : Color(hex: "#F5F5F7"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedCuisines.contains(cuisine.0) 
                                            ? Color(hex: "#8B9A6D") 
                                            : Color.clear, lineWidth: 2)
                            )
                        
                        Text(cuisine.0)
                            .font(.caption)
                            .foregroundColor(selectedCuisines.contains(cuisine.0) 
                                            ? Color(hex: "#8B9A6D") 
                                            : Color(hex: "#1A1A1A"))
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if selectedCuisines.contains(cuisine.0) {
                                selectedCuisines.remove(cuisine.0)
                            } else {
                                selectedCuisines.insert(cuisine.0)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom Button
            VStack {
                Button {
                    onComplete()
                } label: {
                    Text("下一步")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#8B9A6D"))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(Color.white)
    }
}

#Preview {
    OnboardingStep2(onComplete: {})
}
