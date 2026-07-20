"""
通知模型模块
定义 Notification 模型
"""
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String

from app.core.database import Base
from app.models.base import BaseMixin


class Notification(Base, BaseMixin):
    """通知模型"""

    __tablename__ = "notifications"

    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, comment="用户ID（null=全家庭）")
    type = Column(String(30), nullable=False, comment="通知类型：expiry/stock/purchase/warranty/system")
    title = Column(String(100), nullable=False, comment="通知标题")
    body = Column(String(500), nullable=True, comment="通知内容")
    item_id = Column(Integer, nullable=True, comment="关联物品ID")
    priority = Column(String(10), default="medium", comment="优先级：high/medium/low")
    is_read = Column(Boolean, default=False, comment="是否已读")
    action_url = Column(String(200), nullable=True, comment="点击跳转路径")

    # 通知类型常量
    TYPE_EXPIRY = "expiry"
    TYPE_STOCK = "stock"
    TYPE_PURCHASE = "purchase"
    TYPE_WARRANTY = "warranty"
    TYPE_SYSTEM = "system"
    TYPE_IDLE = "idle"  # 长期未使用提醒

    # 优先级常量
    PRIORITY_HIGH = "high"
    PRIORITY_MEDIUM = "medium"
    PRIORITY_LOW = "low"
