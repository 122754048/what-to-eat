import SwiftUI

struct MyProfilePage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(Color(hex: "#F5F5F7"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#8B9A6D"))
                        )
                    
                    Text("小明")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                        Text("Premium会员")
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: "#8B9A6D"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#8B9A6D").opacity(0.15))
                    .cornerRadius(20)
                }
                .padding(.top, 24)
                
                // Member Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Premium 会员")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            Text("到期: 2026-12-31")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#86868B"))
                        }
                        Spacer()
                        Button {
                            // Renew
                        } label: {
                            Text("续费")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "#8B9A6D"))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#8B9A6D"), Color(hex: "#A8B88A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal, 16)
                
                // Menu List
                VStack(spacing: 0) {
                    MenuRow(icon: "heart.fill", iconColor: Color(hex: "#FF6B6B"), title: "我的收藏")
                    Divider().padding(.leading, 56)
                    MenuRow(icon: "clock.fill", iconColor: Color(hex: "#4ECDC4"), title: "历史记录")
                    Divider().padding(.leading, 56)
                    MenuRow(icon: "gearshape.fill", iconColor: Color(hex: "#86868B"), title: "设置")
                    Divider().padding(.leading, 56)
                    MenuRow(icon: "questionmark.circle.fill", iconColor: Color(hex: "#8B9A6D"), title: "帮助与反馈")
                }
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 16)
                
                // Logout Button
                Button {
                    // Logout action
                } label: {
                    Text("退出登录")
                        .font(.body)
                        .foregroundColor(Color(hex: "#FF3B30"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .background(Color(hex: "#F5F5F7"))
    }
}

struct MenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15))
                .cornerRadius(10)
            
            Text(title)
                .font(.body)
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(hex: "#C7C7CC"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    MyProfilePage()
}
