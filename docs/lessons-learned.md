# Lessons Learned

## 2026-03-27 - 工程纪律

### 七条纪律确认
1. ✅ 效率优先：使用 Skills，局部修改，禁止全文件重写
2. ✅ 代码为王：只产出可运行代码，不写废话注释
3. ✅ 版本控制：有意义改动立即 git commit，格式 feat/fix/refactor
4. ✅ 学习复盘：出错写入 lessons-learned.md
5. ✅ 沟通纪律：有问必有答，卡住 2 轮立刻报告
6. ✅ 代码质量：先跑通再优化，改完必验证
7. ✅ 文件管理：代码放项目，文档放 docs/

---

## 历史教训

### API 路由对齐问题
**问题**：前后端 API 路由不一致，导致 recommend 接口 404
**教训**：接口对接时先拉取后端最新代码确认路由，不要凭文档假设
**日期**：2026-03-26

### xcodegen 报错 Decoding failed at "path"
**问题**：`project.yml` 中 `sources` 写法导致 xcodegen 解析失败
**教训**：使用最简化 `sources: [src]` 格式，避免复杂配置
**日期**：2026-03-24

### Dish model 重复定义
**问题**：`Dish.swift` 和 `APIService.swift` 中都定义了 Dish struct
**教训**：Model 集中在一个文件，避免分散定义
**日期**：2026-03-24

### Git branch 名称不一致
**问题**：本地分支是 master，远程是 main
**教训**：统一使用 `git branch -m master main` 重命名后再 push
**日期**：2026-03-24
