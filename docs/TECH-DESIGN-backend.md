# 后端技术方案 — 「吃什么」App v1.0

> **作者**: server-dev  
> **状态**: 草稿（待 PM 评审）  
> **日期**: 2026-03-24  
> **版本**: 1.0

---

## 一、技术栈选型

### 1.1 核心技术栈

| 层级 | 技术选型 | 理由 |
|---|---|---|
| **Runtime** | Cloudflare Workers | 免费额度充足，全球CDN边缘部署，冷启动<5ms |
| **语言** | TypeScript | 类型安全，与前端统一语言栈 |
| **框架** | Hono | 轻量（~14KB），完全兼容 Workers API，性能极佳 |
| **数据库** | Cloudflare D1 | SQLite内核，全球复制，免费额度5GB， Serverless友好 |
| **AI** | Cloudflare Workers AI (Llama 3.1 8B) | 免费额度充足，边缘推理低延迟 |
| **图片** | Unsplash API | 免费额度充足，高质量食物图片 |
| **存储（本地缓存） | Cloudflare KV | 边缘KV存储，存储用户会话级数据 |
| **部署** | Wrangler CLI | 官方CI/CD工具，原生支持Workers |

### 1.2 技术栈优势

- **零运维**: 全Serverless，无需管理服务器
- **全球低延迟**: 边缘部署，用户就近访问
- **免费额度充足**: Workers(10万req/天) + D1(5GB) + KV(1GB) + AI(1万tokens/天)
- **开发体验好**: TypeScript + Hono + Wrangler，本地模拟Cloudflare环境

---

## 二、架构设计

### 2.1 系统架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloudflare Edge                           │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │   iOS App    │───▶│   Workers   │───▶│   Hono 框架      │  │
│  │  (SwiftUI)   │    │   (Node)    │    │   Routes         │  │
│  └──────────────┘    └──────────────┘    └────────┬─────────┘  │
│                                                   │              │
│         ┌─────────────────────────────────────────┼───────────┐  │
│         │                 路由层                   │           │  │
│         ├──────────────────────────────────────────────────┤  │
│         │                                                  │  │
│    ┌────▼────┐  ┌────────────┐  ┌─────────────┐  ┌────────▼─┐ │  │
│    │ /cuisines│  │/recommend │  │ /dishes    │  │ /history │ │  │
│    │  菜系    │  │  推荐     │  │  菜品详情   │  │  历史   │ │  │
│    └────┬────┘  └─────┬──────┘  └──────┬─────┘  └─────────┘ │  │
│         │             │                │                     │  │
│         │    ┌─────────┴────────┐       │                     │  │
│         │    │   Service 层    │◀──────┘                     │  │
│         │    │  Recommendation │                             │  │
│         │    │  Cuisine        │                             │  │
│         │    │  Dish          │                             │  │
│         │    │  History        │                             │  │
│         │    └────────┬────────┘                             │  │
│         │             │                                      │  │
│         │    ┌────────┴────────┐                             │  │
│         │    │   Data 层       │                             │  │
│         │    ├─────────────────┤                             │  │
│         │    │  D1 Database    │                             │  │
│         │    │  KV Storage     │                             │  │
│         │    └─────────────────┘                             │  │
│         │             │                                      │  │
│         │    ┌────────▼────────┐                             │  │
│         │    │  AI Provider   │                             │  │
│         │    │  (Llama 3.1)  │                             │  │
│         │    └────────────────┘                             │  │
│         │             │                                      │  │
│         │    ┌────────▼────────┐                             │  │
│         │    │  External APIs  │                             │  │
│         │    │  - Unsplash    │                             │  │
│         │    │  - AI Images   │                             │  │
│         └────│────────────────│─────────────────────────────┘  │
│              └────────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
what-to-eat-backend/
├── src/
│   ├── index.ts              # Workers 入口
│   ├── app.ts                # Hono 应用实例
│   ├── routes/
│   │   ├── cuisines.ts       # 菜系列表路由
│   │   ├── recommend.ts      # 推荐路由
│   │   ├── dishes.ts         # 菜品详情路由
│   │   └── history.ts        # 历史记录路由
│   ├── services/
│   │   ├── cuisine.service.ts # 菜系业务逻辑
│   │   ├── dish.service.ts    # 菜品业务逻辑
│   │   ├── recommend.service.ts # AI推荐逻辑
│   │   └── history.service.ts # 历史记录逻辑
│   ├── providers/
│   │   ├── ai.provider.ts    # Cloudflare AI 封装
│   │   ├── unsplash.provider.ts # 图片服务封装
│   │   └── database.provider.ts # D1 数据库封装
│   ├── repositories/
│   │   ├── cuisine.repository.ts # 菜系数据访问
│   │   ├── dish.repository.ts   # 菜品数据访问
│   │   └── history.repository.ts # 历史数据访问
│   ├── schemas/
│   │   ├── cuisine.schema.ts # 菜系列校验
│   │   ├── dish.schema.ts    # 菜品校验
│   │   └── recommend.schema.ts # 推荐校验
│   ├── middlewares/
│   │   ├── logger.ts         # 请求日志
│   │   ├── error.ts          # 错误处理
│   │   └── cors.ts           # CORS
│   └── utils/
│       ├── response.ts       # 统一响应格式
│       └── env.ts            # 环境变量
├── migrations/
│   └── 001_init.sql          # 数据库初始化脚本
├── wrangler.toml            # Cloudflare Workers 配置
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

---

## 三、数据模型设计

### 3.1 D1 数据库 Schema

```sql
-- 菜系表
CREATE TABLE IF NOT EXISTS cuisines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,           -- 菜系名称（中文）
    name_en TEXT NOT NULL,        -- 菜系名称（英文）
    icon_url TEXT,                -- 菜系图标
    cover_image_url TEXT,         -- 封面图
    tags TEXT,                    -- JSON数组：["辣","麻辣"]
    dish_count INTEGER DEFAULT 0,  -- 菜品数量
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch())
);

-- 菜品表
CREATE TABLE IF NOT EXISTS dishes (
    id TEXT PRIMARY KEY,
    cuisine_id TEXT NOT NULL,     -- 所属菜系ID
    name TEXT NOT NULL,           -- 菜品名称
    image_url TEXT,               -- 主图
    thumbnail_url TEXT,           -- 缩略图
    calories_min INTEGER,         -- 最低卡路里
    calories_max INTEGER,         -- 最高卡路里
    calories_unit TEXT DEFAULT 'kcal',
    tags TEXT,                    -- JSON数组
    difficulty TEXT,              -- 难度：简单/中等/较难
    cook_time TEXT,              -- 烹饪时间
    ai_recommendation TEXT,       -- AI推荐理由
    recipe TEXT,                  -- JSON：{ingredients, steps, tips}
    created_at INTEGER DEFAULT (unixepoch()),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

-- 用户推荐历史表
CREATE TABLE IF NOT EXISTS recommendation_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,        -- 用户ID（设备UUID）
    dish_id TEXT NOT NULL,        -- 推荐的菜品ID
    cuisine_id TEXT NOT NULL,     -- 菜系ID
    recommended_at INTEGER DEFAULT (unixepoch()),
    liked INTEGER DEFAULT 0,      -- 用户是否喜欢：0未知/1喜欢/-1不喜欢
    FOREIGN KEY (dish_id) REFERENCES dishes(id),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

-- 用户偏好表
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id TEXT PRIMARY KEY,     -- 用户ID（设备UUID）
    disliked_cuisines TEXT,        -- 不喜欢的菜系JSON数组
    disliked_tags TEXT,            -- 不喜欢的标签JSON数组
    preferred_dish_ids TEXT,      -- 喜欢的菜品ID列表（用于去重）
    settings TEXT,                -- 用户设置JSON
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch())
);

-- 索引
CREATE INDEX idx_dishes_cuisine ON dishes(cuisine_id);
CREATE INDEX idx_history_user ON recommendation_history(user_id);
CREATE INDEX idx_history_user_recent ON recommendation_history(user_id, recommended_at DESC);
```

### 3.2 KV 存储（会话级数据）

用于存储用户当前会话的临时数据（如已推荐的菜品列表，用于去重）：

```
Key: "session:{userId}:excluded_dishes"
Value: JSON array of dish IDs
TTL: 24 hours
```

---

## 四、API 接口设计

### 4.1 基础信息

- **Base URL**: `https://what-to-eat.{namespace}.workers.dev/api/v1`
- **Content-Type**: `application/json`
- **认证**: 简单设备ID（UUID），通过 header `X-User-ID` 传递

### 4.2 统一响应格式

**成功响应:**
```json
{
  "code": 0,
  "message": "ok",
  "data": { ... }
}
```

**错误响应:**
```json
{
  "code": 40001,
  "message": "参数校验失败",
  "details": { "field": "cuisineId", "reason": "必填" }
}
```

### 4.3 接口详情

#### 4.3.1 获取菜系列表

```
GET /cuisines
```

**响应:**
```json
{
  "code": 0,
  "data": {
    "cuisines": [
      {
        "id": "chinese_sichuan",
        "name": "川菜",
        "nameEn": "Sichuan",
        "iconUrl": "https://...",
        "coverImageUrl": "https://...",
        "dishCount": 28,
        "tags": ["辣", "麻辣"]
      }
    ]
  }
}
```

#### 4.3.2 随机推荐菜品

```
POST /cuisines/{cuisineId}/recommend
Header: X-User-ID: {uuid}
```

**请求体:**
```json
{
  "excludePrevious": true
}
```

**响应:**
```json
{
  "code": 0,
  "data": {
    "dish": {
      "id": "dish_001",
      "name": "宫保鸡丁",
      "cuisineId": "chinese_sichuan",
      "cuisineName": "川菜",
      "imageUrl": "https://...",
      "thumbnailUrl": "https://...",
      "calories": {
        "min": 250,
        "max": 350,
        "unit": "kcal"
      },
      "aiRecommendation": "经典川菜代表，麻辣鲜香！",
      "tags": ["经典", "下饭"],
      "difficulty": "简单",
      "cookTime": "25分钟"
    }
  }
}
```

**行为:**
- AI实时生成推荐理由（调用Llama 3.1）
- 自动从KV读取已推荐菜品列表，进行会话内去重

#### 4.3.3 菜品详情

```
GET /dishes/{dishId}
Header: X-User-ID: {uuid}
```

**响应:**
```json
{
  "code": 0,
  "data": {
    "dish": {
      "id": "dish_001",
      "name": "宫保鸡丁",
      "cuisineId": "chinese_sichuan",
      "cuisineName": "川菜",
      "imageUrl": "https://...",
      "thumbnailUrl": "https://...",
      "calories": { ... },
      "aiRecommendation": "...",
      "tags": ["经典", "下饭"],
      "difficulty": "简单",
      "cookTime": "25分钟",
      "recipe": {
        "ingredients": [
          { "name": "鸡胸肉", "amount": "300g" }
        ],
        "steps": ["步骤1", "步骤2"],
        "tips": ["小贴士1"]
      }
    }
  }
}
```

#### 4.3.4 推荐历史

```
GET /history
Header: X-User-ID: {uuid}
Query: page=1&pageSize=20
```

**响应:**
```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 1,
        "dishId": "dish_001",
        "dishName": "宫保鸡丁",
        "cuisineName": "川菜",
        "recommendedAt": 1711234567,
        "liked": 1
      }
    ],
    "total": 45,
    "page": 1,
    "pageSize": 20
  }
}
```

#### 4.3.5 反馈推荐结果

```
POST /history/{historyId}/feedback
Header: X-User-ID: {uuid}
Body: { "liked": 1 }
```

**响应:**
```json
{ "code": 0, "message": "ok" }
```

---

## 五、核心流程

### 5.1 随机推荐流程

```
1. 客户端: POST /cuisines/{id}/recommend
2. 服务端: 检查KV中的 excluded_dishes
3. 服务端: 从D1随机查询一道未排除的菜品
4. 服务端: 如无结果，随机返回任意菜品（无去重）
5. 服务端: 调用Cloudflare AI生成推荐理由
6. 服务端: 更新KV中的 excluded_dishes
7. 服务端: 记录到 recommendation_history
8. 返回: 菜品 + AI推荐理由
```

### 5.2 AI推荐理由生成

使用 Cloudflare Workers AI 的 Llama 3.1 8B 模型：

```
Prompt Template:
你是一个热情的美食推荐助手。请为"{dishName}"生成一段50字以内的推荐理由，语气友好活泼，突出菜品特点。
```

**超时设置**: 10秒  
**重试策略**: 最多重试2次，指数退避  
**降级方案**: AI不可用时，使用预置推荐理由

---

## 六、技术风险与应对

| 风险 | 等级 | 应对方案 |
|---|---|---|
| Cloudflare AI 冷启动慢 | 中 | 预热机制：每小时调用一次空请求保活 |
| AI推荐理由质量不稳定 | 中 | 提供多个Prompt模板随机选择，控制输出长度 |
| D1写入QPS限制 | 低 | 用户历史记录异步写入，不阻塞主流程 |
| 免费额度用尽 | 中 | 监控使用量，预留降级方案（使用预置文案） |
| KV会话数据丢失 | 低 | 接受会话级去重丢失，用户可接受 |

---

## 七、预估工时

| 模块 | 工作内容 | 预估工时 |
|---|---|---|
| **环境搭建** | 项目初始化、Wrangler配置、本地调试环境 | 4小时 |
| **数据库设计** | D1 Schema、migrations、种子数据 | 4小时 |
| **基础框架** | Hono框架、中间件、统一响应、日志 | 4小时 |
| **菜系列表API** | GET /cuisines | 2小时 |
| **随机推荐API** | POST /cuisines/{id}/recommend + AI集成 | 8小时 |
| **菜品详情API** | GET /dishes/{id} | 2小时 |
| **历史记录API** | GET /history + POST /feedback | 4小时 |
| **去重机制** | KV会话管理、会话级去重 | 4小时 |
| **错误处理** | 统一错误处理、边界情况 | 2小时 |
| **测试** | 单元测试、API测试 | 8小时 |
| **部署** | CI/CD配置、域名绑定 | 2小时 |
| **文档** | API文档、README | 2小时 |
| **总计** | | **46小时** |

---

## 八、下一步行动

1. **PM评审**: 确认技术方案
2. **与client-dev对齐**: 确认API契约和设备ID生成策略
3. **启动开发**: 环境搭建 → 数据库 → API开发

---

**待确认事项:**
1. 设备ID生成策略：前端生成UUID还是服务端生成？
2. 用户偏好设置：是否需要持久化存储？
3. 是否需要多语言支持（当前仅中文）？
