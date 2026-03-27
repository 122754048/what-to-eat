import SwiftUI

struct PrivacyPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("隐私政策")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .padding(.top, 16)
                
                Text("生效日期: 2024-01-01")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#86868B"))
                
                Group {
                    Text("1. 信息收集")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("我们收集您在使用「吃什么」服务时主动提供的信息，包括但不限于：手机号码、头像、昵称、饮食偏好、健康目标等。")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                    
                    Text("2. 信息使用")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("我们使用收集的信息用于：提供个性化的餐饮推荐服务、优化AI算法准确性、保护账号安全、以及改进产品功能。")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                    
                    Text("3. 信息共享")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("未经您的同意，我们不会与任何第三方共享您的个人信息，法律法规要求的除外。")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                    
                    Text("4. 信息安全")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("我们采用行业标准的安全措施保护您的个人信息，防止数据遭到未经授权的访问、使用或泄露。")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                    
                    Text("5. 您的权利")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("您有权随时查看、修改或删除您的个人账户信息。您可以联系我们的客服团队行使这些权利。")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                    
                    Text("6. 联系我们")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Text("如您对本隐私政策有任何疑问，请通过以下方式联系我们：support@chishenme.app")
                        .font(.body)
                        .foregroundColor(Color(hex: "#4A4A4A"))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPage()
    }
}
