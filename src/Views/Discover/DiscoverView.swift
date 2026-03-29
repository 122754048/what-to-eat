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
