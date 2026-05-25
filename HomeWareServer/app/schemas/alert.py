"""
提醒 Schema 定义
"""
from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class AlertResponse(BaseModel):
    """提醒响应模型"""
    id: int
    item_id: int
    name: str
    type: str  # expiry/stock/replenish/warranty
    urgency: int  # 1-3，1最紧急
    message: str
    location_path: Optional[str]
    category_name: str
    expiry_date: Optional[str] = None
    current_quantity: Optional[float] = None
    safety_stock: Optional[float] = None
    unit: Optional[str] = None
    purchase_price: Optional[float] = None
    purchase_date: Optional[str] = None
    warranty_date: Optional[str] = None
    created_at: Optional[str]

    class Config:
        orm_mode = True


class AlertSummaryResponse(BaseModel):
    """提醒统计摘要响应模型"""
    expiry: int
    stock: int
    replenish: int
    warranty: int
    total: int
    expiring_count: int = 0  # 7天内过期数量
    expired_count: int = 0   # 已过期未处理
    low_stock_count: int = 0  # 库存不足
    shopping_count: int = 0   # 待购数量
    nearest_expiry: Optional[dict] = None  # 最近要过期的物品
    nearest_empty: Optional[dict] = None   # 最近要用完的物品


class ExpiringItemResponse(BaseModel):
    """即将过期物品响应模型"""
    id: int
    name: str
    days_until_expiry: int
    expiry_date: str
    location_path: Optional[str]
    category_name: str
    current_quantity: float
    unit: Optional[str]


class LowStockItemResponse(BaseModel):
    """库存不足物品响应模型"""
    id: int
    name: str
    current_quantity: float
    safety_stock: float
    unit: Optional[str]
    location_path: Optional[str]
    category_name: str
