#!/bin/bash
# ===========================================
#  HomeStock 开发环境启动脚本
#  - SQLite 数据库（无需 PostgreSQL/Redis）
#  - 热重载（--reload）
#  - Debug 日志
# ===========================================
set -e

echo "=========================================="
echo "   HomeStock 开发环境启动"
echo "=========================================="

cd "$(dirname "$0")"

# --- Python 检测 ---
PYTHON=""
if command -v python3 &> /dev/null; then
    PYTHON="python3"
elif command -v python &> /dev/null; then
    PYTHON="python"
else
    echo "错误: 未找到 Python"
    exit 1
fi

# --- 虚拟环境 ---
if [ ! -d ".venv" ]; then
    echo "创建虚拟环境..."
    $PYTHON -m venv .venv
fi

echo "激活虚拟环境..."
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    VENV_PYTHON=".venv/bin/python"
elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
    VENV_PYTHON=".venv/Scripts/python"
else
    echo "错误: 虚拟环境创建失败"
    exit 1
fi
PYTHON="$VENV_PYTHON"

# --- 依赖 ---
echo "检查依赖..."
if ! "$PYTHON" -c "import fastapi" &> /dev/null; then
    echo "安装依赖..."
    pip install -r requirements.txt
fi

# --- 设置开发环境变量 ---
export ENV_FILE=.env.dev
export PYTHONPATH="$(cd . && pwd -W 2>/dev/null || pwd):$PYTHONPATH"

# --- 数据库迁移 ---
echo "检查数据库..."
DB_URL=$("$PYTHON" -c "from app.config import settings; print(settings.DATABASE_URL)" 2>/dev/null || echo "")
if [ -n "$DB_URL" ]; then
    if [[ "$DB_URL" == sqlite* ]]; then
        echo "使用 SQLite: $DB_URL"
    fi
    echo "运行数据库迁移..."
    "$PYTHON" -m alembic upgrade head || echo "警告: 迁移失败，继续启动..."
else
    echo "警告: 无法读取数据库配置，跳过迁移"
fi

# --- 杀掉旧进程（端口复用） ---
DEV_PORT=8000
echo "检查端口 $DEV_PORT..."
OLD_PID=$(lsof -ti:$DEV_PORT 2>/dev/null || true)
if [ -n "$OLD_PID" ]; then
    echo "杀掉旧进程 (PID: $OLD_PID)..."
    kill -9 $OLD_PID 2>/dev/null || true
    sleep 1
fi

# --- 启动 ---
echo ""
echo "=========================================="
echo "  服务器: http://localhost:$DEV_PORT"
echo "  API文档: http://localhost:$DEV_PORT/docs"
echo "=========================================="
"$PYTHON" -m uvicorn app.main:app --host 0.0.0.0 --port $DEV_PORT --reload
