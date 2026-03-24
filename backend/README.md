# 「吃什么」App 后端服务

## 技术栈

- **Runtime**: Cloudflare Workers
- **Framework**: Hono (TypeScript)
- **Database**: Cloudflare D1 (SQLite)
- **Cache**: Cloudflare KV
- **AI**: Cloudflare Workers AI (Llama 3.1 8B)

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 配置 Wrangler

登录 Cloudflare：

```bash
wrangler login
```

创 建 D1 数据库：

```bash
wrangler d1 create what-to-eat-db
# 将返回的 database_id 填入 wrangler.toml
```

创建 KV Namespace：

```bash
wrangler kv:namespace create "WHAT_TO_EAT_KV"
# 将返回的 id 填入 wrangler.toml
```

### 3. 执行数据库迁移

```bash
wrangler d1 execute what-to-eat-db --file=./migrations/001_init.sql --local
# 或使用 --remote 部署到生产
```

### 4. 本地开发

```bash
npm run dev
# 访问 http://localhost:8787
```

### 5. 部署

```bash
npm run deploy
```

## API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/cuisines` | 获取菜系列表 |
| POST | `/api/v1/cuisines/{cuisineId}/recommend` | 随机推荐菜品 |
| GET | `/api/v1/dishes/{dishId}` | 菜品详情 |
| GET | `/api/v1/history` | 推荐历史 |
| POST | `/api/v1/history/{historyId}/feedback` | 反馈 |

详细接口文档：`../docs/TECH-DESIGN-backend.md`

## 环境变量

无敏感信息，所有配置通过 `wrangler.toml` 管理。

## 目录结构

```
backend/
├── src/
│   ├── routes/          # 路由层
│   ├── services/        # 业务逻辑层
│   ├── providers/       # 外部服务封装
│   ├── repositories/    # 数据访问层
│   ├── schemas/         # 校验 Schema
│   ├── middlewares/     # 中间件
│   └── utils/           # 工具函数
├── migrations/          # 数据库迁移脚本
├── wrangler.toml        # Workers 配置
└── package.json
```

## 开发规范

遵循团队开发规范：DEV-STANDARD.md
