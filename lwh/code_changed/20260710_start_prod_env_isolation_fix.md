# 生产启动脚本环境变量隔离修复

## 问题

服务器 `./start-prod.sh` 迁移时报错：

```
OSError: Connect call failed ('127.0.0.1', 5432)
```

根因：`start-prod.sh` 先 `export` 了开发用 `.env`（含 `postgresql+asyncpg://...@localhost:5432`），而 `.env.production` 若只加了 DeepSeek 未写 `DATABASE_URL`，Alembic 仍连 PostgreSQL。

## 改动

1. **`start-prod.sh`**：生产环境**仅**加载 `.env.production`（不再读 `.env`）；缺失时从 `.env.production.example` 复制并提示编辑。
2. **新增 `.env.production.example`**：含 SQLite 默认库、Redis 本机地址、DeepSeek 占位符，可提交 Git。

## 服务器修复步骤

```bash
cd /root/ServerHomeware/HomeWareServer
git pull

# 若尚无 .env.production，从模板复制
cp .env.production.example .env.production

# 编辑：JWT_SECRET_KEY、DEEPSEEK_API_KEY 等
nano .env.production
# 确认含：DATABASE_URL=sqlite+aiosqlite:///./homestock_prod.db

source .venv/bin/activate
export ENV_FILE=.env.production
python -m alembic upgrade head

./start-prod.sh restart
```

## 验证

- `alembic upgrade head` 无 5432 连接错误
- `curl http://127.0.0.1:8000/api/v1/health`（或登录接口）正常
- 问管管对话可用

## 影响范围

- 仅 `start-prod.sh` 生产启动路径
- `start-dev.sh` 仍使用 `.env`，不受影响
