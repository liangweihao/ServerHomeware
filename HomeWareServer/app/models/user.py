"""
用户模型模块
定义 User 模型和相关关系
"""
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class User(Base, BaseMixin):
    """用户模型"""
    
    __tablename__ = "users"
    
    phone = Column(String(20), unique=True, nullable=False, index=True, comment="手机号（登录凭证）")
    email = Column(String(100), unique=True, nullable=True, index=True, comment="邮箱")
    password_hash = Column(String(128), nullable=False, comment="加密密码")
    nickname = Column(String(50), nullable=False, comment="昵称")
    avatar_url = Column(String(500), nullable=True, comment="头像URL")
    current_family_id = Column(
        Integer,
        ForeignKey("families.id"),
        nullable=True,
        comment="当前所在家庭ID"
    )
    is_active = Column(Boolean, default=True, comment="是否激活")
    last_login_at = Column(DateTime, nullable=True, comment="最后登录时间")
    
    # 关系定义
    current_family = relationship("Family", foreign_keys=[current_family_id])
    families = relationship("FamilyMember", back_populates="user")
    
    async def update_last_login(self):
        """更新最后登录时间"""
        self.last_login_at = datetime.now(timezone.utc)