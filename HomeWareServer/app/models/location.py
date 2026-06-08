"""
位置模型模块
定义 Location 模型
"""
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class Location(Base, BaseMixin):
    """位置模型"""
    
    __tablename__ = "locations"
    
    name = Column(String(50), nullable=False, comment="位置名称")
    icon = Column(String(20), nullable=True, comment="图标(emoji)")
    images = Column(String(500), nullable=True, comment="位置说明图片 JSON 数组")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    parent_id = Column(Integer, ForeignKey("locations.id"), nullable=True, comment="父位置ID")
    level = Column(Integer, nullable=False, default=1, comment="层级(1/2/3)")
    full_path = Column(String(200), nullable=True, comment="完整路径(如'厨房/冰箱/冷藏层')")
    sort_order = Column(Integer, default=0, comment="排序序号")
    is_active = Column(Boolean, default=True, comment="是否启用")
    deleted_at = Column(DateTime, nullable=True, comment="删除时间(软删除)")
    
    # 关系定义
    parent = relationship("Location", remote_side="Location.id")
    children = relationship("Location", overlaps="parent")
    family = relationship("Family")