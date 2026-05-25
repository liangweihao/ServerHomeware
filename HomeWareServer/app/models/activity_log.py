"""
活动日志模型模块
记录用户的所有操作行为
"""
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, ForeignKey, Integer, JSON, String

from app.core.database import Base
from app.models.base import BaseMixin


class ActivityLog(Base, BaseMixin):
    """活动日志模型"""
    
    __tablename__ = "activity_logs"
    
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, comment="用户ID")
    action = Column(String(50), nullable=False, comment="操作类型")
    target_type = Column(String(50), comment="目标类型")
    target_id = Column(Integer, comment="目标ID")
    target_name = Column(String(100), comment="目标名称(冗余)")
    detail = Column(JSON, nullable=True, comment="详细信息")
    
    # 操作类型常量
    ACTION_CREATE_ITEM = "create_item"
    ACTION_UPDATE_ITEM = "update_item"
    ACTION_DELETE_ITEM = "delete_item"
    ACTION_USE_ITEM = "use_item"
    ACTION_FINISH_ITEM = "finish_item"
    ACTION_DISCARD_ITEM = "discard_item"
    ACTION_MOVE_ITEM = "move_item"
    
    ACTION_CREATE_LOCATION = "create_location"
    ACTION_UPDATE_LOCATION = "update_location"
    ACTION_DELETE_LOCATION = "delete_location"
    
    ACTION_CREATE_CATEGORY = "create_category"
    ACTION_UPDATE_CATEGORY = "update_category"
    ACTION_DELETE_CATEGORY = "delete_category"
    
    ACTION_ADD_SHOPPING_ITEM = "add_shopping_item"
    ACTION_PURCHASE_SHOPPING_ITEM = "purchase_shopping_item"
    
    ACTION_JOIN_FAMILY = "join_family"
    ACTION_LEAVE_FAMILY = "leave_family"
    ACTION_UPDATE_MEMBER_ROLE = "update_member_role"
