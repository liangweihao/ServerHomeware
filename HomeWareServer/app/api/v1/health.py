"""
健康检查路由模块
定义健康检查相关接口
"""
import time
from datetime import datetime

import redis
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.database import get_db

router = APIRouter(prefix="/health", tags=["health"])


@router.get("", summary="健康检查")
async def health_check():
    """
    无需认证的健康检查接口
    
    返回服务状态、版本、运行时间等基本信息
    """
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "version": settings.VERSION,
        "timestamp": datetime.utcnow().isoformat(),
        "environment": settings.APP_ENV
    }


@router.get("/ready", summary="服务就绪检查")
async def readiness_check(db: AsyncSession = Depends(get_db)):
    """
    服务就绪检查（包含数据库连接检查）
    
    返回所有关键服务的连接状态
    """
    checks = {
        "database": {"status": "healthy", "message": ""},
        "redis": {"status": "healthy", "message": ""}
    }

    # 检查数据库连接
    try:
        await db.execute(text("SELECT 1"))
        checks["database"]["status"] = "healthy"
    except Exception as e:
        checks["database"]["status"] = "unhealthy"
        checks["database"]["message"] = str(e)

    # 检查 Redis 连接
    try:
        r = redis.Redis.from_url(settings.REDIS_URL)
        r.ping()
        checks["redis"]["status"] = "healthy"
    except Exception as e:
        checks["redis"]["status"] = "unhealthy"
        checks["redis"]["message"] = str(e)

    # 综合状态
    all_healthy = all(check["status"] == "healthy" for check in checks.values())
    
    return {
        "status": "healthy" if all_healthy else "degraded",
        "checks": checks,
        "timestamp": datetime.utcnow().isoformat()
    }


@router.get("/admin/stats", summary="系统统计（仅开发环境）")
async def admin_stats(db: AsyncSession = Depends(get_db)):
    """
    系统级统计信息（仅开发环境可用）
    
    返回数据库表记录数等统计信息
    """
    if settings.APP_ENV != "development":
        return {
            "error": "此接口仅在开发环境可用"
        }

    stats = {}

    # 获取各表记录数
    try:
        # 用户数
        result = await db.execute(text("SELECT COUNT(*) FROM users"))
        stats["users"] = result.scalar_one()

        # 家庭数
        result = await db.execute(text("SELECT COUNT(*) FROM families"))
        stats["families"] = result.scalar_one()

        # 物品数
        result = await db.execute(text("SELECT COUNT(*) FROM items"))
        stats["items"] = result.scalar_one()

        # 分类数
        result = await db.execute(text("SELECT COUNT(*) FROM categories"))
        stats["categories"] = result.scalar_one()

        # 位置数
        result = await db.execute(text("SELECT COUNT(*) FROM locations"))
        stats["locations"] = result.scalar_one()

        # 使用记录数
        result = await db.execute(text("SELECT COUNT(*) FROM usage_records"))
        stats["usage_records"] = result.scalar_one()

    except Exception as e:
        return {"error": str(e)}

    return {
        "status": "healthy",
        "stats": stats,
        "timestamp": datetime.utcnow().isoformat()
    }
