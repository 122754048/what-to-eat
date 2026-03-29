import SwiftUI

struct OnboardingStep3: View {
    var onComplete: () -> Void
    
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
                        .fill(Color(hex: "#8B9A6D"))
                        .frame(width: 10, height: 10)
                }
                Text("3/3")
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
            
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color(hex: "#F5F5F7"))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#8B9A6D"))
            }
            .padding(.bottom, 40)
            
            // Title
            Text("准备就绪！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#1A1A1A"))
                .padding(.bottom, 16)
            
            Text("开始探索美食\n让AI为你做出最佳选择")
                .font(.body)
                .foregroundColor(Color(hex: "#86868B"))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Bottom Button
            VStack {
                Button {
                    onComplete()
                } label: {
                    Text("开始使用")
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
    OnboardingStep3(onComplete: {})
}
