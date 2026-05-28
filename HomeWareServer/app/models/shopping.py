"""
购物清单模型模块
定义 ShoppingItem 模型
"""
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class ShoppingItem(Base, BaseMixin):
    """购物清单项模型"""
    
    __tablename__ = "shopping_items"
    
    name = Column(String(100), nullable=False, comment="物品名称")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    related_item_id = Column(Integer, ForeignKey("items.id"), nullable=True, comment="关联物品ID")
    quantity = Column(Numeric(10, 2), default=1, comment="数量")
    unit = Column(String(10), default="件", comment="单位")
    estimated_price = Column(Numeric(10, 2), nullable=True, comment="预估价格")
    is_purchased = Column(Boolean, default=False, comment="是否已购买")
    is_auto_generated = Column(Boolean, default=False, comment="是否自动生成")
    priority = Column(Integer, default=0, comment="优先级")
    purchased_at = Column(DateTime, nullable=True, comment="购买时间")
    purchased_by = Column(Integer, ForeignKey("users.id"), nullable=True, comment="购买者ID")
    deleted_at = Column(DateTime, nullable=True, comment="软删除时间")
    
    # 关系定义
    family = relationship("Family")
    related_item = relationship("Item")
    purchased_by_user = relationship("User", foreign_keys=[purchased_by])