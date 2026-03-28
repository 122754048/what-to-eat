import SwiftUI

struct HistoryPage: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("历史记录")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            if true { // Empty state for now
                Spacer()
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Design.Colors.primary.opacity(0.3))
                
                Text("暂无历史记录")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .padding(.top, 16)
                
                Text("你浏览过的菜品将显示在这里")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#86868B"))
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        HistoryPage()
    }
}
