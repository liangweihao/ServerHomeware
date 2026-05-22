# HomeStock 服务端 — 分阶段 Trae 提示词

***

## 📋 Phase 1：基础骨架

```markdown
# HomeStock Server — Phase 1：基础骨架

## 项目概述

为 HomeStock 家庭物品管理 Flutter App 开发后台 API 服务。
核心功能：用户认证、数据同步、多设备共享、智能提醒推送。

## 技术选型

- 语言：Python 3.11+
- 框架：FastAPI
- 数据库：PostgreSQL 15+
- ORM：SQLAlchemy 2.0（async 模式）
- 数据迁移：Alembic
- 认证：JWT（access_token + refresh_token）
- 缓存：Redis
- 任务队列：Celery + Redis（定时任务）
- 文件存储：本地存储（后续可切换 OSS）
- 容器化：Docker + docker-compose
- API文档：FastAPI 自带 Swagger UI

## 本阶段目标

搭建完整项目骨架：目录结构、数据库连接、用户认证系统、基础中间件。
完成后可以注册、登录、刷新Token、获取用户信息。

---

## 任务1：项目结构

创建项目 home_stock_server，目录结构如下：

```

home\_stock\_server/
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env.example
├── alembic.ini
├── alembic/
│ └── versions/
│
├── app/
│ ├── **init**.py
│ ├── main.py # FastAPI 应用入口
│ ├── config.py # 配置管理（环境变量）
│ │
│ ├── core/ # 核心模块
│ │ ├── **init**.py
│ │ ├── database.py # 数据库连接/会话
│ │ ├── redis.py # Redis 连接
│ │ ├── security.py # JWT/密码加密
│ │ ├── dependencies.py # FastAPI 依赖注入
│ │ ├── exceptions.py # 自定义异常
│ │ └── middleware.py # 中间件
│ │
│ ├── models/ # SQLAlchemy 模型
│ │ ├── **init**.py
│ │ ├── base.py # 基础模型类
│ │ ├── user.py
│ │ ├── family.py
│ │ ├── item.py
│ │ ├── category.py
│ │ ├── location.py
│ │ ├── usage\_record.py
│ │ └── shopping.py
│ │
│ ├── schemas/ # Pydantic 请求/响应模型
│ │ ├── **init**.py
│ │ ├── common.py # 通用响应格式
│ │ ├── auth.py
│ │ ├── user.py
│ │ ├── family.py
│ │ ├── item.py
│ │ ├── category.py
│ │ ├── location.py
│ │ ├── usage\_record.py
│ │ └── shopping.py
│ │
│ ├── api/ # 路由/接口
│ │ ├── **init**.py
│ │ ├── router.py # 总路由注册
│ │ └── v1/
│ │ ├── **init**.py
│ │ ├── auth.py
│ │ ├── users.py
│ │ ├── families.py
│ │ ├── items.py
│ │ ├── categories.py
│ │ ├── locations.py
│ │ ├── usage\_records.py
│ │ ├── shopping.py
│ │ ├── alerts.py
│ │ ├── statistics.py
│ │ └── upload.py
│ │
│ ├── services/ # 业务逻辑层
│ │ ├── **init**.py
│ │ ├── auth\_service.py
│ │ ├── user\_service.py
│ │ ├── family\_service.py
│ │ ├── item\_service.py
│ │ ├── category\_service.py
│ │ ├── location\_service.py
│ │ ├── usage\_service.py
│ │ ├── shopping\_service.py
│ │ ├── alert\_service.py
│ │ ├── statistics\_service.py
│ │ ├── prediction\_service.py
│ │ └── notification\_service.py
│ │
│ ├── repositories/ # 数据访问层
│ │ ├── **init**.py
│ │ ├── base.py # 通用 CRUD 基类
│ │ ├── user\_repo.py
│ │ ├── family\_repo.py
│ │ ├── item\_repo.py
│ │ ├── category\_repo.py
│ │ ├── location\_repo.py
│ │ ├── usage\_record\_repo.py
│ │ └── shopping\_repo.py
│ │
│ ├── tasks/ # Celery 异步任务
│ │ ├── **init**.py
│ │ ├── celery\_app.py
│ │ ├── expiry\_check.py
│ │ ├── prediction\_update.py
│ │ └── notification\_push.py
│ │
│ └── utils/ # 工具
│ ├── **init**.py
│ ├── datetime\_utils.py
│ └── file\_utils.py
│
├── tests/
│ ├── **init**.py
│ ├── conftest.py
│ └── test\_auth.py
│
└── scripts/
└── seed\_data.py # 预设数据初始化脚本

```

---

## 任务2：环境配置

### .env.example
```

# App

APP\_NAME=HomeStock
APP\_ENV=development
DEBUG=true
API\_PREFIX=/api/v1

# Database

DATABASE\_URL=postgresql+asyncpg://postgres:password\@localhost:5432/homestock

# Redis

REDIS\_URL=redis\://localhost:6379/0

# JWT

JWT\_SECRET\_KEY=your-secret-key-change-in-production
JWT\_ALGORITHM=HS256
ACCESS\_TOKEN\_EXPIRE\_MINUTES=60
REFRESH\_TOKEN\_EXPIRE\_DAYS=30

# File Upload

UPLOAD\_DIR=./uploads
MAX\_FILE\_SIZE\_MB=10

# FCM (Firebase Cloud Messaging)

FCM\_SERVER\_KEY=your-fcm-key

```

### config.py
使用 pydantic-settings 从环境变量读取配置，支持 .env 文件。

### docker-compose.yml
包含以下服务：
- app: Python FastAPI 应用
- db: PostgreSQL 15
- redis: Redis 7
- celery_worker: Celery Worker
- celery_beat: Celery Beat（定时调度）

---

## 任务3：数据库连接

### database.py
- 使用 SQLAlchemy 2.0 async 引擎
- 创建 async_session_maker
- 提供 get_db 依赖注入函数
- 连接池配置：pool_size=10, max_overflow=20

### base.py（模型基类）
所有模型继承的基类，包含：
- id: 主键，自增
- created_at: 创建时间，默认当前时间
- updated_at: 更新时间，自动更新

---

## 任务4：用户模型 & 家庭模型

### User 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| phone | String(20), unique | 手机号（登录凭证）|
| email | String(100), unique, nullable | 邮箱 |
| password_hash | String(128) | 加密密码 |
| nickname | String(50) | 昵称 |
| avatar_url | String(500), nullable | 头像 |
| current_family_id | Integer, FK, nullable | 当前所在家庭 |
| is_active | Boolean, default True | |
| last_login_at | DateTime, nullable | |
| created_at | DateTime | |
| updated_at | DateTime | |

### Family 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| name | String(50) | 家庭名称 |
| invite_code | String(8), unique | 邀请码 |
| owner_id | Integer, FK → users | 创建者 |
| created_at | DateTime | |

### FamilyMember 模型（关联表）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| user_id | Integer, FK → users | |
| role | String(20) | owner/admin/member |
| nickname_in_family | String(50), nullable | 家庭内昵称（如"爸爸"）|
| joined_at | DateTime | |

---

## 任务5：认证系统

### security.py
- 密码加密：bcrypt（passlib）
- JWT生成：access_token（1小时）+ refresh_token（30天）
- Token payload：{user_id, family_id, exp, type}

### auth 路由接口

**POST /api/v1/auth/register**
```

Request: {phone, password, nickname}
Response: {user, access\_token, refresh\_token}
逻辑：检查手机号唯一 → 创建用户 → 自动创建默认家庭 → 返回token

```

**POST /api/v1/auth/login**
```

Request: {phone, password}
Response: {user, access\_token, refresh\_token}
逻辑：验证手机号密码 → 更新last\_login\_at → 返回token

```

**POST /api/v1/auth/refresh**
```

Request: {refresh\_token}
Response: {access\_token, refresh\_token}
逻辑：验证refresh\_token有效 → 签发新token对

```

**POST /api/v1/auth/logout**
```

Header: Authorization: Bearer {access\_token}
逻辑：将当前token加入Redis黑名单（TTL=剩余有效期）

````

### dependencies.py
- get_current_user：从请求Header提取JWT → 解析 → 查数据库获取用户 → 检查黑名单
- get_current_family：从当前用户获取 current_family_id
- 失败时抛出 401 异常

---

## 任务6：通用响应格式

### schemas/common.py

所有接口统一响应格式：

```python
# 成功
{
  "code": 200,
  "message": "success",
  "data": { ... }
}

# 分页
{
  "code": 200,
  "message": "success", 
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "page_size": 20,
    "pages": 5
  }
}

# 错误
{
  "code": 400/401/404/500,
  "message": "错误描述",
  "data": null
}
````

创建通用的 ResponseSchema、PaginatedResponseSchema、ErrorResponseSchema。

***

## 任务7：异常处理 & 中间件

### exceptions.py

自定义异常类：

- AppException(code, message)
- UnauthorizedException
- ForbiddenException
- NotFoundException
- ValidationException

### middleware.py

- 请求日志中间件：记录每个请求的 method/path/耗时/状态码
- CORS 中间件：允许 Flutter App 跨域
- 全局异常处理器：捕获所有异常返回统一格式

***

## 任务8：main.py 入口

- 创建 FastAPI 实例
- 注册所有路由
- 注册中间件
- startup 事件：连接数据库、连接 Redis
- shutdown 事件：关闭连接
- 启用 Swagger UI (路径 /docs)

***

## 任务9：Alembic 数据迁移

- 初始化 Alembic（async 模式）
- 生成第一个 migration（包含 users、families、family\_members 三张表）
- 确保 alembic upgrade head 可以成功建表

***

## 任务10：Docker 化

### Dockerfile

- 基于 python:3.11-slim
- 安装依赖
- 复制代码
- uvicorn 启动

### docker-compose.yml

一键启动所有服务，开发时可以 docker-compose up 即可运行完整环境。

***

## 验收标准

1. ✅ docker-compose up 后所有服务正常启动
2. ✅ 访问 /docs 可以看到 Swagger 文档
3. ✅ 注册接口：手机号+密码注册成功，返回用户信息和token
4. ✅ 登录接口：正确密码登录成功，错误密码返回401
5. ✅ Token刷新：用refresh\_token获取新access\_token
6. ✅ 受保护接口：不带token返回401，带正确token返回用户信息
7. ✅ 注册时自动创建默认家庭
8. ✅ 数据库迁移正常执行
9. ✅ 请求日志正常打印
10. ✅ CORS 配置正确（Flutter App可以访问）

````

---

## 📋 Phase 2：核心数据模型 & CRUD API

```markdown
# HomeStock Server — Phase 2：核心数据模型 & CRUD API

## 前置条件
Phase 1 已完成：项目骨架、数据库连接、用户认证系统就绪。

## 本阶段目标
创建所有业务数据模型，实现物品、分类、位置的完整 CRUD API。
完成后 Flutter 端可以通过 API 进行物品的增删改查。

---

## 任务1：业务数据模型

所有业务数据都归属于 family（家庭隔离），确保不同家庭的数据互不可见。

### Category 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | 所属家庭（系统预设的 family_id=null）|
| name | String(50) | |
| icon | String(20) | emoji |
| color | String(10) | hex颜色 |
| parent_id | Integer, FK → self, nullable | 父分类 |
| sort_order | Integer, default 0 | |
| is_system | Boolean, default False | 系统预设不可删 |
| is_active | Boolean, default True | 软删除 |
| created_at | DateTime | |

### Location 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(50) | |
| icon | String(20), nullable | |
| parent_id | Integer, FK → self, nullable | |
| level | Integer | 1/2/3 |
| full_path | String(200) | 如"厨房/冰箱/冷藏层" |
| sort_order | Integer, default 0 | |
| is_active | Boolean, default True | |
| created_at | DateTime | |

### Item 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(100) | |
| brand | String(50), nullable | |
| specification | String(100), nullable | |
| barcode | String(50), nullable | |
| category_id | Integer, FK → categories | |
| location_id | Integer, FK → locations, nullable | |
| purchase_price | Numeric(10,2), nullable | |
| total_price | Numeric(10,2), nullable | |
| purchase_quantity | Integer, default 1 | |
| current_quantity | Numeric(10,2), default 1 | |
| unit | String(10), default '件' | |
| safety_stock | Numeric(10,2), default 1 | |
| purchase_date | Date, nullable | |
| purchase_channel | String(50), nullable | |
| production_date | Date, nullable | |
| expiry_date | Date, nullable | |
| shelf_life_days | Integer, nullable | |
| opened_date | Date, nullable | |
| after_open_days | Integer, nullable | |
| warranty_date | Date, nullable | |
| expiry_alert_days | Integer, default 3 | |
| stock_alert | Boolean, default True | |
| notes | Text, nullable | |
| status | Integer, default 0 | 0使用中/1用完/2过期/3丢弃 |
| avg_daily_consumption | Numeric(10,4), nullable | |
| predicted_empty_date | Date, nullable | |
| created_by | Integer, FK → users | 创建人 |
| created_at | DateTime | |
| updated_at | DateTime | |

### ItemImage 模型（物品图片，独立表）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| item_id | Integer, FK → items | |
| url | String(500) | 图片路径/URL |
| sort_order | Integer, default 0 | |
| created_at | DateTime | |

### UsageRecord 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| item_id | Integer, FK → items | |
| family_id | Integer, FK → families | |
| type | Integer | 0入库/1使用/2丢弃/3移动/4调整 |
| quantity | Numeric(10,2) | 变更数量 |
| remaining_quantity | Numeric(10,2) | 变更后剩余 |
| operator_id | Integer, FK → users, nullable | 操作人 |
| operator_name | String(50), nullable | 操作人名称冗余 |
| from_location_id | Integer, nullable | 移动前位置 |
| to_location_id | Integer, nullable | 移动后位置 |
| notes | String(200), nullable | |
| created_at | DateTime | |

### ShoppingItem 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(100) | |
| related_item_id | Integer, FK → items, nullable | |
| quantity | Numeric(10,2), default 1 | |
| unit | String(10), default '件' | |
| estimated_price | Numeric(10,2), nullable | |
| is_purchased | Boolean, default False | |
| is_auto_generated | Boolean, default False | |
| priority | Integer, default 0 | |
| purchased_at | DateTime, nullable | |
| purchased_by | Integer, FK → users, nullable | |
| created_at | DateTime | |

---

## 任务2：Alembic 迁移

生成迁移脚本创建以上所有表。
为常用查询添加索引：
- items: family_id, status, category_id, location_id, expiry_date, barcode
- usage_records: item_id, family_id, created_at
- shopping_items: family_id, is_purchased
- locations: family_id, parent_id
- categories: family_id, parent_id

---

## 任务3：通用 Repository 基类

创建 BaseRepository 类，提供通用 CRUD 方法：
- get_by_id(id) → 单条查询
- get_list(filters, page, page_size, order_by) → 分页查询
- create(data) → 新增
- update(id, data) → 更新
- delete(id) → 删除（软删除 is_active=False）
- hard_delete(id) → 物理删除

所有方法自动加上 family_id 过滤（数据隔离）。

---

## 任务4：分类 API

### 接口清单

**GET /api/v1/categories**
````

说明：获取当前家庭的所有分类（树形结构）
响应：包含父分类及其子分类的嵌套列表
逻辑：查询 family\_id=当前家庭 OR is\_system=True 的分类
按 parent\_id 组装成树形

```

**POST /api/v1/categories**
```

说明：创建自定义分类
请求：{name, icon, color, parent\_id(可选)}
逻辑：family\_id=当前家庭，is\_system=False

```

**PUT /api/v1/categories/{id}**
```

说明：更新分类（仅可改自定义分类）
请求：{name, icon, color, sort\_order}
逻辑：检查 is\_system=False 才允许修改

```

**DELETE /api/v1/categories/{id}**
```

说明：删除分类
逻辑：is\_system=True 不可删；检查该分类下是否有物品，有则拒绝删除

```

---

## 任务5：位置 API

### 接口清单

**GET /api/v1/locations**
```

说明：获取当前家庭所有位置（树形结构）
查询参数：parent\_id（可选，获取某层级下的子位置）
响应：树形结构，每个位置附带 item\_count（该位置下的物品数量）

```

**GET /api/v1/locations/{id}**
```

说明：获取位置详情
响应：位置信息 + 子位置列表 + 该位置下的物品列表

```

**POST /api/v1/locations**
```

请求：{name, icon, parent\_id(可选)}
逻辑：

- 自动计算 level（无parent=1，有parent=parent.level+1，最大3）
- 自动拼接 full\_path
- family\_id=当前家庭

```

**PUT /api/v1/locations/{id}**
```

请求：{name, icon, sort\_order}
逻辑：更新后如果name变了，更新 full\_path 和所有子位置的 full\_path

```

**DELETE /api/v1/locations/{id}**
```

逻辑：检查该位置及子位置下是否有物品，有则拒绝（返回400+提示信息）
无物品则删除该位置及所有子位置

```

---

## 任务6：物品 CRUD API

### 接口清单

**GET /api/v1/items**
```

说明：获取物品列表（分页 + 筛选 + 排序）
查询参数：

- page, page\_size（分页）
- status: 0/1/2/3（状态筛选）
- category\_id（分类筛选）
- location\_id（位置筛选）
- keyword（搜索名称/品牌）
- sort\_by: expiry\_date/created\_at/current\_quantity/purchase\_price
- sort\_order: asc/desc
- expiring\_within\_days: 7（即将过期筛选，过期日期在N天内）
- low\_stock: true（库存低于safety\_stock的）
  响应：分页列表，每个物品附带 category\_name, location\_full\_path, urgency 字段

```

**GET /api/v1/items/{id}**
```

说明：获取物品详情
响应：完整物品信息 + 图片列表 + 最近5条使用记录

```

**POST /api/v1/items**
```

请求：全量字段（name和category\_id必填，其余可选）
逻辑：

- 如果没传 current\_quantity，默认等于 purchase\_quantity
- 如果传了 production\_date + shelf\_life\_days 但没传 expiry\_date，自动计算
- 如果传了 purchase\_price + purchase\_quantity，自动计算 total\_price
- created\_by = 当前用户
- 同时插入一条 usage\_record（type=0入库，quantity=purchase\_quantity）
- family\_id=当前家庭

```

**PUT /api/v1/items/{id}**
```

请求：部分更新（只传需要改的字段）
逻辑：更新 updated\_at，如果改了 expiry\_date 要重新调度提醒

```

**DELETE /api/v1/items/{id}**
```

逻辑：软删除（status 不变，加 is\_deleted 标记）或物理删除
同时删除关联的 usage\_records 和 item\_images
从 shopping\_list 中解除关联

```

**POST /api/v1/items/{id}/use**
```

说明：快捷记录使用
请求：{quantity, operator\_name(可选)}
逻辑：

- 更新 current\_quantity -= quantity
- 插入 usage\_record（type=1使用）
- 如果 current\_quantity <= 0，自动更新 status=1（已用完）
- 更新 avg\_daily\_consumption 和 predicted\_empty\_date
- 返回更新后的物品信息

```

**POST /api/v1/items/{id}/finish**
```

说明：标记用完
逻辑：current\_quantity=0, status=1, 记录usage\_record

```

**POST /api/v1/items/{id}/discard**
```

说明：标记丢弃
逻辑：status=3, 记录usage\_record(type=2)

```

**POST /api/v1/items/{id}/move**
```

说明：移动位置
请求：{to\_location\_id}
逻辑：更新 location\_id，记录 usage\_record(type=3，含from和to)

```

**GET /api/v1/items/barcode/{barcode}**
```

说明：根据条码查询物品（检查当前家庭是否已有该条码物品）
响应：物品信息 或 404

```

---

## 任务7：预设数据种子脚本

创建 scripts/seed_data.py：
- 插入系统预设分类（family_id=null, is_system=True）
- 首次创建家庭时，自动从预设模板复制位置结构到该家庭

预设分类数据：
```

食品饮料🍎 #FF8A65：乳制品、肉类、蔬果、零食、饮品、调味品、粮油、速食
日用清洁🧹 #4DB6AC：洗衣、厨房清洁、纸巾、垃圾袋
个护美妆🧴 #F06292：洗护、口腔、护肤、彩妆
药品保健💊 #7986CB：常用药、保健品、医疗器械
家用电器📺 #FFD54F：大家电、小家电、数码
衣物鞋帽👕 #F06292
其他📦 #A1887F

```

预设位置模板（用户注册创建家庭时复制）：
```

厨房🍳：冰箱(冷藏层/冷冻层/门侧)、吊柜(一层/二层/三层)、调料架、水槽下方、台面
卫生间🛁：洗漱台(台面/镜柜/下方)、浴室柜、马桶旁
客厅🛋️：电视柜、茶几(上方/下方)、书架
主卧🛏️：衣柜(上层/中层/下层/抽屉)、床头柜(台面/抽屉)、梳妆台
次卧🛏️：衣柜、书桌
阳台☀️：储物柜(上层/下层)、晾衣区

```

---

## 验收标准

1. ✅ 数据库迁移成功，所有表已创建
2. ✅ 分类API：获取树形分类列表、创建/编辑/删除自定义分类
3. ✅ 位置API：树形结构获取、创建/删除带保护检查
4. ✅ 物品API：完整CRUD、分页查询、多条件筛选、排序
5. ✅ 物品使用：/use接口正确更新数量和记录
6. ✅ 标记用完/丢弃正确更新状态
7. ✅ 所有接口有 family_id 数据隔离
8. ✅ Swagger 文档清晰可读
9. ✅ 预设数据脚本可正确执行
10. ✅ 注册新用户时自动创建家庭+位置模板
```

***

## 📋 Phase 3：家庭协作 & 数据同步

```markdown
# HomeStock Server — Phase 3：家庭协作 & 数据同步

## 前置条件
Phase 1-2 已完成。认证系统和核心CRUD API就绪。

## 本阶段目标
实现家庭多人协作：邀请成员、权限管理、操作记录归属、数据变更同步机制。

---

## 任务1：家庭管理 API

**POST /api/v1/families**
```

说明：创建新家庭
请求：{name}
逻辑：

- 创建家庭，owner\_id=当前用户
- 生成8位随机邀请码（字母+数字，避免歧义字符）
- 创建 family\_member 记录（role=owner）
- 从预设模板复制位置结构到新家庭
- 更新用户 current\_family\_id

```

**GET /api/v1/families/current**
```

说明：获取当前家庭信息
响应：家庭基础信息 + 成员列表 + 邀请码 + 统计数据（物品总数等）

```

**POST /api/v1/families/join**
```

说明：通过邀请码加入家庭
请求：{invite\_code}
逻辑：

- 查找邀请码对应的家庭
- 检查用户是否已在该家庭
- 创建 family\_member（role=member）
- 更新用户 current\_family\_id

```

**POST /api/v1/families/current/refresh-invite-code**
```

说明：刷新邀请码（仅owner/admin）
逻辑：生成新邀请码替换旧的

```

**PUT /api/v1/families/members/{member_id}/role**
```

说明：修改成员角色（仅owner可操作）
请求：{role: "admin" | "member"}

```

**DELETE /api/v1/families/members/{member_id}**
```

说明：移除成员（owner可移除任何人；admin可移除member；不能移除自己）

```

**POST /api/v1/families/leave**
```

说明：主动退出家庭
逻辑：

- owner不能退出（需先转让）
- 退出后 current\_family\_id 置空

```

**PUT /api/v1/families/current/switch**
```

说明：切换当前家庭（如果用户属于多个家庭）
请求：{family\_id}
逻辑：检查用户确实属于该家庭，更新 current\_family\_id

```

---

## 任务2：权限控制

### 角色权限矩阵

| 操作 | owner | admin | member |
|------|-------|-------|--------|
| 查看物品/位置/分类 | ✅ | ✅ | ✅ |
| 添加/编辑物品 | ✅ | ✅ | ✅ |
| 记录使用 | ✅ | ✅ | ✅ |
| 删除物品 | ✅ | ✅ | ❌ |
| 管理位置 | ✅ | ✅ | ❌ |
| 管理分类 | ✅ | ✅ | ❌ |
| 管理成员 | ✅ | ✅（不能改owner） | ❌ |
| 删除家庭 | ✅ | ❌ | ❌ |
| 修改家庭设置 | ✅ | ✅ | ❌ |

### 实现方式
创建权限检查依赖：
- require_member：只要是家庭成员即可
- require_admin：需要admin或owner角色
- require_owner：需要owner角色

在对应接口中注入权限依赖。

---

## 任务3：操作记录增强

### 完善 UsageRecord

所有操作自动记录 operator_id 和 operator_name（从当前登录用户获取）。

### ActivityLog 模型（新增，可选）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK | |
| user_id | Integer, FK | |
| action | String(50) | create_item/use_item/delete_item/... |
| target_type | String(50) | item/location/category/... |
| target_id | Integer | |
| target_name | String(100) | 冗余名称方便显示 |
| detail | JSON, nullable | 额外信息 |
| created_at | DateTime | |

### 动态流 API

**GET /api/v1/activities**
```

说明：获取家庭动态流（首页"最近动态"数据源）
查询参数：page, page\_size, user\_id(可选，筛选某人的操作)
响应：分页的动态列表，每条含：操作人名称、操作描述、时间、目标物品

```

---

## 任务4：数据同步机制

### 方案：增量同步（基于 updated_at 时间戳）

Flutter App 端记录上次同步时间（last_sync_at），请求时带上。

**GET /api/v1/sync/changes**
```

查询参数：since（ISO时间戳，上次同步时间）
响应：
{
"server\_time": "2024-01-25T10:00:00Z",
"changes": {
"items": {
"created": \[...], // since 之后新建的
"updated": \[...], // since 之后修改的
"deleted": \[id...] // since 之后删除的
},
"categories": { ... },
"locations": { ... },
"shopping\_list": { ... }
}
}
逻辑：查询 updated\_at > since 或 deleted\_at > since 的记录

```

**POST /api/v1/sync/push**
```

说明：App端离线操作后批量上传
请求：
{
"items": \[
{"action": "create", "data": {...}, "client\_id": "temp\_123"},
{"action": "update", "data": {...}, "id": 45},
{"action": "delete", "id": 46}
],
"usage\_records": \[...]
}
响应：
{
"results": \[
{"client\_id": "temp\_123", "server\_id": 78, "status": "ok"},
...
],
"conflicts": \[...] // 冲突记录（服务端也改了）
}
逻辑：

- 逐条处理
- 如果某物品在App离线期间服务端也被修改（updated\_at更新）→ 标记冲突
- 冲突策略：服务端数据优先，将冲突记录返回让App处理

```

### 软删除支持
为 Item、Location、Category 添加 deleted_at 字段：
- 删除时不真正删除，设 deleted_at = now
- 查询时默认过滤 deleted_at IS NULL
- 同步接口需要返回已删除的 ID 列表

---

## 任务5：设备管理

### UserDevice 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| user_id | Integer, FK → users | |
| device_token | String(500) | FCM推送token |
| device_type | String(20) | ios/android |
| device_name | String(100), nullable | 如"iPhone 15" |
| last_active_at | DateTime | |
| created_at | DateTime | |

**POST /api/v1/devices/register**
```

请求：{device\_token, device\_type, device\_name}
逻辑：注册/更新设备token（用于推送通知）

```

**DELETE /api/v1/devices/{id}**
```

说明：注销设备（退出登录时调用）

```

---

## 验收标准

1. ✅ 创建家庭并自动生成邀请码
2. ✅ 通过邀请码成功加入家庭
3. ✅ 切换家庭后数据正确隔离
4. ✅ 权限控制生效：member不能删除物品
5. ✅ 所有操作正确记录operator_id
6. ✅ 动态流API返回正确的家庭操作记录
7. ✅ 增量同步接口正确返回变更数据
8. ✅ 批量推送接口正确处理并返回结果
9. ✅ 设备注册接口正常
10. ✅ 软删除机制正确（查询排除已删除，同步包含已删除ID）
```

***

## 📋 Phase 4：提醒 & 推送 & 定时任务

```markdown
# HomeStock Server — Phase 4：提醒 & 推送 & 定时任务

## 前置条件
Phase 1-3 已完成。用户系统、CRUD、家庭协作就绪。

## 本阶段目标
实现服务端提醒检查、推送通知、定时任务系统。

---

## 任务1：Celery 配置

### celery_app.py
- Broker: Redis
- Result Backend: Redis
- 时区：Asia/Shanghai
- 序列化：JSON

### Beat 定时调度配置
| 任务 | 频率 | 说明 |
|------|------|------|
| check_expiry | 每天早上8:00 | 检查即将过期物品 |
| update_predictions | 每天凌晨2:00 | 批量更新消耗预测 |
| auto_expire_items | 每天凌晨1:00 | 自动将已过期物品状态改为2 |
| generate_shopping_suggestions | 每天早上9:00 | 自动生成购物推荐 |
| clean_old_notifications | 每周日凌晨3:00 | 清理30天前的通知记录 |

---

## 任务2：提醒检查任务

### check_expiry 任务逻辑
```

1. 查询所有 status=0 且 expiry\_date 不为空 的物品
2. 对每个物品计算 days\_until\_expiry = expiry\_date - today
3. 如果 days\_until\_expiry <= expiry\_alert\_days：
   - 生成提醒记录
   - 向该家庭所有成员推送通知
4. 如果 days\_until\_expiry == 0（今天过期）：
   - 推送紧急通知
5. 去重：同一个物品当天只推送一次（用 Redis 记录已推送）

```

### auto_expire_items 任务逻辑
```

UPDATE items SET status=2, updated\_at=now
WHERE status=0 AND expiry\_date < today

```

### generate_shopping_suggestions 任务逻辑
```

遍历所有 status=0 的物品：
IF (current\_quantity <= safety\_stock) OR (predicted\_empty\_date <= today + 7天)
AND shopping\_list 中不存在该物品的未购买记录
THEN:
INSERT shopping\_list（is\_auto\_generated=True）

```

---

## 任务3：Notification 模型 & API

### Notification 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK | |
| user_id | Integer, FK, nullable | null=全家庭，有值=特定用户 |
| type | String(30) | expiry/stock/purchase/warranty/system |
| title | String(100) | |
| body | String(500) | |
| item_id | Integer, nullable | 关联物品 |
| priority | String(10) | high/medium/low |
| is_read | Boolean, default False | |
| action_url | String(200), nullable | 点击跳转路径如 /items/123 |
| created_at | DateTime | |

### 提醒 API

**GET /api/v1/notifications**
```

查询参数：

- page, page\_size
- type: expiry/stock/purchase/warranty（可选筛选）
- is\_read: true/false（可选）
  响应：分页通知列表

```

**GET /api/v1/notifications/unread-count**
```

响应：{count: 5}
用于 Flutter 端角标显示

```

**PUT /api/v1/notifications/{id}/read**
```

说明：标记单条已读

```

**PUT /api/v1/notifications/read-all**
```

说明：全部标记已读

```

**DELETE /api/v1/notifications/{id}**
```

说明：删除通知

```

---

## 任务4：提醒数据聚合 API（实时查询）

除了 Notification 存储型提醒，还提供实时查询接口（App打开时用）：

**GET /api/v1/alerts/summary**
```

说明：获取当前提醒摘要（首页StatCard用）
响应：
{
"expiring\_count": 5, // 7天内过期数量
"expired\_count": 2, // 已过期未处理
"low\_stock\_count": 3, // 库存不足
"shopping\_count": 8, // 待购数量
"nearest\_expiry": {...}, // 最近要过期的物品简要信息
"nearest\_empty": {...} // 最近要用完的物品简要信息
}

```

**GET /api/v1/alerts/expiring**
```

说明：获取即将过期物品列表
查询参数：days=7（几天内）
响应：物品列表 + 距离过期天数

```

**GET /api/v1/alerts/low-stock**
```

说明：获取库存不足物品列表
响应：物品列表 + 当前量 vs 安全线

```

---

## 任务5：推送通知服务

### notification_service.py

**push_to_user(user_id, title, body, data)**
```

逻辑：

1. 查询该用户的所有 device\_token
2. 通过 FCM HTTP API 发送推送
3. 记录推送结果
4. 如果 token 失效则删除该设备记录

```

**push_to_family(family_id, title, body, data)**
```

逻辑：

1. 查询家庭所有成员的 device\_token
2. 批量推送

````

**push_data 格式**
```json
{
  "type": "expiry_alert",
  "item_id": 123,
  "route": "/items/123"
}
````

Flutter端收到推送后根据 data.route 跳转对应页面。

### 推送模板

```
过期提醒：
  title: "⚠️ 物品即将过期"
  body: "{物品名} 还剩{N}天过期，请及时处理"

库存提醒：
  title: "📦 库存不足"  
  body: "{物品名} 剩余不足，预计{N}天后用完"

用完提醒：
  title: "🛒 物品已用完"
  body: "{物品名} 已经用完了，要补购吗？"
```

***

## 任务6：用户提醒偏好

### NotificationPreference 模型

| 字段              | 类型                    | 说明            |
| :-------------- | :-------------------- | :------------ |
| id              | Integer, PK           | <br />        |
| user\_id        | Integer, FK, unique   | <br />        |
| push\_enabled   | Boolean, default True | 全局开关          |
| expiry\_alert   | Boolean, default True | <br />        |
| stock\_alert    | Boolean, default True | <br />        |
| purchase\_alert | Boolean, default True | <br />        |
| quiet\_start    | Time, nullable        | 免打扰开始（如22:00） |
| quiet\_end      | Time, nullable        | 免打扰结束（如08:00） |

**GET /api/v1/users/me/notification-preferences**
**PUT /api/v1/users/me/notification-preferences**

推送前检查用户偏好：

- push\_enabled=False → 不推送
- 对应类型关闭 → 不推送
- 当前时间在免打扰时段 → 延迟到免打扰结束后推送

***

## 验收标准

1. ✅ Celery Worker 和 Beat 正常启动运行
2. ✅ 每日过期检查任务按时执行
3. ✅ 过期物品自动更新状态为已过期
4. ✅ 购物推荐自动生成到购物清单
5. ✅ 通知记录正确存储
6. ✅ 通知API：列表/未读数/标记已读 正常工作
7. ✅ 提醒摘要API正确返回各类计数
8. ✅ FCM推送正确发送（至少用测试token验证接口正确）
9. ✅ 免打扰时段内不推送
10. ✅ 用户偏好设置可保存并生效

````

---

## 📋 Phase 5：购物清单 & 统计 & 预测

```markdown
# HomeStock Server — Phase 5：购物清单 & 统计 & 预测

## 前置条件
Phase 1-4 已完成。

## 本阶段目标
完善购物清单功能、实现数据统计接口、完善消耗预测算法。

---

## 任务1：购物清单 API

**GET /api/v1/shopping**
````

查询参数：

- status: pending/purchased/all
- page, page\_size
  响应：分页列表，每项附带关联物品信息（如有）

```

**POST /api/v1/shopping**
```

说明：手动添加购物项
请求：{name, quantity, unit, estimated\_price(可选), related\_item\_id(可选)}

```

**PUT /api/v1/shopping/{id}**
```

请求：{quantity, unit, estimated\_price, priority}

```

**PUT /api/v1/shopping/{id}/purchase**
```

说明：标记已购买
请求：{actual\_price(可选)}
逻辑：

- is\_purchased=True, purchased\_at=now, purchased\_by=当前用户
- 如果有 related\_item\_id 且该物品 status=1(用完)，提示"是否入库"

```

**POST /api/v1/shopping/{id}/to-item**
```

说明：从已购物品一键创建入库（跳过手动填写）
请求：{location\_id(可选), expiry\_date(可选)}
逻辑：

- 根据 related\_item\_id 获取历史物品信息
- 复制信息创建新 Item（或恢复原物品的数量）
- 标记购物项为已完成

```

**PUT /api/v1/shopping/purchase-all**
```

说明：全部标记已购买

```

**DELETE /api/v1/shopping/{id}**

**GET /api/v1/shopping/share-text**
```

说明：生成分享文本
响应：
{
"text": "📋 购物清单 (2024-01-25)\n- 洗衣液 3kg ×1\n- 纯牛奶 ×6\n...",
"total\_estimated": 152.6
}

```

---

## 任务2：统计 API

**GET /api/v1/statistics/overview**
```

查询参数：period=week/month/year, date(可选，默认当前)
响应：
{
"period": "month",
"date\_range": {"start": "2024-01-01", "end": "2024-01-31"},

"expense": {
"total": 2847.5,
"previous\_total": 2542.0,
"trend\_percentage": 12.0, // 比上期+12%
"trend\_direction": "up"
},

"inventory": {
"total\_items": 95,
"new\_items": 23,
"consumed\_items": 18,
"warning\_items": 5
}
}

```

**GET /api/v1/statistics/expense-trend**
```

查询参数：months=6（近几个月）
响应：
{
"data": \[
{"month": "2023-08", "amount": 2100.0},
{"month": "2023-09", "amount": 2350.0},
...
]
}
说明：用于折线图

```

**GET /api/v1/statistics/category-breakdown**
```

查询参数：period=month, date
响应：
{
"data": \[
{"category\_id": 1, "name": "食品饮料", "color": "#FF8A65", "amount": 1280.0, "percentage": 45.0},
{"category\_id": 2, "name": "日用清洁", "color": "#4DB6AC", "amount": 710.0, "percentage": 25.0},
...
]
}
说明：用于饼图

```

**GET /api/v1/statistics/waste**
```

查询参数：period=month, date
响应：
{
"total\_count": 3,
"total\_amount": 47.5,
"items": \[
{"name": "有机生菜", "price": 15.8, "expired\_at": "2024-01-20", "reason": "过期未食用"},
...
],
"suggestion": "建议：减少叶菜类一次购买量"
}
说明：统计过期丢弃数据
数据来源：usage\_records type=2(丢弃) 在该时间段内

```

**GET /api/v1/statistics/consumption-ranking**
```

查询参数：period=month, limit=10
响应：
{
"data": \[
{"item\_name": "纯牛奶", "total\_consumed": 12, "unit": "盒", "total\_cost": 155.0},
{"item\_name": "抽纸", "total\_consumed": 8, "unit": "包", "total\_cost": 96.0},
...
]
}
数据来源：usage\_records type=1(使用) 按item\_id聚合

```

---

## 任务3：消耗预测服务

### prediction_service.py

**calculate_avg_daily_consumption(item_id)**
```

算法：

1. 查询该物品所有 type=1(使用) 的 usage\_records，按 created\_at 排序
2. 如果记录 < 2 条：
   - consumed = purchase\_quantity - current\_quantity
   - days = (today - item.created\_at).days
   - 如果 days <= 0：返回 0
   - 返回 consumed / days
3. 如果记录 >= 2 条：
   - 加权平均法：
   - 遍历相邻记录对(i, i+1)
   - interval\_days = (record\[i+1].created\_at - record\[i].created\_at).days
   - 如果 interval\_days <= 0：跳过
   - rate = record\[i+1].quantity / interval\_days
   - weight = i + 1（序号越大=越近=权重越高）
   - avg = sum(rate × weight) / sum(weight)
   - 返回 avg

```

**predict_empty_date(item_id)**
```

avg = calculate\_avg\_daily\_consumption(item\_id)
如果 avg <= 0：返回 None
如果 current\_quantity <= 0：返回 today
days\_remaining = current\_quantity / avg
返回 today + days\_remaining

```

**batch_update_predictions()**
```

遍历所有 status=0 的物品：
计算 avg\_daily\_consumption
计算 predicted\_empty\_date
更新 items 表
此方法由 Celery Beat 每日调用一次

```

### 预测 API

**GET /api/v1/items/{id}/prediction**
```

响应：
{
"avg\_daily\_consumption": 0.28,
"predicted\_empty\_date": "2024-02-05",
"days\_until\_empty": 10,
"confidence": "medium", // low(<3条记录)/medium(3-10条)/high(>10条)
"should\_repurchase": true,
"usage\_history": \[
{"date": "2024-01-25", "quantity": 1, "operator": "妈妈"},
...
]
}

```

---

## 任务4：智能购物推荐增强

**GET /api/v1/shopping/recommendations**
```

说明：获取系统推荐的购物项（实时计算，不存储）
逻辑：
遍历所有 status=0 物品：

1. 已低于安全库存 → 推荐（优先级高）
2. 预计7天内用完 → 推荐（优先级中）
3. 预计14天内用完 → 推荐（优先级低）

过滤掉已在购物清单中的

响应：
{
"recommendations": \[
{
"item\_id": 12,
"item\_name": "洗衣液",
"reason": "预计3天后用完",
"priority": "high",
"suggested\_quantity": 1,
"suggested\_unit": "瓶",
"last\_price": 39.9,
"last\_channel": "京东"
},
...
]
}

```

---

## 验收标准

1. ✅ 购物清单 CRUD 完整可用
2. ✅ 标记已购买状态正确更新
3. ✅ 一键入库从历史物品复制信息
4. ✅ 分享文本格式正确
5. ✅ 统计概览数据准确（金额、数量、趋势）
6. ✅ 消费趋势数据可用于折线图
7. ✅ 分类占比数据可用于饼图
8. ✅ 浪费统计正确关联丢弃记录
9. ✅ 消耗排行正确聚合
10. ✅ 预测算法输出合理的日均消耗和预计日期
11. ✅ 购物推荐逻辑正确，优先级分明
12. ✅ 批量更新预测任务正常执行
```

***

## 📋 Phase 6：文件上传 & 高级功能

```markdown
# HomeStock Server — Phase 6：文件上传 & 高级功能

## 前置条件
Phase 1-5 已完成。

## 本阶段目标
实现文件上传（图片）、条码查询服务、数据导出、WebSocket实时通信。

---

## 任务1：文件上传

### 图片上传 API

**POST /api/v1/upload/image**
```

请求：multipart/form-data，字段 file
限制：最大10MB，格式 jpg/jpeg/png/webp
逻辑：

- 校验文件类型和大小
- 压缩图片（最大宽度1080px，质量85%）
- 生成文件名：{family\_id}/{timestamp}\_{uuid}.webp
- 保存到 UPLOAD\_DIR
- 返回文件URL
  响应：{url: "/uploads/1/20240125\_abc123.webp"}

```

**POST /api/v1/upload/images**
```

说明：批量上传（最多5张）
请求：multipart/form-data，字段 files（多文件）
响应：{urls: \[...]}

```

**DELETE /api/v1/upload/image**
```

请求：{url}
逻辑：删除文件

```

### 静态文件服务
配置 FastAPI StaticFiles 挂载 /uploads 目录，供 Flutter 端访问图片。
或配置 Nginx 反向代理静态资源。

### 图片处理
使用 Pillow 库：
- 读取上传文件
- 自动旋转（根据EXIF）
- 等比缩放到最大1080px宽度
- 转为WebP格式（节省空间）
- 保存

---

## 任务2：条码查询服务

**GET /api/v1/barcode/{code}**
```

逻辑优先级：

1. 先查本地数据库：当前家庭是否已有该条码的物品
   - 有 → 返回物品信息 + "already\_exists": true
2. 查询公开商品信息API（如有对接）
   - 找到 → 返回商品名称、品牌、规格
3. 都没有 → 返回 404

响应（已存在）：
{
"already\_exists": true,
"item": { ... }
}

响应（新商品，从公开API获取）：
{
"already\_exists": false,
"product\_info": {
"name": "蒙牛纯牛奶",
"brand": "蒙牛",
"specification": "250ml",
"barcode": "6907992500867"
}
}

```

注：公开商品API可后续对接，MVP阶段只检查本地数据库即可。

---

## 任务3：数据导出

**POST /api/v1/export/items**
```

请求：{format: "csv", status\_filter: \[0,1,2,3]}
逻辑：

- 根据筛选条件查询物品
- 生成CSV文件（包含列：名称、品牌、分类、位置、单价、数量、剩余、单位、购买日期、过期日期、状态）
- 保存到临时文件
- 返回下载URL
  响应：{download\_url: "/api/v1/export/download/abc123.csv", expires\_in: 3600}

```

**GET /api/v1/export/download/{filename}**
```

说明：下载导出文件
逻辑：验证文件存在且未过期，返回文件流

```

**POST /api/v1/export/items/json**
```

说明：JSON格式完整导出（用于数据备份）
响应：完整的家庭数据JSON（物品+分类+位置+使用记录）

```

---

## 任务4：WebSocket 实时通知（可选增强）

### 实时通知 WebSocket

**WS /api/v1/ws/notifications**
```

连接时需要传 token 参数进行认证
连接后服务端推送实时事件：

事件类型：

- item\_updated: 物品信息变更（其他家庭成员操作时推送给你）
- item\_used: 物品被使用
- new\_notification: 新提醒产生
- shopping\_updated: 购物清单变更

消息格式：
{
"event": "item\_used",
"data": {
"item\_id": 123,
"item\_name": "牛奶",
"operator": "爸爸",
"quantity": 1,
"remaining": 2
},
"timestamp": "2024-01-25T10:30:00Z"
}

```

实现方式：
- 使用 FastAPI WebSocket
- 连接管理器维护 family_id → [connections] 映射
- 当有操作发生时，向同家庭其他在线设备广播
- 支持心跳检测（30秒一次ping/pong）
- 断线自动清理

---

## 任务5：用户设置 & 个人信息

**GET /api/v1/users/me**
```

响应：完整用户信息 + 当前家庭信息 + 通知偏好

```

**PUT /api/v1/users/me**
```

请求：{nickname, avatar\_url, email}

```

**PUT /api/v1/users/me/password**
```

请求：{old\_password, new\_password}
逻辑：验证旧密码 → 更新新密码hash

```

**DELETE /api/v1/users/me**
```

说明：注销账户
逻辑：

- 如果是家庭owner且家庭有其他成员 → 拒绝（先转让）
- 否则：软删除用户 + 退出所有家庭

```

---

## 任务6：健康检查 & 管理接口

**GET /api/v1/health**
```

响应：
{
"status": "ok",
"database": "connected",
"redis": "connected",
"version": "1.0.0",
"uptime": "3d 12h 30m"
}
无需认证

```

**GET /api/v1/admin/stats**（仅开发环境）
```

响应：系统级统计
{
"total\_users": 150,
"total\_families": 80,
"total\_items": 5600,
"active\_today": 45
}

```

---

## 任务7：API 限流 & 安全

### 限流规则
使用 slowapi 或 Redis 实现：
- 登录接口：每IP 10次/分钟（防暴力破解）
- 注册接口：每IP 5次/小时
- 普通接口：每用户 60次/分钟
- 上传接口：每用户 20次/分钟

### 安全措施
- 密码强度校验：至少8位，包含字母和数字
- SQL注入防护：ORM参数化查询（SQLAlchemy默认安全）
- XSS防护：Pydantic 自动转义
- 文件上传：类型检查 + 文件头校验（防伪造扩展名）
- 敏感信息：响应中不返回 password_hash

---

## 验收标准

1. ✅ 图片上传成功，压缩和格式转换正确
2. ✅ 上传后图片可通过URL正常访问
3. ✅ 条码查询：已有物品返回信息，没有返回404
4. ✅ CSV导出文件格式正确，可用Excel打开
5. ✅ JSON完整导出包含所有家庭数据
6. ✅ WebSocket连接正常，能收到其他成员操作的实时推送
7. ✅ WebSocket断线重连后恢复正常
8. ✅ 用户信息修改/密码修改正常
9. ✅ 健康检查接口正确返回服务状态
10. ✅ 限流生效：超出频率返回429
11. ✅ 上传非法文件类型被拒绝
```

***

## 📋 Phase 7：部署 & 上线准备

```markdown
# HomeStock Server — Phase 7：部署 & 上线准备

## 前置条件
Phase 1-6 功能开发完成。

## 本阶段目标
生产环境配置、Docker部署优化、日志监控、API文档完善。

---

## 任务1：生产环境配置

### 环境变量区分
- .env.development（本地开发）
- .env.production（生产环境）

### 生产配置要点
```

DEBUG=false
LOG\_LEVEL=INFO
DATABASE\_URL=（生产数据库地址）
REDIS\_URL=（生产Redis地址）
JWT\_SECRET\_KEY=（生产环境强密钥，至少32位随机字符）
CORS\_ORIGINS=\["https\://你的域名"]（限制来源）

````

### Dockerfile 优化
- 多阶段构建（减小镜像体积）
- 非root用户运行
- 健康检查指令

### docker-compose.production.yml
- 去掉开发模式热重载
- 添加 restart: always
- 配置日志大小限制
- uvicorn workers 数量 = CPU核心数 × 2 + 1
- 添加 Nginx 作为反向代理

---

## 任务2：Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # API 代理
    location /api/ {
        proxy_pass http://app:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket 代理
    location /api/v1/ws/ {
        proxy_pass http://app:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 静态文件（上传的图片）
    location /uploads/ {
        alias /data/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 文件大小限制
    client_max_body_size 10M;
}
````

***

## 任务3：日志系统

### 日志配置

- 使用 Python logging 模块
- 格式：JSON格式（方便后续接入日志系统）
- 级别：开发INFO，生产WARNING
- 输出：同时输出到 stdout 和文件
- 文件轮转：每天一个文件，保留30天

### 关键日志点

- 每个API请求：method, path, status, duration, user\_id
- 认证失败：IP, 尝试的手机号
- 数据库异常
- Celery任务执行结果
- 推送通知结果

***

## 任务4：数据库备份

创建备份脚本 scripts/backup.sh：

- 使用 pg\_dump 导出数据库
- 压缩为 .gz 文件
- 文件名含日期：homestock\_20240125.sql.gz
- 保留最近30天的备份
- 可通过 crontab 每日执行

***

## 任务5：API 文档完善

确保 Swagger UI (/docs) 中：

- 每个接口有清晰的中文描述（summary + description）
- 请求/响应示例（example）
- 参数说明完整
- 错误码说明
- 接口分组（tags）清晰：
  - 认证（Auth）
  - 用户（Users）
  - 家庭（Families）
  - 物品（Items）
  - 分类（Categories）
  - 位置（Locations）
  - 使用记录（Usage Records）
  - 购物清单（Shopping）
  - 提醒通知（Notifications）
  - 统计（Statistics）
  - 文件（Upload）

***

## 任务6：自动化测试（核心链路）

至少覆盖以下核心场景的测试：

- 注册 → 登录 → 获取Token
- 创建物品 → 查询 → 记录使用 → 数量更新
- 过期检查逻辑
- 消耗预测计算
- 权限控制（member不能删除）
- 数据隔离（不同家庭看不到对方数据）

使用 pytest + httpx (async)，conftest 中配置测试数据库。

***

## 验收标准

1. ✅ docker-compose -f docker-compose.production.yml up 一键启动
2. ✅ Nginx 正确代理API和WebSocket
3. ✅ 图片通过Nginx直接返回（不经过Python）
4. ✅ 日志正确输出到文件和stdout
5. ✅ 数据库备份脚本可正确执行
6. ✅ Swagger文档清晰完整
7. ✅ 核心测试用例全部通过
8. ✅ 限流在生产配置下生效
9. ✅ 非CORS白名单的请求被拒绝
10. ✅ 服务重启后自动恢复（restart: always）

```

---

## 各 Phase 关系总览

```

Phase 1：骨架 → 能跑、能登录
Phase 2：核心API → Flutter能增删改查物品
Phase 3：家庭协作 → 多人共享数据
Phase 4：提醒推送 → 到期推送、定时任务
Phase 5：智能功能 → 预测、统计、推荐
Phase 6：高级功能 → 文件、实时通信、导出
Phase 7：部署上线 → 生产可用

依赖关系：
1 → 2 → 3 → 4 → 5 → 6 → 7（严格顺序）

```

---

## 给 Trae 的使用建议

| 阶段 | 喂给 Trae 时 | 补充说明 |
|------|-------------|---------|
| Phase 1 | 整段给 | 可能需要帮它解决 alembic async 配置问题 |
| Phase 2 | 分两次：模型建表 + API实现 | 表多，一次可能太长 |
| Phase 3 | 整段给 | 逻辑不复杂但细节多 |
| Phase 4 | 分两次：Celery配置 + 推送服务 | Celery配置容易出问题 |
| Phase 5 | 分两次：购物清单API + 统计API | |
| Phase 6 | 分三次：文件上传 + WebSocket + 其余 | WebSocket最容易出bug |
| Phase 7 | 整段给 | 主要是配置文件 |

需要我为 Flutter 端补充一份**「对接服务端 API」的改造提示词**吗？（把之前纯本地存储改为调用API）
```

