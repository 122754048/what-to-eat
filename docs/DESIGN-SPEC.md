# 设计规范 - 「吃什么」(What to Eat)

## 1. 设计理念

**核心原则**: 对标 Apple 原生 App 设计水准，严格遵循 Apple HIG（Human Interface Guidelines）。

**三大原则**（Apple HIG 核心）：
- **Clarity（清晰）**: 文字易读，图标识清晰，无视觉噪音
- **Deference（克制）**: 界面服务于内容，UI 元素不应抢夺食物图片的注意力
- **Depth（层次）**: 合理利用毛玻璃、阴影、层次感，让界面有呼吸感

**设计参考**：
- Apple 原生 App（Health / Fitness / Books）
- 高质量 iOS 第三方 App（Headspace / Notion / Things 3）
- 大量留白，食物图片作为绝对视觉核心
- 毛玻璃效果用于底部 Tab Bar 和弹窗

---

## 2. 色彩系统

**Apple HIG 色彩规范**：
- 使用系统语义色（Semantic Colors），支持 Light/Dark Mode 自动切换
- 深色模式使用 `systemBackground` / `secondarySystemBackground` 等

| 用途 | 系统色（Light模式） | Hex | Dark模式 Hex |
|---|---|---|---|
| 主背景 | systemBackground | `#FFFFFF` | `#000000` |
| 卡片背景 | secondarySystemBackground | `#F2F2F7` | `#1C1C1E` |
| 分组背景 | tertiarySystemBackground | `#FFFFFF` | `#2C2C2E` |
| 主色（强调） | systemGreen | `#34C759` | `#30D158` |
| 次要文字 | secondaryLabel | `#3C3C43` (60%) | `#EBEBF5` (60%) |
| 占位符 | tertiaryLabel | `#3C3C43` (30%) | `#EBEBF5` (30%) |
| 分隔线 | separator | `#3C3C43` (29%) | `#545458` (65%) |

**App 专用品牌色**（作为 accent）：
- 健康/自然感: `#34C759`（Apple Green）用于成功/健康标签
- 温暖/食欲感: `#FF9500`（Apple Orange）用于 CTA 按钮
- 文字主色: `#1D1D1F`（Apple 官方深黑）

---

## 3. 字体规范

**Apple HIG 字体规范**：严格使用 SF Pro（系统默认字体），使用 Dynamic Type 支持无障碍。

| 场景 | 语义 | 字重 | 基础字号 | 备注 |
|---|---|---|---|---|
| 大标题 | .largeTitle | Bold | 34pt | 页面主标题 |
| 标题1 | .title | Bold | 28pt | 区块标题 |
| 标题2 | .title2 | Semibold | 22pt | 卡片菜名 |
| 标题3 | .title3 | Semibold | 20pt | 副标题 |
| 正文 | .body | Regular | 17pt | 主要内容 |
| 调用文字 | .callout | Regular | 16pt | 辅助说明 |
| 字幕 | .subheadline | Regular | 15pt | 描述文字 |
| 脚注 | .footnote | Regular | 13pt | 次要信息 |
| 标签 | .caption | Regular | 12pt | 小标签 |

**重要规则**：
- 永远不要设置固定字体，使用 `.font()` modifier
- 正文使用 `.body`，标题使用对应语义级别
- 避免过粗字重（Bold 仅用于大标题和标题）
- 中文字体回退：系统自动处理 SF Pro → PingFang

---

## 4. 间距系统

**Apple HIG iOS 标准间距**（8pt 基准，但 iOS 更常用 4/8/12/16/20/24/32pt）：

| 用途 | 间距 | 场景 |
|---|---|---|
| 紧凑间距 | 4pt | 标签内元素 |
| 元素间距 | 8pt | 同组元素 |
| 标准间距 | 12pt | 不同组元素 |
| 16pt | 16pt | 卡片内边距 |
| 区块间距 | 20pt | 区块间 |
| 页面边距 | 16pt | 安全区边距（刘海屏） |
| 大区块间距 | 32pt | 主要内容区块 |

**安全区**：
- 顶部: 避免内容被刘海/Dynamic Island 遮挡
- 底部: Tab Bar 以上至少 34pt（Home Indicator）

---

## 5. 圆角与阴影（Apple HIG 标准）

**圆角规则**：
- **小元素**（按钮/标签）: cornerRadius = 8pt
- **中等元素**（卡片/输入框）: cornerRadius = 12pt（Apple 标准）
- **大元素**（底部弹窗/Sheet）: cornerRadius = 20pt（顶部）; 底部为 0（贴屏幕底部）
- **图片**: cornerRadius = 12pt（与卡片保持一致）
- **永远不要使用正圆**（Apple HIG 明确反对，除非是头像）

**阴影规则**：
- 使用 Apple 标准 `.shadow` modifier（自动适配浅色/深色模式）
- 卡片: `color: .black.opacity(0.1), radius: 10, y: 4`
- 浮层/弹窗: `color: .black.opacity(0.2), radius: 20, y: 8`

**毛玻璃效果（重点）**：
- Tab Bar: `.ultraThinMaterial`（Apple 毛玻璃）
- 弹窗背景: `.regularMaterial`
- 保持系统层级感，不自定义模糊

---

## 6. 页面详细设计（Apple HIG 标准）

### 6.1 Tab Bar（底部导航）- iOS 标准

- **高度**: 83pt（含 Home Indicator 安全区 34pt）
- **背景**: `.ultraThinMaterial` 毛玻璃（Apple HIG 标准）
- **3个 Tab**: 首页（🎲）/ 探索（🍜）/ 健康（🥗）
- **Tab 图标**: SF Symbols (`die.face.5` / `fork.knife` / `leaf.fill`)
- **选中态**: SF Symbol `rectangle.fill` 填充图标 + 主色
- **未选中态**: SF Symbol `rectangle` 线性图标 + `.secondaryLabel`
- **文字**: Caption 尺寸，12pt
- **布局**: 文字在图标正下方，等距分布（Apple 规范）

### 6.2 首页 Tab 1 — 随便决定器

**布局（Apple 规范）**:
- 顶部: "今天吃什么？" 大标题（.largeTitle, 34pt Bold）
- 中间: 
  - 心情选择器: `.horizontalScroll()` 横向滚动，`.pickerStyle(.segmented)` 不适用，用自定义胶囊按钮
  - 心情选项: 5个胶囊按钮，图标 + 短文字，选中态背景 #34C759
  - 甩一甩: 使用 `Core Motion` 检测摇动，或简单点击按钮
- 中央决策按钮:
  - 尺寸: 120pt 直径（Apple HIG: 最小触控区域 44pt，实际要更大才有仪式感）
  - 样式: `.fill` 填充按钮，背景 #FF9500，文字白色 .title2 Bold
  - 圆角: 正圆（Apple 允许正圆用于特殊按钮）
  - 阴影: `.shadow(radius: 10, y: 5)` 
  - 动效: 点击 `scale(0.92) + spring()` 回弹

**结果展示（Sheet 弹出，Apple HIG 标准）**:
- 弹出方式: `.sheet(isPresented:)` 从底部滑出，`.presentationDetents([.medium, .large])`
- 顶部拖动条: 标准 36x5pt 灰色条（iOS 规范）
- 食物大图: 宽度撑满，aspectRatio 4:3，圆角 12pt
- 菜名: .title2 Semibold
- 推荐理由: .subheadline，`.secondaryLabel` 颜色
- 卡路里: .caption，带圆形背景标签 #34C75920%
- 操作按钮: `.buttonStyle(.bordered)` 样式统一
- 底部 Sheet 可下滑关闭（iOS 标准交互）

### 6.3 探索 Tab 2 — 菜系探索

**布局（List + Grid 混合）**:
- 顶部: 页面标题 "探索菜系" (.largeTitle)
- 菜系列表: `.lazyVGrid` 双列网格，或 `.lazyVStack`
  - 每个菜系: 卡片 12pt 圆角，图片 60% + 文字 40%
  - 图片: 使用 SF Symbol 或 Unsplash（如果是真实食物图）
- 选中态: 2pt 绿色边框 + 浅绿背景

**详情页（NavigationLink 推入）**:
- 使用 `.navigationStack`（iOS 16+ 标准）
- 推入动画: 默认 spring 动画
- 返回按钮: 标准 `.navigationTitle` 自动后退箭头

### 6.4 健康 Tab 3 — 健康模式

**布局（Apple 健康 App 风格）**:
- 顶部: 页面标题 "健康饮食" (.largeTitle)
- 目标选择: 4个 `.tieredButton` 或 `.symbolRenderingMode(.hierarchical)` 的 SF Symbol 按钮
  - 选中态: 背景 `.tint` 色，图标 `.foregroundStyle(.white)`
- 结果列表: `.lazyVStack` 纵向列表
  - 卡片: `.card` 样式（iOS 15+ 原生卡片支持 `.cardStyle`）
  - 营养标签: 小字号 `.tags` 风格

### 6.5 通用组件规范

**Cards（Apple 原生）**:
```swift
// iOS 15+ 标准卡片
Text("内容")
    .padding()
    .background(Color(.secondarySystemBackground))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
```

**Buttons（Apple HIG）**:
- `.buttonStyle(.bordered)`: 带边框按钮
- `.buttonStyle(.borderedProminent)`: 填充主色按钮
- `.buttonStyle(.plain)`: 纯文本按钮
- 最小触控区域: 44x44pt（HIG 强制要求）

**Images**:
- 使用 `AsyncImage` + placeholder
- `resizable()` + `.aspectRatio(contentMode: .fill)` 填充
- 统一 `.cornerRadius(12)`

---

## 7. 动效规范（Apple HIG 标准）

**Apple 动效核心原则**：动效应帮助用户理解界面变化，而不是装饰。

**Apple 标准动画曲线**：
- **标准**: `Animation.easeInOut(duration: 0.3)`
- **弹性**: `.spring(response: 0.4, dampingFraction: 0.8)`
- **快速**: `.easeOut(duration: 0.2)` — 用于按钮点击反馈
- **减速**: `.easeIn(duration: 0.2)` — 用于弹窗出现

**Apple HIG 规范交互动效**：

| 交互 | 动效 | 参数 |
|---|---|---|
| 按钮点击 | scale + opacity | 0.97 → 1.0, 200ms |
| Sheet 弹出 | 弹簧动画 | `.presentationSpring()` |
| Tab 切换 | 系统默认 | iOS 系统控制 |
| 页面推入 | NavigationStack 默认 | 系统默认 |
| 开关 Toggle | 系统默认 | `.animation(.spring())` |
| 列表删除 | 系统默认 swipe | 系统默认 |
| 下拉刷新 | 系统默认 | `.refreshable` |

**禁止的动效**（Apple HIG 明确反对）：
- ❌ 持续的循环动画（除非播放态指示器）
- ❌ 闪烁或快速闪烁的动画
- ❌ 过度华丽的过渡动画
- ❌ 自动播放的视频背景（除非用户主动触发）

**具体实现规则**：
- 使用 SwiftUI `withAnimation()` 包裹状态变化
- 使用 `.transition(.asymmetric(...))` 实现非对称过渡
- 列表 staggered 动画：`transition(.scale(scale: 0.8).combined(with: .opacity))`
- 所有动效必须可关闭（Reduce Motion 设置）

---

## 8. 图片规范

- **图片比例**: 4:3（横向食物照）或 16:9（风景食物）
- **图片来源**: Unsplash API（食物类别），或 AI 生成
- **图片加载**: 使用 `AsyncImage` + placeholder
- **占位图**: 系统 `.gray` 加上 SF Symbol `photo` 居中
- **加载态**: **骨架屏（Shimmer）** 是 Apple HIG 推荐方案
  - 使用 `Shimmer` modifier（iOS 16+）
  - 不使用纯灰色块

**图片应用规则**：
```swift
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        ProgressView() // 加载中显示 ProgressView
    case .success(let image):
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    case .failure:
        Color.gray.opacity(0.2)
            .overlay(Image(systemName: "photo"))
    @unknown default:
        Color.gray.opacity(0.2)
    }
}
.frame(height: 200)
.cornerRadius(12)
```

---

## 9. 图标规范（SF Symbols 3.0+）

**核心图标（必须使用 SF Symbols）**：
| Tab | 选中态 | 未选中态 |
|---|---|---|
| 首页 | `die.face.5.fill` | `die.face.5` |
| 探索 | `fork.knife.circle.fill` | `fork.knife.circle` |
| 健康 | `leaf.fill` | `leaf` |
| 收藏 | `heart.fill` | `heart` |
| 重试 | `arrow.clockwise` | - |
| 分享 | `square.and.arrow.up` | - |

**SF Symbols 使用规则**：
- 只使用 `.hierarchical` 或 `.monochrome` 渲染模式
- 不要自定义颜色，使用系统 `tint` 驱动
- 多重量级（weight）: `.medium` 用于 Tab，`.regular` 用于正文图标
- 动效图标: 使用 `.symbolEffect(.pulse)` 等系统动效

---

## 10. 无障碍规范（Apple HIG 要求）

**VoiceOver**：
- 所有图片必须设置 `.accessibilityLabel("食物图片描述")`
- 按钮必须设置 `.accessibilityLabel("操作名称")`
- 使用 `.accessibilityHint("双击执行...")` 给出操作提示

**Dynamic Type**：
- 所有字体使用语义级别（`.body` / `.title` 等），不要固定字号
- 支持 Bold Text 设置
- 支持放大模式（LazyVStack 滚动不受影响）

**Reduce Motion**：
```swift
// 检测 Reduce Motion 设置
@Environment(\.accessibilityReduceMotion) var reduceMotion

// 条件动画
withAnimation(reduceMotion ? .none : .spring()) {
    // 状态变化
}
```

**色彩对比度**：
- 文字与背景: 最小 4.5:1（AA 标准）
- 大文字: 最小 3:1
- 使用 `.accessibilityContrast()` 辅助检查
