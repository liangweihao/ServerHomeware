#!/bin/bash

# HomeStock Server Docker 启动脚本

set -e

echo "=========================================="
echo "   HomeStock Server Docker 启动脚本"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到 Docker，请先安装 Docker"
    echo "下载地址: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 未找到 Docker Compose"
    exit 1
fi

# 检查是否在正确的目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 请在 HomeWareServer 目录下运行此脚本"
    exit 1
fi

echo "检查 Docker 服务..."
if ! docker info &> /dev/null; then
    echo "警告: Docker 服务未启动，请先启动 Docker"
    exit 1
fi

echo "启动服务..."
echo "这将启动以下服务:"
echo "  - PostgreSQL 数据库 (端口: 5432)"
echo "  - Redis (端口: 6379)"
echo "  - FastAPI 服务器 (端口: 8000)"
echo "  - Celery Worker"
echo "  - Celery Beat"
echo ""
echo "服务启动后:"
echo "  - API 地址: http://localhost:8000"
echo "  - API 文档: http://localhost:8000/docs"
echo ""

# 启动所有服务
docker-compose up -d

echo ""
echo "服务正在启动中..."
echo "请等待几秒后访问 http://localhost:8000"
echo ""
echo "查看日志: docker-compose logs -f app"
echo "停止服务: docker-compose down"