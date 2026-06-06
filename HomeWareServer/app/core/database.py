"""
数据库连接模块
使用 SQLAlchemy 2.0
支持 PostgreSQL 和 SQLite 两种数据库类型
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker, Session

from app.config import settings

# 创建基础模型类
Base = declarative_base()

# 根据数据库类型配置引擎
if settings.DATABASE_TYPE == "sqlite":
    # SQLite 使用异步引擎 (aiosqlite)
    async_engine = create_async_engine(
        settings.DATABASE_URL,
        echo=settings.DEBUG,
        connect_args={"check_same_thread": False},
    )
    
    # 创建异步会话工厂
    async_session_maker = sessionmaker(
        async_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )
    
    async def get_db() -> AsyncSession:
        """FastAPI 依赖注入函数，提供数据库会话"""
        async with async_session_maker() as session:
            yield session
    
    async def init_db():
        """初始化数据库表（已关闭 create_all，schema 由 Alembic 管理）"""
        # 不再使用 create_all，避免绕过 Alembic 导致双轨建表冲突
        # async with async_engine.begin() as conn:
        #     await conn.run_sync(Base.metadata.create_all)
        pass

    async def test_db_connection() -> bool:
        """测试数据库连接"""
        try:
            async with async_engine.connect() as conn:
                await conn.execute("SELECT 1")
                await conn.commit()
            return True
        except Exception as e:
            print(f"Database connection failed: {e}")
            return False

else:
    # PostgreSQL 使用异步引擎
    async_engine = create_async_engine(
        settings.DATABASE_URL,
        pool_size=10,
        max_overflow=20,
        echo=settings.DEBUG,
    )

    # 创建异步会话工厂
    async_session_maker = sessionmaker(
        async_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async def get_db() -> AsyncSession:
        """FastAPI 依赖注入函数，提供数据库会话"""
        async with async_session_maker() as session:
            yield session

    async def init_db():
        """初始化数据库表（已关闭 create_all，schema 由 Alembic 管理）"""
        # 不再使用 create_all，避免绕过 Alembic 导致双轨建表冲突
        # async with async_engine.begin() as conn:
        #     await conn.run_sync(Base.metadata.create_all)
        pass

    async def test_db_connection() -> bool:
        """测试数据库连接"""
        try:
            async with async_engine.connect() as conn:
                await conn.execute("SELECT 1")
                await conn.commit()
            return True
        except Exception as e:
            print(f"Database connection failed: {e}")
            return False