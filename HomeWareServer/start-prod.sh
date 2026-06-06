#!/bin/bash
# ===========================================
#  HomeStock 生产环境启动脚本
#  - 适配腾讯轻量云 / 通用 Linux 服务器
#  - 自动检测 Python 版本，缺少依赖时自动安装
#  - gunicorn + uvicorn workers（Windows 回退 uvicorn）
# ===========================================
#  用法：
#    ./start-prod.sh             后台守护（默认）
#    ./start-prod.sh foreground  systemd 前台模式
#    ./start-prod.sh stop        停止
#    ./start-prod.sh restart     重启
#    ./start-prod.sh status      查看状态
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
    # 按优先级尝试所有可能的 Python 命令
    local candidates=(
        python3.12 python3.11 python3.10 python3.9
        python3 python
    )
    for cmd in "${candidates[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            # 验证能真正运行（排除 Windows Store 假 python3）
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
    # 确保 pip 可用
    if "$_FOUND_PYTHON" -m pip --version &> /dev/null; then
        _FOUND_PIP="$_FOUND_PYTHON -m pip"
        return 0
    fi
    echo "  pip 未安装，尝试安装..."
    # CentOS/RHEL
    if command -v yum &> /dev/null; then
        sudo yum install -y python3-pip 2>/dev/null || true
    fi
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq python3-pip 2>/dev/null || true
    fi
    # ensurepip fallback
    "$_FOUND_PYTHON" -m ensurepip --upgrade 2>/dev/null || true

    if "$_FOUND_PYTHON" -m pip --version &> /dev/null; then
        _FOUND_PIP="$_FOUND_PYTHON -m pip"
        return 0
    fi
    return 1
}

_install_system_deps() {
    # 安装编译 Python 包所需的系统依赖
    echo "  检查系统编译依赖..."
    local missing=""

    # 检查是否有 gcc（编译 asyncpg/psycopg2 等需要）
    if ! command -v gcc &> /dev/null && ! command -v cc &> /dev/null; then
        missing="gcc $missing"
    fi
    # 检查 Python 开发头文件
    if ! "$_FOUND_PYTHON" -c "import sysconfig; print(sysconfig.get_config_var('INCLUDEPY'))" &> /dev/null; then
        missing="python3-dev $missing"
    fi

    if [ -n "$missing" ]; then
        echo "  缺少: $missing，尝试安装..."
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
    # 确保 venv 模块可用
    if "$_FOUND_PYTHON" -c "import venv" &> /dev/null; then
        return 0
    fi
    echo "  venv 模块不可用，尝试安装..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq "python${_FOUND_PYTHON//python/}-venv" 2>/dev/null || \
        sudo apt-get install -y -qq python3-venv 2>/dev/null || true
    fi
    "$_FOUND_PYTHON" -c "import venv" &> /dev/null || {
        echo "  警告: venv 仍不可用，跳过虚拟环境，使用系统 Python"
        return 1
    }
    return 0
}

# --- 执行 Python 检测 ---
echo "=========================================="
echo "  HomeStock 环境检测"
echo "=========================================="

if ! _detect_python; then
    echo "错误: 未找到可用的 Python，请先安装 Python 3.9+"
    echo "  Ubuntu: sudo apt install python3 python3-pip python3-venv"
    echo "  CentOS: sudo yum install python3 python3-pip"
    exit 1
fi

_ensure_pip || { echo "错误: 无法安装 pip"; exit 1; }
_install_system_deps
_ensure_venv

# ===========================================
#  虚拟环境
# ===========================================
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

# 确保使用 venv 中的 python
PY_CMD="python"
[ "$VENV_OK" = "1" ] && [ -f ".venv/bin/python" ] && PY_CMD=".venv/bin/python"
[ "$VENV_OK" = "1" ] && [ -f ".venv/Scripts/python" ] && PY_CMD=".venv/Scripts/python"

# ===========================================
#  依赖安装
# ===========================================
echo "检查 Python 依赖..."
if ! $PY_CMD -c "import fastapi" &> /dev/null; then
    echo "安装依赖（使用清华镜像源）..."
    $PY_CMD -m pip install --upgrade pip -q 2>/dev/null || true
    $PY_CMD -m pip install \
        -i https://pypi.tuna.tsinghua.edu.cn/simple \
        -r requirements.txt || {
        echo "  清华源失败，使用默认源重试..."
        $PY_CMD -m pip install -r requirements.txt
    }
fi

# ===========================================
#  加载环境变量
# ===========================================
if [ -f ".env.production" ]; then
    export $(grep -v '^#' .env.production | xargs)
fi
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# ===========================================
#  目录 & 端口清理
# ===========================================
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
    # 端口占用兜底
    local PORT_PID
    PORT_PID=$(lsof -ti:$PORT 2>/dev/null || fuser ${PORT}/tcp 2>/dev/null | awk '{print $1}' || true)
    if [ -n "$PORT_PID" ]; then
        echo "  杀掉占用端口进程 (PID: $PORT_PID)..."
        kill -9 $PORT_PID 2>/dev/null || true
        sleep 1
    fi
}

# ===========================================
#  数据库迁移
# ===========================================
_do_migrate() {
    export PYTHONPATH="$SCRIPT_DIR:$PYTHONPATH"
    echo "运行数据库迁移..."
    $PY_CMD -m alembic upgrade head || {
        echo "  警告: 数据库迁移失败，继续启动..."
    }
}

# ===========================================
#  平台检测 & 启动
# ===========================================
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
        # Linux: 优先 gunicorn，失败回退 uvicorn
        local USE_GUNICORN=1
        $PY_CMD -c "import gunicorn" 2>/dev/null || USE_GUNICORN=0

        if [ "$USE_GUNICORN" = "1" ]; then
            local ARGS=(
                -m 007
                --worker-class uvicorn.workers.UvicornWorker
                --bind "$HOST:$PORT"
                --workers "$WORKERS"
                --access-logfile "$LOG_DIR/access.log"
                --error-logfile "$LOG_DIR/error.log"
                --log-level warning
                --timeout 120
            )
            if [ "$FG" = "1" ]; then
                exec $PY_CMD -m gunicorn app.main:app "${ARGS[@]}"
            else
                $PY_CMD -m gunicorn app.main:app "${ARGS[@]}" --daemon --pid "$PID_FILE"
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

# ===========================================
#  命令路由
# ===========================================
case "${1:-start}" in
    --daemon|-d|daemon|start|"")
        _kill_old
        _do_migrate
        echo "=========================================="
        echo "  HomeStock 后台守护模式"
        echo "  地址: http://$HOST:$PORT"
        echo "  Workers: $WORKERS"
        echo "  PID: $PID_FILE"
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
        $0 --daemon
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
        echo "  HomeStock systemd 前台模式"
        echo "  地址: http://$HOST:$PORT"
        echo "=========================================="
        _start_server 1
        ;;

    *)
        echo "用法: $0 [start|stop|restart|status|foreground]"
        echo "  start      默认后台守护"
        echo "  stop       停止后台进程"
        echo "  restart    重启"
        echo "  status     查看状态"
        echo "  foreground systemd 前台模式"
        exit 1
        ;;
esac
