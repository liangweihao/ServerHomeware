#!/bin/bash
# ===========================================
#  HomeStock 启动入口
#  自动判断环境：
#   - dev  → 调用 start-dev.sh（SQLite + 热重载）
#   - prod → 调用 start-prod.sh（PostgreSQL + gunicorn）
#
#  手动指定：./start.sh dev  或  ./start.sh prod
# ===========================================

cd "$(dirname "$0")"

MODE="${1:-dev}"

case "$MODE" in
    dev|development)
        echo "→ 开发模式"
        exec bash start-dev.sh
        ;;
    prod|production)
        echo "→ 生产模式"
        exec bash start-prod.sh
        ;;
    *)
        echo "用法: ./start.sh [dev|prod]"
        exit 1
        ;;
esac
