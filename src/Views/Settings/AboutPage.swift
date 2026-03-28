import SwiftUI

struct AboutPage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Design.Colors.primary)
                    
                    Text("吃什么")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#86868B"))
                }
                .padding(.top, 40)
                .padding(.bottom, 24)
                
                // Info List
                VStack(spacing: 0) {
                    InfoRow(title: "开发商", value: "WhatToEat Team")
                    Divider()
                    InfoRow(title: "联系方式", value: "support@chishenme.app")
                    Divider()
                    InfoRow(title: "官方网站", value: "www.chishenme.app")
                    Divider()
                    NavigationLink(destination: PrivacyPage()) {
                        HStack {
                            Text("用户协议")
                                .font(.body)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "#C7C7CC"))
                        }
                        .padding(.vertical, 16)
                    }
                    Divider()
                    NavigationLink(destination: PrivacyPage()) {
                        HStack {
                            Text("隐私政策")
                                .font(.body)
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "#C7C7CC"))
                        }
                        .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(16)
                
                // Footer
                Text("© 2024 WhatToEat Team. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#C7C7CC"))
                    .padding(.top, 24)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(hex: "#F5F5F7"))
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color(hex: "#1A1A1A"))
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(Color(hex: "#86868B"))
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        AboutPage()
    }
}
