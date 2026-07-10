"""
问管管对话消息模型
按家庭 + 用户持久化，换设备 / 重装 App 可恢复
"""
from sqlalchemy import Column, ForeignKey, Integer, JSON, String, Text

from app.core.database import Base
from app.models.base import BaseMixin


class AssistantChatMessage(Base, BaseMixin):
    """助手对话消息"""

    __tablename__ = "assistant_chat_messages"

    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, index=True, comment="家庭ID")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True, comment="用户ID")
    role = Column(String(20), nullable=False, comment="user 或 assistant")
    content = Column(Text, nullable=False, comment="消息正文")
    meta_json = Column(JSON, nullable=True, comment="扩展：shopping_added / items / actions")
