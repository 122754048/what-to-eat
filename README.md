# 「吃什么」- What to Eat App

## 产品定位
解决"今天吃什么"选择困难的 iOS App，通过 AI 随机生成个性化菜单。

## 核心功能
- 🎰 **随便决定器**：随机推荐一道美食
- 🍜 **菜系探索**：浏览不同菜系，随机推荐菜品
- 🥗 **健康模式**：根据健康目标推荐合适菜品

## 技术栈
- **前端**：SwiftUI (iOS 18+)
- **后端**：Cloudflare Workers + Hono + TypeScript
- **AI**：Cloudflare Workers AI (Llama 3.1 8B)
- **数据**：Cloudflare D1 + KV

## 项目结构
```
what-to-eat/
├── src/
│   ├── App/
│   │   └── WhatToEatApp.swift       # App 入口
│   ├── Views/
│   │   ├── Home/HomeView.swift       # 首页 - 随便决定器
│   │   ├── Explore/ExploreView.swift  # 探索页 - 菜系浏览
│   │   └── Health/HealthView.swift   # 健康页 - 健康推荐
│   ├── Services/
│   │   ├── APIService.swift          # 真实 API 调用
│   │   ├── AIService.swift           # Cloudflare AI 调用
│   │   └── MockAPIService.swift     # Mock 数据（演示用）
│   ├── Models/
│   │   └── Dish.swift                # 数据模型
│   └── Utils/
│       ├── Constants.swift            # 常量定义
│       └── Design.swift              # 设计系统
├── project.yml                       # XcodeGen 配置
└── WhatToEat.xcodeproj/             # Xcode 项目文件
```

## 如何运行

### 前置条件
- Xcode 15+
- XcodeGen (`brew install xcodegen`)
- iOS 18+ 模拟器或真机

### 编译步骤
```bash
# 1. 进入项目目录
cd shared-projects/what-to-eat

# 2. 生成 Xcode 项目
xcodegen generate

# 3. 用 Xcode 打开
open WhatToEat.xcodeproj

# 4. 在 Xcode 中选择 iOS 18+ 模拟器，点击运行
```

### API 模式切换
在 `APIService.swift` 中修改：
```swift
enum APIConfig {
    static let useMock = true  // true = 使用 Mock 数据（无需后端）
    // static let useMock = false // false = 使用真实后端
}
```

### 后端 API 地址
- **开发环境**：`http://localhost:8787/api/v1`
- **生产环境**：`https://what-to-eat.{account}.workers.dev/api/v1`

## 设计规范
- 色彩：鼠尾草绿 `#7CB97D` + 暖橙 `#F4A261`
- 字体：SF Pro 语义化（`.largeTitle` / `.title` 等）
- 间距：20pt 屏幕边距，16pt 卡片间距
- 圆角：20pt 卡片，12pt 按钮
- 动效：Spring 弹性回弹，scale(0.96) 点击反馈

## API 接口
| 接口 | 方法 | 说明 |
|---|---|---|
| `/cuisines` | GET | 获取菜系列表 |
| `/cuisines/{id}/recommend` | POST | 随机推荐菜品 |
| `/dishes/{id}` | GET | 获取菜品详情 |
| `/history` | GET | 获取推荐历史 |
| `/history/{id}/feedback` | POST | 提交反馈 |

## 项目状态
🚧 开发中

## GitHub
https://github.com/122754048/what-to-eat
