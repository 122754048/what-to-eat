import SwiftUI

// MARK: - Design Tokens (ChiShenMe v2.0)
enum Design {
    enum Colors {
        /// 主色 - 鼠尾草绿
        static let primary = Color(hex: "#7CB97D")
        /// 暖橙色 - CTA 按钮
        static let accent = Color(hex: "#F4A261")
        /// 页面主背景
        static let background = Color(hex: "#FFFFFF")
        /// 卡片背景
        static let cardBackground = Color(hex: "#F5F5F7")
        /// 主文字
        static let primaryText = Color(hex: "#1D1D1F")
        /// 次文字
        static let secondaryText = Color(hex: "#86868B")
        /// 分割线/边框
        static let border = Color(hex: "#E5E5EA")
        /// Tab Bar 激活色
        static let tabActive = Color(hex: "#7CB97D")
        /// Tab Bar 未激活
        static let tabInactive = Color(hex: "#86868B")
    }

    enum Spacing {
        /// 屏幕边距
        static let screenPadding: CGFloat = 24
        /// 卡片内边距
        static let cardPadding: CGFloat = 24
        /// 区块间距
        static let cardMargin: CGFloat = 32
        /// 元素间距 - 紧密
        static let compact: CGFloat = 8
        /// 元素间距 - 标准
        static let element: CGFloat = 16
        /// 元素间距 - 宽松
        static let standard: CGFloat = 24
    }

    enum CornerRadius {
        /// 卡片圆角
        static let card: CGFloat = 20
        /// 按钮圆角
        static let button: CGFloat = 16
        /// 标签圆角
        static let tag: CGFloat = 20
    }

    enum FontSize {
        static let largeTitle: CGFloat = 34
        static let pageTitle: CGFloat = 28
        static let cardTitle: CGFloat = 24
        static let body: CGFloat = 17
        static let caption: CGFloat = 15
        static let tag: CGFloat = 12
        static let tab: CGFloat = 10
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
