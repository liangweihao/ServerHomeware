"""
Redis 连接模块
提供 Redis 客户端连接
"""
from redis.asyncio import Redis, ConnectionPool

from app.config import settings

# 创建连接池
redis_pool = ConnectionPool.from_url(settings.REDIS_URL)

# 创建 Redis 客户端实例
redis_client = Redis(connection_pool=redis_pool)


async def get_redis() -> Redis:
    """FastAPI 依赖注入函数，提供 Redis 客户端"""
    return redis_client


async def init_redis():
    """初始化 Redis 连接测试"""
    try:
        await redis_client.ping()
    except Exception as e:
        raise RuntimeError(f"Redis 连接失败: {e}")