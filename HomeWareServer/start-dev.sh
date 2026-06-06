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
SCRIPT_DIR="$(pwd)"

# --- Python 环境检测（兼容腾讯云等各种环境） ---
_FOUND_PYTHON=""
_detect_python() {
    for cmd in python3.12 python3.11 python3.10 python3.9 python3 python; do
        if command -v "$cmd" &> /dev/null; then
            local ver=$("$cmd" --version 2>&1) || continue
            if echo "$ver" | grep -qi "python"; then
                _FOUND_PYTHON="$cmd"
                echo "  找到 Python: $cmd ($ver)"
                return 0
            fi
        fi
    done
    return 1
}

if ! _detect_python; then
    echo "错误: 未找到 Python，请安装 Python 3.9+"
    exit 1
fi

# 确保 pip
if ! "$_FOUND_PYTHON" -m pip --version &> /dev/null; then
    echo "安装 pip..."
    "$_FOUND_PYTHON" -m ensurepip --upgrade 2>/dev/null || true
fi

# --- 虚拟环境 ---
if [ ! -d ".venv" ]; then
    echo "创建虚拟环境..."
    "$_FOUND_PYTHON" -m venv .venv 2>/dev/null || {
        "$_FOUND_PYTHON" -m pip install virtualenv -q 2>/dev/null || true
        "$_FOUND_PYTHON" -m virtualenv .venv
    }
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
    echo "安装依赖（使用清华镜像源）..."
    "$PYTHON" -m pip install --upgrade pip -q 2>/dev/null || true
    "$PYTHON" -m pip install \
        -i https://pypi.tuna.tsinghua.edu.cn/simple \
        -r requirements.txt || {
        echo "  清华源失败，使用默认源..."
        "$PYTHON" -m pip install -r requirements.txt
    }
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
