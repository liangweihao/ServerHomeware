"""
通知偏好 Schema 模块
定义用户通知偏好相关的 Pydantic 模型
"""
from datetime import time
from typing import Optional

from pydantic import BaseModel


class NotificationPreferenceResponse(BaseModel):
    """通知偏好响应"""
    push_enabled: bool = True
    expiry_alert: bool = True
    stock_alert: bool = True
    purchase_alert: bool = True
    warranty_alert: bool = True
    quiet_start: Optional[time] = None
    quiet_end: Optional[time] = None

    model_config = {"from_attributes": True}


class UpdateNotificationPreferenceRequest(BaseModel):
    """更新通知偏好请求"""
    push_enabled: Optional[bool] = None
    expiry_alert: Optional[bool] = None
    stock_alert: Optional[bool] = None
    purchase_alert: Optional[bool] = None
    warranty_alert: Optional[bool] = None
    quiet_start: Optional[time] = None
    quiet_end: Optional[time] = None
