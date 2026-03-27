# 测试报告 - what-to-eat App v1.0

> **测试工程师：** 小测
> **测试日期：** 2026-03-27
> **测试方式：** 静态代码审查
> **版本：** v1.0

---

## 基本信息

| 字段 | 内容 |
|---|---|
| 测试日期 | 2026-03-27 |
| 测试人员 | 小测 |
| 测试范围 | 滑动卡片、发现页、TabBar、收藏/历史、冷启动引导 |
| 测试环境 | macOS + Xcode（静态审查） |
| 代码路径 | `what-to-eat/WhatToEat.xcodeproj` |
| Mock 模式 | useMock=true |

---

## 测试结果概览

| 指标 | 数值 |
|---|---|
| 功能模块 | 6 |
| 发现问题 | 6 |
| Critical | 0 |
| Major | 2 |
| Minor | 4 |

**测试方式说明：** simctl 不可用（Xcode Command Line Tools 环境问题），采用静态代码审查 + 编译验证。

---

## 问题汇总

| # | 严重程度 | 模块 | 问题描述 |
|---|---|---|---|
| 1 | **Major** | 冷启动 | Onboarding 页面从未被调用，App 直接进入 ContentView |
| 2 | **Major** | 收藏/历史 | MyProfilePage 的"历史记录"菜单点击无响应（无 NavigationLink） |
| 3 | **Major** | 收藏/历史 | FavoritesPage 和 HistoryPage 在 ContentView 中无入口 |
| 4 | **Minor** | 发现页 | DiscoverView 菜系列表硬编码，与 MockAPIService 数据不一致 |
| 5 | **Minor** | 收藏/历史 | FavoritesPage/HistoryPage 缺少 NavigationStack 包装 |
| 6 | **Minor** | 代码规范 | CuisineSelectionPage 的 let columns 声明在 body 中（应在 computed property） |

---

## 详细问题分析

### 🔴 BUG-001: Onboarding 永远不会被展示（Critical/阻塞发布）

- **Bug编号：** BUG-001
- **标题：** Onboarding 页面未被 App 入口调用
- **严重程度：** Critical（阻塞发布）
- **位置：** `WhatToEatApp.swift`
- **复现步骤：**
  1. 查看 `WhatToEatApp.swift` 的 App 入口
  2. `ContentView()` 直接作为 WindowGroup 内容
  3. OnboardingStep1/2/3.swift 存在但无任何引用
- **预期结果：** 新用户首次打开 App 应看到 3 步引导页
- **实际结果：** App 直接进入主界面（ContentView），冷启动引导流程完全缺失
- **建议修复：**
  1. 创建 `AppState.swift` 管理 onboarding 完成状态
  2. 在 `WhatToEatApp.swift` 中根据状态决定展示 Onboarding 还是 ContentView

```swift
// WhatToEatApp.swift 当前代码（有问题）：
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()  // 直接进入主界面，Onboarding 从未调用
        }
    }
}
```

---

### 🔴 BUG-002: 历史记录菜单点击无响应

- **Bug编号：** BUG-002
- **标题：** MyProfilePage 中"历史记录"行点击无任何导航行为
- **严重程度：** Major
- **位置：** `MyProfilePage.swift` → `MenuRow`
- **复现步骤：**
  1. 进入"我的"页面
  2. 找到并点击"历史记录"菜单行
- **预期结果：** 跳转到 HistoryPage
- **实际结果：** 点击后无任何响应（MenuRow 无 tap 动作，仅作展示）
- **建议修复：** 为 MenuRow 添加 tap action 或使用 NavigationLink

```swift
// 当前 MenuRow（无交互）：
struct MenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            // ... 图标和文字
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        // 问题：没有任何 tap gesture 或 NavigationLink
    }
}

// MyProfilePage 中调用：
MenuRow(icon: "clock.fill", iconColor: Color(hex: "#4ECDC4"), title: "历史记录")
```

---

### 🔴 BUG-003: FavoritesPage 和 HistoryPage 在 ContentView 中无入口

- **Bug编号：** BUG-003
- **标题：** 收藏和历史页面已实现但无法访问
- **严重程度：** Major
- **位置：** `WhatToEatApp.swift` ContentView TabView
- **问题分析：**

```swift
// ContentView 当前 Tab 配置：
Tab 1: HomeView()          // ✅ 有
Tab 2: ExploreView()       // ✅ 有（发现）
Tab 3: CuisineSelectionPage()  // ✅ 有（菜系）
Tab 4: FavoritesPage()     // ⚠️ 有 Tab 但点击无效（MenuRow 问题）
Tab 5: MyProfilePage()    // ✅ 有

// 问题：
// 1. FavoritesPage 虽然是 Tab，但点击"我的收藏"Tab → FavoritesPage 确实会显示
// 2. HistoryPage 完全没有独立入口
// 3. MyProfilePage 中的"历史记录"点击无响应（BUG-002）
```

- **建议修复：**
  1. 修复 BUG-002 后，"历史记录"点击应导航到 HistoryPage
  2. 或在 ContentView 中增加独立的"历史"Tab

---

### 🟡 BUG-004: 发现页菜系列表数据源不一致

- **Bug编号：** BUG-004
- **标题：** DiscoverView 硬编码 8 个菜系，Mock API 返回 6 个不同菜系
- **严重程度：** Minor
- **位置：** `DiscoverView.swift` vs `MockAPIService.swift`
- **问题：** DiscoverView 显示川菜/粤菜/湘菜等中国传统菜系，但 Mock API 返回日料/意餐/泰餐等

---

### 🟡 BUG-005: 收藏/历史页面缺少导航支持

- **Bug编号：** BUG-005
- **标题：** FavoritesPage 和 HistoryPage 作为独立 View 缺少导航包装
- **严重程度：** Minor
- **位置：** `FavoritesPage.swift`, `HistoryPage.swift`
- **说明：** 这两个页面在 #Preview 中有 NavigationStack，但实际作为 Tab 内容时依赖父级 NavigationStack。如父级无 NavigationStack，导航将失效。

---

### 🟡 BUG-006: CuisineSelectionPage 代码质量问题

- **Bug编号：** BUG-006
- **标题：** `let columns` 声明在 view body 中
- **严重程度：** Trivial
- **位置：** `CuisineSelectionPage.swift`
- **说明：** SwiftUI 最佳实践建议 computed property 应提取到 body 之外

---

## 代码审查通过的功能

| 功能 | 状态 | 说明 |
|---|---|---|
| 滑动卡片-右滑 | ✅ PASS | SwipeCardView 逻辑完整，阈值/动画正确 |
| 滑动卡片-左滑 | ✅ PASS | Nope 指示器逻辑正确 |
| 滑动卡片-上滑 | ✅ PASS | Super Like 与水平滑动分离 |
| 滑动卡片-点击 | ✅ PASS | onTapGesture → showDetail sheet |
| 发现页搜索 | ✅ PASS | filteredCuisines 过滤逻辑正确 |
| Tab 切换框架 | ✅ PASS | ContentView TabView 5 Tab 定义完整 |
| 收藏页 UI | ✅ PASS | 空状态 UI 完整 |
| Onboarding 步骤 UI | ✅ PASS | 3 个步骤页面 UI 完整（只是未被调用） |
| 菜系选择页 UI | ✅ PASS | CuisineCard 选择状态正确 |

---

## 编译验证

| 项目 | 状态 |
|---|---|
| XcodeGen 生成项目 | ✅ 通过 |
| Swift 语法静态检查 | ✅ 通过 |
| 项目结构 | ✅ 符合预期 |
| Mock 数据完整性 | ✅ 通过 |

---

## 结论

- [ ] ❌ **不通过** — 存在 3 个 Major 级别问题，其中 BUG-001 阻塞冷启动引导流程
- [ ] ⚠️ **有条件通过** — 需要修复 BUG-001、002、003 后方可发布
- [ ] ❌ **通过**

**核心问题：**
1. **BUG-001** Onboarding 流程完全缺失 — 新用户无引导
2. **BUG-002** 历史记录不可用 — MenuRow 无导航
3. **BUG-003** 历史页面入口问题 — 与 BUG-002 相关

---

## 建议

### 立即修复（发布前必须）

1. **BUG-001**: 实现 Onboarding 流程
   - 创建 `AppState.swift` 管理首次启动状态
   - 修改 `WhatToEatApp.swift` 根据状态切换 Onboarding/ContentView

2. **BUG-002**: 修复 MenuRow 导航
   - 为"历史记录"添加 NavigationLink
   - 或在 MyProfilePage 外层包 NavigationStack

### 建议优化（发布后）

3. **BUG-004**: 统一发现页数据源为 API
4. **BUG-005**: 确认收藏/历史页面导航架构
5. **BUG-006**: 优化 CuisineSelectionPage 代码结构

---

## 附录：测试用例 vs 代码对照

| 用例 | 对应代码文件 | 审查结果 |
|---|---|---|
| TC-001 滑动右滑 | SwipeCardView.swift | ✅ PASS |
| TC-002 滑动左滑 | SwipeCardView.swift | ✅ PASS |
| TC-003 滑动上滑 | SwipeCardView.swift | ✅ PASS |
| TC-004 发现页搜索 | DiscoverView.swift | ✅ PASS |
| TC-005 清空搜索 | DiscoverView.swift | ✅ PASS |
| TC-006 菜系分类 | DiscoverView.swift | ✅ 数据不一致 ⚠️ |
| TC-007 收藏页 | FavoritesPage.swift | ✅ UI PASS |
| TC-008 历史页 | HistoryPage.swift | ❌ 入口缺失 ⚠️ |
| TC-009 Tab切换 | ContentView.swift | ✅ PASS |
| TC-010 Tab切换 | ContentView.swift | ✅ PASS |
| TC-011 5-Tab | ContentView.swift | ✅ PASS |
| TC-012 冷启动引导 | WhatToEatApp.swift | ❌ 完全缺失 ⚠️ |

---

**报告状态：** 完成
**待修复 Major Bug：** 3 个
**下次更新：** Bug 修复后回归测试
