#!/bin/bash
# ===========================================
#  HomeStock 生产环境启动脚本
#  - 需要 PostgreSQL + Redis
#  - gunicorn + uvicorn workers
#  - 支持后台守护 / systemd / 前台运行
#
#  用法：
#    ./start-prod.sh             前台运行（Ctrl+C 停止）
#    ./start-prod.sh --daemon    后台守护（关终端不断开）
#    ./start-prod.sh stop        停止后台进程
#    ./start-prod.sh restart     重启后台进程
#    ./start-prod.sh status      查看状态
# ===========================================
set -e

cd "$(dirname "$0")"

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
WORKERS="${WORKERS:-4}"
PID_FILE="logs/gunicorn.pid"
LOG_DIR="logs"

# --- 加载环境 ---
if [ -f ".env.production" ]; then
    export $(grep -v '^#' .env.production | xargs)
fi
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# --- Python ---
PYTHON="${PYTHON:-python3}"
if ! command -v "$PYTHON" &> /dev/null; then
    echo "错误: 未找到 $PYTHON"
    exit 1
fi

# --- 虚拟环境 ---
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
fi

# --- 依赖 ---
if ! python -c "import fastapi" &> /dev/null; then
    echo "安装依赖..."
    pip install -r requirements.txt
fi

# --- 目录 ---
mkdir -p logs uploads

# --- 杀掉旧进程（避免端口冲突） ---
_kill_old() {
    echo "检查端口 $PORT..."
    # 先尝试用 PID 文件
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null || true)
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            echo "杀掉旧进程 (PID: $OLD_PID)..."
            kill "$OLD_PID" 2>/dev/null || true
            sleep 2
            kill -9 "$OLD_PID" 2>/dev/null || true
            rm -f "$PID_FILE"
        fi
    fi
    # 再用端口查一次
    PORT_PID=$(lsof -ti:$PORT 2>/dev/null || true)
    if [ -n "$PORT_PID" ]; then
        echo "杀掉占用端口进程 (PID: $PORT_PID)..."
        kill -9 $PORT_PID 2>/dev/null || true
        sleep 1
    fi
}

# --- 数据库迁移 ---
_do_migrate() {
    export PYTHONPATH="$(pwd):$PYTHONPATH"
    echo "运行数据库迁移..."
    python -m alembic upgrade head
}

# --- Gunicorn 参数 ---
_GUNICORN_ARGS=(
    -m 007  # 新建文件的默认权限
    --worker-class uvicorn.workers.UvicornWorker
    --bind "$HOST:$PORT"
    --workers "$WORKERS"
    --access-logfile "$LOG_DIR/access.log"
    --error-logfile "$LOG_DIR/error.log"
    --log-level warning
    --timeout 120
)

# --- 命令路由 ---
case "${1:-start}" in
    --daemon|-d|daemon)
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 后台守护模式"
        echo "  地址: http://$HOST:$PORT"
        echo "  Workers: $WORKERS"
        echo "  PID: $PID_FILE"
        echo "  停止: ./start-prod.sh stop"
        echo "=========================================="
        python -m gunicorn app.main:app \
            "${_GUNICORN_ARGS[@]}" \
            --daemon \
            --pid "$PID_FILE"
        echo "已启动 (PID: $(cat "$PID_FILE" 2>/dev/null || echo 'unknown'))"
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "停止 HomeStock (PID: $PID)..."
            kill "$PID" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "已停止"
        else
            echo "未找到 PID 文件，尝试查找进程..."
            pkill -f "gunicorn app.main:app" && echo "已停止" || echo "未找到运行中的进程"
        fi
        ;;

    restart)
        "$0" stop
        sleep 2
        "$0" --daemon
        ;;

    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo "HomeStock 运行中 (PID: $PID)"
                exit 0
            else
                echo "PID 文件存在但进程已停止"
                rm -f "$PID_FILE"
                exit 1
            fi
        else
            if pgrep -f "gunicorn app.main:app" > /dev/null; then
                echo "HomeStock 运行中 (无 PID 文件)"
            else
                echo "HomeStock 未运行"
                exit 1
            fi
        fi
        ;;

    foreground|fg)
        # systemd 前台模式（不 daemonize）
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 生产环境（systemd 前台）"
        echo "  地址: http://$HOST:$PORT"
        echo "  Workers: $WORKERS"
        echo "=========================================="
        exec python -m gunicorn app.main:app "${_GUNICORN_ARGS[@]}"
        ;;

    start|"")
        # 默认后台守护
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 生产环境（后台守护）"
        echo "  地址: http://$HOST:$PORT"
        echo "  Workers: $WORKERS"
        echo "  PID: $PID_FILE"
        echo "  日志: $LOG_DIR/"
        echo "  停止: ./start-prod.sh stop"
        echo "=========================================="
        python -m gunicorn app.main:app \
            "${_GUNICORN_ARGS[@]}" \
            --daemon \
            --pid "$PID_FILE"
        echo "已启动 (PID: $(cat "$PID_FILE" 2>/dev/null || echo 'unknown'))"
        ;;

    *)
        echo "用法: $0 [start|--daemon|stop|restart|status|foreground]"
        echo "  start      默认后台守护（关终端不断开）"
        echo "  --daemon   同 start"
        echo "  stop       停止后台进程"
        echo "  restart    重启"
        echo "  status     查看状态"
        echo "  foreground systemd 前台模式"
        exit 1
        ;;
esac
