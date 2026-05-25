"""
通知 Schema 模块
定义通知相关的 Pydantic 模型
"""
from datetime import datetime
from typing import Generic, List, Optional, TypeVar

from pydantic import BaseModel


class NotificationResponse(BaseModel):
    """通知响应Schema"""
    id: int
    family_id: int
    user_id: Optional[int]
    type: str
    title: str
    body: Optional[str]
    item_id: Optional[int]
    priority: str
    is_read: bool
    action_url: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


class NotificationListResponse(BaseModel):
    """通知列表响应（分页）"""
    items: List[NotificationResponse]
    total: int
    page: int
    page_size: int
    pages: int


class UnreadCountResponse(BaseModel):
    """未读数量响应"""
    count: int
