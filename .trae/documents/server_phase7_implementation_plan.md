# Server Phase 7：部署 & 上线准备 - 实施计划

## 需求分析

根据 Phase 7 文档，需要实现生产环境部署和上线准备。

### 当前状态
- ✅ 已有基础 Dockerfile（单阶段构建、dev模式）
- ✅ 已有开发 docker-compose.yml
- ✅ 基础日志配置在 main.py 中
- ⚠️ 缺少生产环境配置
- ⚠️ 缺少 Nginx 配置
- ⚠️ 缺少日志优化

---

## 任务清单

### 任务1：生产环境配置

| 子任务 | 说明 |
|--------|------|
| 创建 .env.development | 本地开发环境配置 |
| 创建 .env.production | 生产环境配置模板 |
| 更新 app/config.py | 添加生产配置支持 |

### 任务2：Docker 优化

| 子任务 | 说明 |
|--------|------|
| 优化 Dockerfile | 多阶段构建、非root用户、健康检查 |
| 创建 docker-compose.production.yml | 生产环境编排 |
| 配置 Nginx | 反向代理、WebSocket、静态文件 |

### 任务3：日志系统

| 子任务 | 说明 |
|--------|------|
| 创建 app/core/logger.py | 完善日志配置 |
| JSON格式输出 | 便于监控系统分析 |
| 文件轮转 | 每天一个文件，保留30天 |

### 任务4：数据库备份

| 子任务 | 说明 |
|--------|------|
| 创建 scripts/backup.sh | PostgreSQL 备份脚本 |
| 创建 docker-compose.backup.yml | 备份服务编排 |

### 任务5：API 文档完善

| 子任务 | 说明 |
|--------|------|
| 检查并完善各API路由 | 添加清晰的中文描述 |
| 验证接口分组 | tags 是否正确 |

---

## 文件清单

### 新增文件

| 文件路径 | 说明 |
|----------|------|
| .env.development | 开发环境配置 |
| .env.production | 生产环境配置模板 |
| app/core/logger.py | 日志配置模块 |
| scripts/backup.sh | 数据库备份脚本 |
| docker-compose.production.yml | 生产编排 |
| docker-compose.backup.yml | 备份服务编排 |
| nginx/nginx.conf | Nginx配置 |
| nginx/Dockerfile | Nginx镜像 |

### 修改文件

| 文件路径 | 说明 |
|----------|------|
| requirements.txt | 添加日志库（python-json-logger） |
| app/config.py | 添加日志和生产环境配置 |
| app/main.py | 集成新的日志系统 |
| Dockerfile | 优化为多阶段构建 |

---

## 详细实现步骤

### 步骤1：创建环境变量配置

#### .env.development
```
DEBUG=true
LOG_LEVEL=DEBUG
APP_NAME=HomeStock Dev
API_PREFIX=/api/v1
DATABASE_URL=postgresql+asyncpg://postgres:password@db:5432/homestock
REDIS_URL=redis://redis:6379/0
JWT_SECRET_KEY=dev_secret_key_change_in_production_32_chars
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE_MB=10
CORS_ORIGINS=["*"]
```

#### .env.production
```
DEBUG=false
LOG_LEVEL=WARNING
APP_NAME=HomeStock
API_PREFIX=/api/v1
DATABASE_URL=postgresql+asyncpg://user:password@db:5432/homestock
REDIS_URL=redis://redis:6379/0
JWT_SECRET_KEY=（生产密钥，至少32位）
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE_MB=10
CORS_ORIGINS=["https://your-domain.com"]
```

### 步骤2：完善 requirements.txt

添加：
- python-json-logger==2.0.7

### 步骤3：创建日志系统

创建 app/core/logger.py
- JSON 日志格式
- 同时输出到 stdout 和文件
- 文件轮转配置（TimedRotatingFileHandler）

### 步骤4：优化 Dockerfile

多阶段构建：
1. builder 阶段：安装依赖
2. final 阶段：只复制必要文件
- 创建非 root 用户
- 添加 HEALTHCHECK
- 使用 gunicorn + uvicorn workers

### 步骤5：创建 docker-compose.production.yml

- app：多 worker 启动，restart: always，日志限制
- db：数据持久化，健康检查
- redis：数据持久化
- nginx：反向代理，静态文件
- celery_worker/celery_beat：后台任务
- volumes：uploads 持久化

### 步骤6：配置 Nginx

创建 nginx/nginx.conf 和 nginx/Dockerfile：
- API 代理 /api/
- WebSocket 代理 /api/v1/ws/
- 静态文件 /uploads/
- 限流配置
- 文件大小限制 10M

### 步骤7：创建数据库备份脚本

scripts/backup.sh：
- pg_dump 导出
- gzip 压缩
- 保留 30 天
- 输出到 /backups/

### 步骤8：完善 API 文档

检查各路由模块，确保：
- 每个接口有 summary 和 description
- tags 分组清晰
- 示例数据完整

---

## 验收标准

1. ✅ docker-compose -f docker-compose.production.yml up 一键启动
2. ✅ Nginx 正确代理API和WebSocket
3. ✅ 图片通过Nginx直接返回
4. ✅ 日志正确输出到文件和stdout（JSON格式）
5. ✅ 数据库备份脚本可正确执行
6. ✅ Swagger文档清晰完整
7. ✅ 服务重启后自动恢复
8. ✅ 非CORS白名单请求被拒绝

---

## 风险与注意事项

1. **JWT密钥安全**：生产环境必须使用强随机密钥
2. **数据持久化**：确保 volumes 配置正确
3. **日志磁盘占用**：配置文件轮转避免磁盘满
4. **WebSocket代理**：确保 nginx 的 upgrade 配置正确
