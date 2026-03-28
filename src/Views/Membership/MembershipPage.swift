import SwiftUI

struct MembershipPage: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Design.Colors.primary)
                
                Text("升级 Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Design.Colors.primaryText)
                
                Text("解锁无限探索，告别选择困难")
                    .font(.subheadline)
                    .foregroundColor(Design.Colors.secondaryText)
            }
            .padding(.top, 60)
            .padding(.bottom, 32)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Pro Plan
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pro")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Design.Colors.primaryText)
                                Text("$9.9/月 或 $79/年")
                                    .font(.caption)
                                    .foregroundColor(Design.Colors.secondaryText)
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "checkmark.circle.fill", text: "每天 100 次滑动")
                            FeatureRow(icon: "checkmark.circle.fill", text: "口味 DNA")
                            FeatureRow(icon: "checkmark.circle.fill", text: "永久历史记录")
                            FeatureRow(icon: "checkmark.circle.fill", text: "每周报告推送")
                        }
                        
                        Button {
                            // Subscribe Pro
                        } label: {
                            Text("选择 Pro")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Design.Colors.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    
                    // Family Plan
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Family")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Design.Colors.primaryText)
                                Text("$19.9/月 或 $159/年")
                                    .font(.caption)
                                    .foregroundColor(Design.Colors.secondaryText)
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "checkmark.circle.fill", text: "5 人家庭共享")
                            FeatureRow(icon: "checkmark.circle.fill", text: "Pro 全部功能")
                        }
                        
                        Button {
                            // Subscribe Family
                        } label: {
                            Text("选择 Family")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Design.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Design.Colors.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                }
                .padding(.horizontal, 24)
            }
            
            // Guarantee
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("支持 7 天无理由退款")
                    .font(.caption)
            }
            .foregroundColor(Design.Colors.secondaryText)
            .padding(.vertical, 24)
        }
        .background(Design.Colors.cardBackground)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Design.Colors.primary)
                .font(.caption)
            Text(text)
                .font(.body)
                .foregroundColor(Design.Colors.primaryText)
        }
    }
}

#Preview {
    MembershipPage()
}
