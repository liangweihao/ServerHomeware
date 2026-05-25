#!/bin/bash

# HomeStock Server 启动脚本

set -e

echo "=========================================="
echo "     HomeStock Server 启动脚本"
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
fi

# 设置 PYTHONPATH，让 Alembic 能找到 app 模块
export PYTHONPATH=$PYTHONPATH:$(pwd)

# 检查数据库连接
echo "检查数据库连接..."
python3 -c "
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.config import settings

async def test_db():
    try:
        engine = create_async_engine(settings.DATABASE_URL)
        async with engine.connect() as conn:
            await conn.execute('SELECT 1')
            await conn.commit()
        await engine.dispose()
        return True
    except Exception as e:
        print(f'DB connection failed: {e}')
        return False

result = asyncio.run(test_db())
exit(0 if result else 1)
"

if [ $? -eq 0 ]; then
    echo "数据库连接成功"
    # 运行数据库迁移
    echo "运行数据库迁移..."
    alembic upgrade head
else
    echo "警告: 数据库连接失败，跳过数据库迁移步骤"
    echo "请确保 PostgreSQL 和 Redis 服务已启动"
    echo "数据库配置: ${DATABASE_URL:-从 .env 文件读取}"
fi

# 启动服务器
echo "启动 FastAPI 服务器..."
echo "服务器将在 http://localhost:8000 运行"
echo "API 文档: http://localhost:8000/docs"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload