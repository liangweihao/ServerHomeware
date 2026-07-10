#!/bin/bash
# ===========================================
#  HomeStock 统一启动脚本（本地 + 服务器）
#  配置：仅使用 HomeWareServer/.env（模板见 .env.example）
# ===========================================
#  用法：
#    ./start.sh              后台守护（默认）
#    ./start.sh prod         同上
#    ./start.sh stop         停止
#    ./start.sh restart      重启
#    ./start.sh status       查看状态
#    ./start.sh foreground   前台模式（systemd / 调试）
# ===========================================
set -e

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
WORKERS="${WORKERS:-4}"
PID_FILE="logs/gunicorn.pid"
LOG_DIR="logs"

# ===========================================
#  Python 环境检测 & 自动修复
# ===========================================
_FOUND_PYTHON=""
_FOUND_PIP=""

_detect_python() {
    local candidates=(
        python3.12 python3.11 python3.10 python3.9
        python3 python
    )
    for cmd in "${candidates[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            local ver
            ver=$("$cmd" --version 2>&1) || continue
            if echo "$ver" | grep -qi "python"; then
                _FOUND_PYTHON="$cmd"
                echo "  找到 Python: $cmd ($ver)"
                return 0
            fi
        fi
    done
    return 1
}

_ensure_pip() {
    if "$_FOUND_PYTHON" -m pip --version &> /dev/null; then
        _FOUND_PIP="$_FOUND_PYTHON -m pip"
        return 0
    fi
    echo "  pip 未安装，尝试安装..."
    if command -v yum &> /dev/null; then
        sudo yum install -y python3-pip 2>/dev/null || true
    fi
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq python3-pip 2>/dev/null || true
    fi
    "$_FOUND_PYTHON" -m ensurepip --upgrade 2>/dev/null || true
    if "$_FOUND_PYTHON" -m pip --version &> /dev/null; then
        _FOUND_PIP="$_FOUND_PYTHON -m pip"
        return 0
    fi
    return 1
}

_install_system_deps() {
    echo "  检查系统编译依赖..."
    if ! command -v gcc &> /dev/null && ! command -v cc &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update -qq 2>/dev/null || true
            sudo apt-get install -y -qq build-essential python3-dev 2>/dev/null || true
        elif command -v yum &> /dev/null; then
            sudo yum groupinstall -y "Development Tools" 2>/dev/null || true
            sudo yum install -y python3-devel 2>/dev/null || true
        fi
    fi
}

_ensure_venv() {
    if "$_FOUND_PYTHON" -c "import venv" &> /dev/null; then
        return 0
    fi
    echo "  venv 模块不可用，尝试安装..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq python3-venv 2>/dev/null || true
    fi
    "$_FOUND_PYTHON" -c "import venv" &> /dev/null || {
        echo "  警告: venv 仍不可用，跳过虚拟环境，使用系统 Python"
        return 1
    }
    return 0
}

echo "=========================================="
echo "  HomeStock 环境检测"
echo "=========================================="

if ! _detect_python; then
    echo "错误: 未找到可用的 Python，请先安装 Python 3.9+"
    exit 1
fi

_ensure_pip || { echo "错误: 无法安装 pip"; exit 1; }
_install_system_deps
_ensure_venv

VENV_OK=0
if [ ! -d ".venv" ]; then
    echo "创建虚拟环境..."
    if "$_FOUND_PYTHON" -m venv .venv 2>/dev/null; then
        VENV_OK=1
    else
        echo "  venv 创建失败，使用 virtualenv..."
        $_FOUND_PIP install virtualenv 2>/dev/null || true
        "$_FOUND_PYTHON" -m virtualenv .venv 2>/dev/null && VENV_OK=1 || true
    fi
else
    VENV_OK=1
fi

if [ "$VENV_OK" = "1" ] && [ -f ".venv/bin/activate" ]; then
    echo "激活虚拟环境..."
    source .venv/bin/activate
elif [ "$VENV_OK" = "1" ] && [ -f ".venv/Scripts/activate" ]; then
    echo "激活虚拟环境..."
    source .venv/Scripts/activate
fi

PY_CMD="python"
[ "$VENV_OK" = "1" ] && [ -f ".venv/bin/python" ] && PY_CMD=".venv/bin/python"
[ "$VENV_OK" = "1" ] && [ -f ".venv/Scripts/python" ] && PY_CMD=".venv/Scripts/python"

echo "安装/更新 Python 依赖..."
$PY_CMD -m pip install --upgrade pip -q 2>/dev/null || true
$PY_CMD -m pip install \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    -r requirements.txt 2>/dev/null || {
    echo "  清华源不可用，使用默认源..."
    $PY_CMD -m pip install -r requirements.txt
}

# ===========================================
#  加载环境变量（仅 .env）
# ===========================================
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "  未找到 .env，从 .env.example 复制..."
    cp .env.example .env
    echo "  请编辑 .env 填写 JWT_SECRET_KEY、DEEPSEEK_API_KEY 等后重启"
fi
if [ -f ".env" ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
else
    echo "错误: 缺少 .env，请复制 .env.example 并配置"
    exit 1
fi
export ENV_FILE=".env"

_validate_env() {
    local warn=0
    if [ -z "$DEEPSEEK_API_KEY" ] || [ "$DEEPSEEK_API_KEY" = "your-deepseek-api-key" ]; then
        echo "  警告: DEEPSEEK_API_KEY 未配置，问管管将不可用"
        warn=1
    else
        echo "  DeepSeek: ${DEEPSEEK_API_KEY:0:8}... 已加载"
    fi
    if [ -z "$JWT_SECRET_KEY" ] || [[ "$JWT_SECRET_KEY" == *"change-in-production"* ]] || [[ "$JWT_SECRET_KEY" == *"your-secret-key"* ]]; then
        echo "  警告: JWT_SECRET_KEY 仍为占位符，生产环境请改为强随机字符串"
        warn=1
    fi
    echo "  数据库: ${DATABASE_URL:-未设置}"
    if [ "$warn" = "1" ]; then
        echo "  → 请编辑 .env 后执行 ./start.sh restart"
    fi
}
_validate_env

mkdir -p logs uploads

_kill_old() {
    echo "检查端口 $PORT..."
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null || true)
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            echo "  杀掉旧进程 (PID: $OLD_PID)..."
            kill "$OLD_PID" 2>/dev/null || true
            sleep 2
            kill -9 "$OLD_PID" 2>/dev/null || true
            rm -f "$PID_FILE"
        fi
    fi
    local PORT_PID
    PORT_PID=$(lsof -ti:$PORT 2>/dev/null || fuser ${PORT}/tcp 2>/dev/null | awk '{print $1}' || true)
    if [ -n "$PORT_PID" ]; then
        echo "  杀掉占用端口进程 (PID: $PORT_PID)..."
        kill -9 $PORT_PID 2>/dev/null || true
        sleep 1
    fi
}

_do_migrate() {
    export PYTHONPATH="$SCRIPT_DIR:$PYTHONPATH"
    echo "运行数据库迁移..."
    $PY_CMD -m alembic upgrade head || {
        echo "  警告: 数据库迁移失败，继续启动..."
    }
}

_is_windows() {
    case "$(uname -s 2>/dev/null || echo Windows)" in
        CYGWIN*|MINGW*|MSYS*|Windows) return 0 ;;
        *) return 1 ;;
    esac
}

_start_server() {
    local FG="${1:-0}"

    if _is_windows; then
        echo "  (Windows 环境，使用 uvicorn)"
        if [ "$FG" = "1" ]; then
            exec $PY_CMD -m uvicorn app.main:app --host "$HOST" --port "$PORT" --workers "$WORKERS"
        else
            nohup $PY_CMD -m uvicorn app.main:app \
                --host "$HOST" --port "$PORT" --workers "$WORKERS" \
                > "$LOG_DIR/access.log" 2> "$LOG_DIR/error.log" &
            echo $! > "$PID_FILE"
            echo "已启动 (PID: $(cat "$PID_FILE"))"
        fi
    else
        local USE_GUNICORN=1
        $PY_CMD -c "import gunicorn" 2>/dev/null || USE_GUNICORN=0

        if [ "$USE_GUNICORN" = "1" ]; then
            local ARGS=(
                -m gunicorn
                app.main:app
                --worker-class uvicorn.workers.UvicornWorker
                --bind "$HOST:$PORT"
                --workers "$WORKERS"
                --access-logfile "$LOG_DIR/access.log"
                --error-logfile "$LOG_DIR/error.log"
                --log-level warning
                --timeout 120
            )
            if [ "$FG" = "1" ]; then
                exec $PY_CMD "${ARGS[@]}"
            else
                $PY_CMD "${ARGS[@]}" --daemon --pid "$PID_FILE"
                echo "已启动 (PID: $(cat "$PID_FILE" 2>/dev/null || echo 'unknown'))"
            fi
        else
            echo "  (gunicorn 不可用，使用 uvicorn)"
            if [ "$FG" = "1" ]; then
                exec $PY_CMD -m uvicorn app.main:app --host "$HOST" --port "$PORT" --workers "$WORKERS"
            else
                nohup $PY_CMD -m uvicorn app.main:app \
                    --host "$HOST" --port "$PORT" --workers "$WORKERS" \
                    > "$LOG_DIR/access.log" 2> "$LOG_DIR/error.log" &
                echo $! > "$PID_FILE"
                echo "已启动 (PID: $(cat "$PID_FILE"))"
            fi
        fi
    fi
}

case "${1:-start}" in
    prod|production|start|""|--daemon|-d|daemon)
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 后台守护模式"
        echo "  地址: http://$HOST:$PORT"
        echo "  Workers: $WORKERS"
        echo "  配置: .env"
        echo "  停止: $0 stop"
        echo "=========================================="
        _start_server 0
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "停止 HomeStock (PID: $PID)..."
            kill "$PID" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "已停止"
        else
            echo "未找到 PID 文件，按进程名查找..."
            pkill -f "uvicorn app.main:app" 2>/dev/null || true
            pkill -f "gunicorn app.main:app" 2>/dev/null || true
            echo "已停止"
        fi
        ;;

    restart)
        $0 stop
        sleep 2
        $0 start
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
        elif pgrep -f "uvicorn app.main:app" > /dev/null 2>&1 || pgrep -f "gunicorn app.main:app" > /dev/null 2>&1; then
            echo "HomeStock 运行中 (无 PID 文件)"
        else
            echo "HomeStock 未运行"
            exit 1
        fi
        ;;

    foreground|fg)
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 前台模式"
        echo "  地址: http://$HOST:$PORT"
        echo "=========================================="
        _start_server 1
        ;;

    *)
        echo "用法: $0 [start|prod|stop|restart|status|foreground]"
        exit 1
        ;;
esac
