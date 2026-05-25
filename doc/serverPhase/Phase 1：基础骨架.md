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
home_stock_server/
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env.example
├── alembic.ini
├── alembic/
│   └── versions/
│
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI 应用入口
│   ├── config.py                  # 配置管理（环境变量）
│   │
│   ├── core/                      # 核心模块
│   │   ├── __init__.py
│   │   ├── database.py            # 数据库连接/会话
│   │   ├── redis.py               # Redis 连接
│   │   ├── security.py            # JWT/密码加密
│   │   ├── dependencies.py        # FastAPI 依赖注入
│   │   ├── exceptions.py          # 自定义异常
│   │   └── middleware.py          # 中间件
│   │
│   ├── models/                    # SQLAlchemy 模型
│   │   ├── __init__.py
│   │   ├── base.py                # 基础模型类
│   │   ├── user.py
│   │   ├── family.py
│   │   ├── item.py
│   │   ├── category.py
│   │   ├── location.py
│   │   ├── usage_record.py
│   │   └── shopping.py
│   │
│   ├── schemas/                   # Pydantic 请求/响应模型
│   │   ├── __init__.py
│   │   ├── common.py              # 通用响应格式
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── family.py
│   │   ├── item.py
│   │   ├── category.py
│   │   ├── location.py
│   │   ├── usage_record.py
│   │   └── shopping.py
│   │
│   ├── api/                       # 路由/接口
│   │   ├── __init__.py
│   │   ├── router.py              # 总路由注册
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── auth.py
│   │       ├── users.py
│   │       ├── families.py
│   │       ├── items.py
│   │       ├── categories.py
│   │       ├── locations.py
│   │       ├── usage_records.py
│   │       ├── shopping.py
│   │       ├── alerts.py
│   │       ├── statistics.py
│   │       └── upload.py
│   │
│   ├── services/                  # 业务逻辑层
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── user_service.py
│   │   ├── family_service.py
│   │   ├── item_service.py
│   │   ├── category_service.py
│   │   ├── location_service.py
│   │   ├── usage_service.py
│   │   ├── shopping_service.py
│   │   ├── alert_service.py
│   │   ├── statistics_service.py
│   │   ├── prediction_service.py
│   │   └── notification_service.py
│   │
│   ├── repositories/              # 数据访问层
│   │   ├── __init__.py
│   │   ├── base.py                # 通用 CRUD 基类
│   │   ├── user_repo.py
│   │   ├── family_repo.py
│   │   ├── item_repo.py
│   │   ├── category_repo.py
│   │   ├── location_repo.py
│   │   ├── usage_record_repo.py
│   │   └── shopping_repo.py
│   │
│   ├── tasks/                     # Celery 异步任务
│   │   ├── __init__.py
│   │   ├── celery_app.py
│   │   ├── expiry_check.py
│   │   ├── prediction_update.py
│   │   └── notification_push.py
│   │
│   └── utils/                     # 工具
│       ├── __init__.py
│       ├── datetime_utils.py
│       └── file_utils.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_auth.py
│
└── scripts/
    └── seed_data.py              # 预设数据初始化脚本
```

---

## 任务2：环境配置

### .env.example
```
# App
APP_NAME=HomeStock
APP_ENV=development
DEBUG=true
API_PREFIX=/api/v1

# Database
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/homestock

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
JWT_SECRET_KEY=your-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE_MB=10

# FCM (Firebase Cloud Messaging)
FCM_SERVER_KEY=your-fcm-key
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
Response: {user, access_token, refresh_token}
逻辑：检查手机号唯一 → 创建用户 → 自动创建默认家庭 → 返回token
```

**POST /api/v1/auth/login**
```
Request: {phone, password}
Response: {user, access_token, refresh_token}
逻辑：验证手机号密码 → 更新last_login_at → 返回token
```

**POST /api/v1/auth/refresh**
```
Request: {refresh_token}
Response: {access_token, refresh_token}
逻辑：验证refresh_token有效 → 签发新token对
```

**POST /api/v1/auth/logout**
```
Header: Authorization: Bearer {access_token}
逻辑：将当前token加入Redis黑名单（TTL=剩余有效期）
```

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
```

创建通用的 ResponseSchema、PaginatedResponseSchema、ErrorResponseSchema。

---

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

---

## 任务8：main.py 入口

- 创建 FastAPI 实例
- 注册所有路由
- 注册中间件
- startup 事件：连接数据库、连接 Redis
- shutdown 事件：关闭连接
- 启用 Swagger UI (路径 /docs)

---

## 任务9：Alembic 数据迁移

- 初始化 Alembic（async 模式）
- 生成第一个 migration（包含 users、families、family_members 三张表）
- 确保 alembic upgrade head 可以成功建表

---

## 任务10：Docker 化

### Dockerfile

- 基于 python:3.11-slim
- 安装依赖
- 复制代码
- uvicorn 启动

### docker-compose.yml

一键启动所有服务，开发时可以 docker-compose up 即可运行完整环境。

---

## 验收标准

1. ✅ docker-compose up 后所有服务正常启动
2. ✅ 访问 /docs 可以看到 Swagger 文档
3. ✅ 注册接口：手机号+密码注册成功，返回用户信息和token
4. ✅ 登录接口：正确密码登录成功，错误密码返回401
5. ✅ Token刷新：用refresh_token获取新access_token
6. ✅ 受保护接口：不带token返回401，带正确token返回用户信息
7. ✅ 注册时自动创建默认家庭
8. ✅ 数据库迁移正常执行
9. ✅ 请求日志正常打印
10. ✅ CORS 配置正确（Flutter App可以访问）