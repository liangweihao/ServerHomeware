"""
使用记录模型模块
定义 UsageRecord 模型
"""
from sqlalchemy import Column, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class UsageRecord(Base, BaseMixin):
    """使用记录模型"""
    
    __tablename__ = "usage_records"
    
    item_id = Column(Integer, ForeignKey("items.id"), nullable=False, comment="物品ID")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    type = Column(Integer, nullable=False, comment="记录类型(0入库/1使用/2丢弃/3移动/4调整)")
    quantity = Column(Numeric(10, 2), nullable=False, comment="变更数量")
    remaining_quantity = Column(Numeric(10, 2), nullable=False, comment="变更后剩余数量")
    operator_id = Column(Integer, ForeignKey("users.id"), nullable=True, comment="操作人ID")
    operator_name = Column(String(50), nullable=True, comment="操作人名称(冗余)")
    from_location_id = Column(Integer, ForeignKey("locations.id"), nullable=True, comment="移动前位置ID")
    to_location_id = Column(Integer, ForeignKey("locations.id"), nullable=True, comment="移动后位置ID")
    notes = Column(String(200), nullable=True, comment="备注")
    
    # 关系定义
    item = relationship("Item", back_populates="usage_records")
    operator = relationship("User", foreign_keys=[operator_id])