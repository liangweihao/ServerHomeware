# 启动脚本与环境变量统一整理

## 目标

用户仅使用 `./start.sh prod`，删除多套启动脚本与 `.env.*` 分散配置。

## 改动

### 启动脚本

| 操作 | 文件 |
|------|------|
| 保留并合并 | `start.sh`（含原 start-prod 全部能力） |
| 删除 | `start-dev.sh`、`start-prod.sh` |

**用法：**
```bash
./start.sh          # 后台守护
./start.sh prod     # 同上
./start.sh restart
./start.sh stop
./start.sh status
./start.sh foreground
```

### 环境变量

| 操作 | 文件 |
|------|------|
| 保留 | `.env`（本地真实配置，gitignore） |
| 保留 | `.env.example`（统一模板，已合并 SQLite/Redis/DeepSeek 等） |
| 删除 | `.env.dev`、`.env.production`、`.env.production.example`、`.env.development` |

### 其它

- `.gitignore`：仅忽略 `.env`
- `docker-compose.production.yml` / `docker-compose.backup.yml`：`env_file` 改为 `.env`
- `CLAUDE.md`：更新启动说明

## 迁移步骤

**本地（已有 `.env`）：** 无需改文件，直接：
```bash
cd HomeWareServer
./start.sh restart
```

**服务器（原用 `.env.production`）：**
```bash
# 若只有 .env.production，合并到 .env
cp .env.production .env   # 或手动合并 DEEPSEEK/JWT/DATABASE_URL
./start.sh restart
```

**新环境：**
```bash
cp .env.example .env
# 编辑 JWT_SECRET_KEY、DEEPSEEK_API_KEY、DATABASE_URL
./start.sh prod
```

## 验证

- 启动日志：`DeepSeek: sk-xxxx... 已加载`、`数据库: sqlite+...`
- App 重新登录后问管管可用
- `alembic upgrade head` 无 5432 连接错误

## 影响范围

- 后端启动与 Docker compose 环境文件路径
- 不再支持 `./start-dev.sh` / `ENV_FILE=.env.dev`
