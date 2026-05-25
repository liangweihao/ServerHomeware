"""
用户设备模型模块
管理用户的推送设备信息
"""
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String

from app.core.database import Base


class UserDevice(Base):
    """用户设备模型"""
    
    __tablename__ = "user_devices"
    
    id = Column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, comment="用户ID")
    device_token = Column(String(500), nullable=False, comment="FCM推送token")
    device_type = Column(String(20), nullable=False, comment="设备类型：ios/android")
    device_name = Column(String(100), nullable=True, comment="设备名称")
    last_active_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), comment="最后活跃时间")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), comment="创建时间")
