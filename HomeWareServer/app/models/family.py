"""
家庭模型模块
定义 Family 和 FamilyMember 模型
"""
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class Family(Base, BaseMixin):
    """家庭模型"""
    
    __tablename__ = "families"
    
    name = Column(String(50), nullable=False, comment="家庭名称")
    invite_code = Column(String(8), unique=True, nullable=False, index=True, comment="邀请码")
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False, comment="创建者ID")
    icon = Column(String(10), default="🏠", comment="家庭图标")
    deleted_at = Column(DateTime, nullable=True, comment="软删除时间")
    
    # 关系定义
    owner = relationship("User", foreign_keys=[owner_id])
    members = relationship("FamilyMember", back_populates="family")


class FamilyMember(Base):
    """家庭成员关联模型"""
    
    __tablename__ = "family_members"
    
    id = Column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, comment="用户ID")
    role = Column(String(20), default="member", comment="角色：owner/admin/member")
    nickname_in_family = Column(String(50), nullable=True, comment="家庭内昵称")
    joined_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), comment="加入时间")
    
    # 关系定义
    family = relationship("Family", back_populates="members")
    user = relationship("User", back_populates="families")