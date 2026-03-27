import SwiftUI

struct LoginPage: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#8B9A6D"))
                
                Text("今天吃什么")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Text("让AI帮你决定今天吃什么")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#86868B"))
            }
            .padding(.bottom, 60)
            
            Spacer()
            
            // Apple Login Button
            Button {
                // Apple Sign In action
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.title3)
                    Text("用 Apple 登录")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Terms
            Text("登录即表示同意《用户协议》和《隐私政策》")
                .font(.caption)
                .foregroundColor(Color(hex: "#86868B"))
                .padding(.bottom, 34)
        }
        .background(Color.white)
    }
}

#Preview {
    LoginPage()
}
