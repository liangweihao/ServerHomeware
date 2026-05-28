#!/bin/bash

# HomeStock Server 开发模式启动脚本
# 使用 SQLite 作为数据库，无需 PostgreSQL 和 Redis
#
# Windows 用户请用 PowerShell 运行: .\start-dev.ps1
# （.sh 需要 Git Bash / WSL / macOS / Linux，在 Windows 下双击通常无反应）

set -e
kill -9 $(lsof -ti:8000) 2>/dev/null
sleep 1
echo "=========================================="
echo "   HomeStock Server 开发模式启动脚本"
echo "=========================================="
echo "注意: 此模式使用 SQLite 数据库，适合开发测试"
echo "=========================================="

# 检查是否在正确的目录
if [ ! -f "app/main.py" ]; then
    echo "错误: 请在 HomeWareServer 目录下运行此脚本"
    exit 1
fi

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请先安装 Python"
    exit 1
fi

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "创建虚拟环境..."
    python3 -m venv .venv
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source .venv/bin/activate

# 检查并安装依赖
echo "检查依赖..."
if [ ! -f ".venv/lib/python*/site-packages/fastapi/__init__.py" ]; then
    echo "安装依赖..."
    echo "使用国内镜像源加速安装..."
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple aioredis  # 用于模拟 Redis
fi

# 设置 PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$(pwd)

# 创建开发环境配置
echo "创建开发环境配置..."
cat > .env.dev << 'EOF'
APP_NAME=HomeStock
APP_ENV=development
DEBUG=true
API_PREFIX=/api/v1

# 使用 SQLite
DATABASE_URL=sqlite+aiosqlite:///./homestock.db

# Redis 配置（开发模式可以为空）
REDIS_URL=redis://localhost:6379/0

JWT_SECRET_KEY=dev-secret-key-for-development-only-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30

UPLOAD_DIR=./uploads
MAX_FILE_SIZE_MB=10
FCM_SERVER_KEY=
EOF

# 设置环境变量指向开发配置
export ENV_FILE=.env.dev

# 创建数据库文件目录
mkdir -p ./data

# 创建 SQLite 数据库迁移
echo "创建 SQLite 数据库迁移..."
python3 -c "
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.core.database import Base
from app.models import *

async def create_tables():
    engine = create_async_engine('sqlite+aiosqlite:///./homestock.db')
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await engine.dispose()
    print('数据库表创建成功')

asyncio.run(create_tables())
"

# 启动服务器
echo ""
echo "启动 FastAPI 开发服务器..."
echo "服务器将在 http://localhost:8000 运行"
echo "API 文档: http://localhost:8000/docs"
echo "数据库: SQLite (homestock.db)"
echo ""
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload