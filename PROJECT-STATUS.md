# 项目状态看板 — 「吃什么」iOS App

## 总览
- 状态：🔄 开发进行中
- 当前阶段：UI 设计稿进行中，客户端初始化进行中
- 开始日期：2026-03-24
- 最后更新：2026-03-24

## 已完成文档
| 文档 | 路径 | 状态 |
|---|---|---|
| README.md | `what-to-eat/README.md` | ✅ 完成 |
| PRD.md | `what-to-eat/docs/PRD.md` | ✅ 完成 |
| DESIGN-SPEC.md (主控版) | `what-to-eat/docs/DESIGN-SPEC.md` | ✅ 完成 |
| DESIGN-SPEC-what-to-eat-v1.md (UI版) | `what-to-eat/docs/DESIGN-SPEC-what-to-eat-v1.md` | ✅ 完成 |
| CHANGELOG.md | `what-to-eat/CHANGELOG.md` | ✅ 完成 |
| TECH-DESIGN-backend.md (后端技术方案) | `what-to-eat/docs/TECH-DESIGN-backend.md` | ✅ 完成 |

## 各岗位进度
| 岗位 | 任务 | 状态 | 阻塞 |
|---|---|---|---|
| 主控 | 需求决策 + 规范输出 | ✅ 完成 | 无 |
| UI (小艺) | 3个Tab完整设计稿 | 🔄 进行中 | 无 |
| 客户端 (小前) | 项目初始化 + AI接口 | ✅ 完成 | 无 |
| 客户端 (小前) | API对接代码 | ✅ 完成 | 等待后端服务 |
| 后端 | Cloudflare AI配置 | ✅ 完成核心代码 | 等待凭证 |
| 后端 | API对齐 | ✅ 完成 | client-dev确认API契约，APIService结构对齐 |
| 后端 | Cloudflare凭证配置 | ⏳ 待启动 | 等待主控提供凭证 |
| 测试 (小测) | 测试用例 | ⏳ 未开始 | 等待开发 |

## 技术决策（已确认）
- **前端**: SwiftUI (iOS 17+)
- **AI**: Cloudflare Workers AI（Llama 3.1，开源免费）
- **图片**: Unsplash API
- **存储**: UserDefaults（本地）
- **图标**: SF Symbols 3.0+
- **设计风格**: 欧美简约（Airbnb/Calm风格）

## 设计规范要点（UI版 v1）
- 主色: #7CB97D（鼠尾草绿）
- 强调色: #F4A261（暖橙）
- 背景: #FFFFFF 纯白
- 圆角: 20pt 卡片 / 16pt 按钮
- 字体: SF Pro Display + SF Pro Text
- 动效: Spring 动画，staggered 卡片出现

## 下一步动作
1. UI 完成3个Tab完整设计稿
2. 客户端完成项目初始化（XcodeGen + 基础架构）
3. AI Service 接口对接 Cloudflare Workers AI
4. 本地存储 Service 实现
