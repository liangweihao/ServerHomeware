# Phase 1 基础骨架实现计划

## 项目现状分析

当前项目已完成基本结构搭建，服务器可通过开发模式启动，但仍有以下问题需要完善：

| 任务 | 状态 | 问题 |
|------|------|------|
| 环境配置 | 已完成 | 部分配置需要验证 |
| 数据库连接 | 部分完成 | SQLite开发模式可用，PostgreSQL连接失败 |
| 用户/家庭模型 | 已完成 | 需要验证完整性 |
| 认证系统 | 部分完成 | Redis不可用时登出功能受限 |
| 通用响应格式 | 已完成 | 已修复PaginatedData顺序问题 |
| 异常处理 | 已完成 | 需要验证 |
| 中间件 | 已完成 | 需要验证CORS配置 |
| main.py入口 | 已完成 | 需要优化启动流程 |
| Alembic迁移 | 部分完成 | SQLite模式跳过迁移 |
| Docker化 | 已完成 | 需要验证docker-compose |

## 实施计划

### 任务1：完善数据库配置

**目标：** 确保 PostgreSQL 和 SQLite 模式都能正常工作

**步骤：**
1. 修改 database.py，支持动态数据库URL配置
2. 修改 config.py，支持从环境变量选择数据库类型
3. 确保 SQLite 开发模式下无需 PostgreSQL

**文件：**
- `app/core/database.py`
- `app/config.py`
- `.env.dev`

---

### 任务2：验证模型完整性

**目标：** 确保 User、Family、FamilyMember 模型符合设计规范

**步骤：**
1. 检查模型字段是否完整
2. 验证关系定义是否正确
3. 修复缺失的 relationship 导入

**文件：**
- `app/models/user.py`
- `app/models/family.py`

---

### 任务3：完善认证系统

**目标：** 确保所有认证接口正常工作

**步骤：**
1. 测试注册接口（自动创建家庭）
2. 测试登录接口（密码验证、last_login_at更新）
3. 测试刷新Token接口
4. 测试登出接口（Redis不可用时优雅降级）

**文件：**
- `app/api/v1/auth.py`
- `app/services/auth_service.py`
- `app/core/dependencies.py`

---

### 任务4：完善异常处理和中间件

**目标：** 确保全局异常处理和日志记录正常

**步骤：**
1. 验证自定义异常类
2. 验证请求日志中间件
3. 验证CORS配置（支持Flutter App）
4. 验证全局异常处理器

**文件：**
- `app/core/exceptions.py`
- `app/core/middleware.py`
- `app/main.py`

---

### 任务5：完善 Alembic 迁移

**目标：** 确保数据库迁移在两种模式下都能正常执行

**步骤：**
1. 修复 SQLite 迁移脚本
2. 确保 PostgreSQL 迁移正常
3. 更新启动脚本支持迁移

**文件：**
- `alembic/env.py`
- `alembic/versions/0001_initial_migration.py`
- `start-dev.sh`

---

### 任务6：验证 Docker 配置

**目标：** 确保 docker-compose 能一键启动所有服务

**步骤：**
1. 验证 Dockerfile
2. 验证 docker-compose.yml
3. 测试完整的容器化部署

**文件：**
- `Dockerfile`
- `docker-compose.yml`

---

## 验收标准

| 标准 | 描述 |
|------|------|
| 服务启动 | 开发模式和Docker模式都能正常启动 |
| API文档 | 访问 `/docs` 可以看到完整的Swagger文档 |
| 用户注册 | 手机号+密码注册成功，自动创建默认家庭 |
| 用户登录 | 正确密码登录成功，错误密码返回401 |
| Token刷新 | 用refresh_token获取新access_token |
| 受保护接口 | 不带token返回401，带正确token正常访问 |
| 请求日志 | 每个请求都有日志记录 |
| CORS配置 | Flutter App可以正常访问 |

## 风险处理

1. **数据库连接失败**：开发模式自动切换到SQLite，生产模式需要确保PostgreSQL可用
2. **Redis不可用**：认证功能优雅降级，登出时跳过黑名单操作
3. **端口占用**：启动脚本检测并释放占用端口

---

## 执行顺序

1. 任务1：完善数据库配置
2. 任务2：验证模型完整性
3. 任务3：完善认证系统
4. 任务4：完善异常处理和中间件
5. 任务5：完善 Alembic 迁移
6. 任务6：验证 Docker 配置

---

**创建时间：** 2026-05-22
**版本：** v1.0