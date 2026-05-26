#!/bin/bash

# HomeStock Server 启动脚本
# 使用方法: ./start_server.sh

# 配置
PORT=8000
VENV_PATH="./HomeWareServer/.venv"
SERVER_DIR="./HomeWareServer"
HOST="0.0.0.0"

echo "========================================"
echo "     HomeStock Server 启动脚本"
echo "========================================"

# 强制关闭占用端口的进程
echo "🔌 检查并关闭占用端口 $PORT 的进程..."
PID=$(lsof -ti:$PORT)
if [ -n "$PID" ]; then
    echo "    发现进程 $PID 占用端口 $PORT，正在强制关闭..."
    kill -9 "$PID" 2>/dev/null
    sleep 1
    # 再次检查是否关闭成功
    PID=$(lsof -ti:$PORT)
    if [ -n "$PID" ]; then
        echo "    ❌ 无法关闭进程 $PID"
        exit 1
    else
        echo "    ✅ 进程已关闭"
    fi
else
    echo "    ✅ 端口 $PORT 未被占用"
fi

# 检查是否存在虚拟环境
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ 虚拟环境不存在: $VENV_PATH"
    echo "   请先创建虚拟环境: python -m venv $VENV_PATH"
    exit 1
fi

# 激活虚拟环境
echo "📦 激活虚拟环境..."
source "$VENV_PATH/bin/activate"

# 安装依赖（如果需要）
echo "📥 安装依赖..."
pip install -q aiosqlite

# 启动服务
echo "🚀 启动服务端..."
echo "服务地址: http://$HOST:$PORT"
echo "API文档: http://$HOST:$PORT/docs"
echo "========================================"

cd "$SERVER_DIR" && python -m uvicorn app.main:app --host "$HOST" --port "$PORT" --reload