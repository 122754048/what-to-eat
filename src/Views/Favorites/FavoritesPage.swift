import SwiftUI

struct FavoritesPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "#8B9A6D").opacity(0.3))
            
            Text("还没有收藏")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            Text("滑动卡片时点击心形按钮\n即可收藏你喜欢的菜品")
                .font(.subheadline)
                .foregroundColor(Color(hex: "#86868B"))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .navigationTitle("我的收藏")
    }
}

#Preview {
    NavigationStack {
        FavoritesPage()
    }
}
