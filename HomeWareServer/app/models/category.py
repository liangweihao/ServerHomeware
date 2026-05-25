"""
分类模型模块
定义 Category 模型
"""
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class Category(Base, BaseMixin):
    """分类模型"""
    
    __tablename__ = "categories"
    
    name = Column(String(50), nullable=False, comment="分类名称")
    icon = Column(String(20), nullable=True, comment="图标(emoji)")
    color = Column(String(10), nullable=True, comment="颜色代码(hex)")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=True, comment="家庭ID(系统预设为null)")
    parent_id = Column(Integer, ForeignKey("categories.id"), nullable=True, comment="父分类ID")
    sort_order = Column(Integer, default=0, comment="排序序号")
    is_system = Column(Boolean, default=False, comment="是否系统预设")
    is_active = Column(Boolean, default=True, comment="是否启用(软删除)")
    deleted_at = Column(DateTime, nullable=True, comment="删除时间(软删除)")
    
    # 关系定义
    parent = relationship("Category", remote_side="Category.id")
    children = relationship("Category", overlaps="parent")
    family = relationship("Family")