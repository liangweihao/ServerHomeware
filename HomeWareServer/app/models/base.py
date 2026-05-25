"""
模型基类模块
所有模型继承的基类，包含公共字段
"""
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Integer
from sqlalchemy.ext.declarative import declared_attr

from app.core.database import Base


class BaseMixin:
    """模型基类混入"""
    
    @declared_attr
    def __tablename__(cls) -> str:
        """自动生成表名（类名小写加s）"""
        return cls.__name__.lower() + "s"
    
    id = Column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), comment="创建时间")
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        comment="更新时间"
    )