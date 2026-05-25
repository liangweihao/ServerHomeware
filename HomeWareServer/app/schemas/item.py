"""
物品相关的请求/响应模型
"""
from datetime import date, datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class ItemImageResponse(BaseModel):
    """物品图片响应模型"""
    
    id: int = Field(..., description="图片ID")
    url: str = Field(..., description="图片URL")
    sort_order: int = Field(..., description="排序序号")
    
    model_config = {"from_attributes": True}


class UsageRecordResponse(BaseModel):
    """使用记录响应模型"""
    
    id: int = Field(..., description="记录ID")
    type: int = Field(..., description="记录类型(0入库/1使用/2丢弃/3移动/4调整)")
    quantity: float = Field(..., description="变更数量")
    remaining_quantity: float = Field(..., description="变更后剩余数量")
    operator_name: Optional[str] = Field(None, description="操作人名称")
    notes: Optional[str] = Field(None, description="备注")
    created_at: datetime = Field(..., description="创建时间")
    
    model_config = {"from_attributes": True}


class ItemResponse(BaseModel):
    """物品响应模型"""
    
    id: int = Field(..., description="物品ID")
    name: str = Field(..., description="物品名称")
    brand: Optional[str] = Field(None, description="品牌")
    specification: Optional[str] = Field(None, description="规格")
    barcode: Optional[str] = Field(None, description="条码")
    category_id: int = Field(..., description="分类ID")
    category_name: Optional[str] = Field(None, description="分类名称")
    location_id: Optional[int] = Field(None, description="位置ID")
    location_full_path: Optional[str] = Field(None, description="位置完整路径")
    family_id: int = Field(..., description="家庭ID")
    
    # 价格相关
    purchase_price: Optional[float] = Field(None, description="购买单价")
    total_price: Optional[float] = Field(None, description="总价")
    purchase_quantity: int = Field(..., description="购买数量")
    current_quantity: float = Field(..., description="当前数量")
    unit: str = Field(..., description="单位")
    safety_stock: float = Field(..., description="安全库存")
    
    # 日期相关
    purchase_date: Optional[date] = Field(None, description="购买日期")
    purchase_channel: Optional[str] = Field(None, description="购买渠道")
    production_date: Optional[date] = Field(None, description="生产日期")
    expiry_date: Optional[date] = Field(None, description="过期日期")
    shelf_life_days: Optional[int] = Field(None, description="保质期天数")
    opened_date: Optional[date] = Field(None, description="开封日期")
    after_open_days: Optional[int] = Field(None, description="开封后保质期")
    warranty_date: Optional[date] = Field(None, description="质保日期")
    
    # 提醒设置
    expiry_alert_days: int = Field(..., description="过期提醒天数")
    stock_alert: bool = Field(..., description="是否开启库存提醒")
    
    # 其他
    notes: Optional[str] = Field(None, description="备注")
    status: int = Field(..., description="状态(0使用中/1用完/2过期/3丢弃)")
    avg_daily_consumption: Optional[float] = Field(None, description="日均消耗量")
    predicted_empty_date: Optional[date] = Field(None, description="预计用完日期")
    urgency: Optional[int] = Field(None, description="紧急程度(0正常/1即将过期/2库存不足/3已过期/4已用完)")
    created_by: int = Field(..., description="创建者ID")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    
    # 关联数据
    images: Optional[List[ItemImageResponse]] = Field(None, description="图片列表")
    usage_records: Optional[List[UsageRecordResponse]] = Field(None, description="使用记录列表")
    
    model_config = {"from_attributes": True}


class CreateItemRequest(BaseModel):
    """创建物品请求"""
    
    name: str = Field(..., description="物品名称")
    brand: Optional[str] = Field(None, description="品牌")
    specification: Optional[str] = Field(None, description="规格")
    barcode: Optional[str] = Field(None, description="条码")
    category_id: int = Field(..., description="分类ID")
    location_id: Optional[int] = Field(None, description="位置ID")
    
    # 价格相关
    purchase_price: Optional[float] = Field(None, description="购买单价")
    purchase_quantity: int = Field(1, description="购买数量")
    current_quantity: Optional[float] = Field(None, description="当前数量")
    unit: str = Field("件", description="单位")
    safety_stock: float = Field(1, description="安全库存")
    
    # 日期相关
    purchase_date: Optional[date] = Field(None, description="购买日期")
    purchase_channel: Optional[str] = Field(None, description="购买渠道")
    production_date: Optional[date] = Field(None, description="生产日期")
    expiry_date: Optional[date] = Field(None, description="过期日期")
    shelf_life_days: Optional[int] = Field(None, description="保质期天数")
    opened_date: Optional[date] = Field(None, description="开封日期")
    after_open_days: Optional[int] = Field(None, description="开封后保质期")
    warranty_date: Optional[date] = Field(None, description="质保日期")
    
    # 提醒设置
    expiry_alert_days: int = Field(3, description="过期提醒天数")
    stock_alert: bool = Field(True, description="是否开启库存提醒")
    
    # 其他
    notes: Optional[str] = Field(None, description="备注")


class UpdateItemRequest(BaseModel):
    """更新物品请求"""
    
    name: Optional[str] = Field(None, description="物品名称")
    brand: Optional[str] = Field(None, description="品牌")
    specification: Optional[str] = Field(None, description="规格")
    barcode: Optional[str] = Field(None, description="条码")
    category_id: Optional[int] = Field(None, description="分类ID")
    location_id: Optional[int] = Field(None, description="位置ID")
    
    # 价格相关
    purchase_price: Optional[float] = Field(None, description="购买单价")
    purchase_quantity: Optional[int] = Field(None, description="购买数量")
    current_quantity: Optional[float] = Field(None, description="当前数量")
    unit: Optional[str] = Field(None, description="单位")
    safety_stock: Optional[float] = Field(None, description="安全库存")
    
    # 日期相关
    purchase_date: Optional[date] = Field(None, description="购买日期")
    purchase_channel: Optional[str] = Field(None, description="购买渠道")
    production_date: Optional[date] = Field(None, description="生产日期")
    expiry_date: Optional[date] = Field(None, description="过期日期")
    shelf_life_days: Optional[int] = Field(None, description="保质期天数")
    opened_date: Optional[date] = Field(None, description="开封日期")
    after_open_days: Optional[int] = Field(None, description="开封后保质期")
    warranty_date: Optional[date] = Field(None, description="质保日期")
    
    # 提醒设置
    expiry_alert_days: Optional[int] = Field(None, description="过期提醒天数")
    stock_alert: Optional[bool] = Field(None, description="是否开启库存提醒")
    
    # 其他
    notes: Optional[str] = Field(None, description="备注")
    status: Optional[int] = Field(None, description="状态")


class UseItemRequest(BaseModel):
    """使用物品请求"""
    
    quantity: float = Field(..., description="使用数量")
    operator_name: Optional[str] = Field(None, description="操作人名称")


class MoveItemRequest(BaseModel):
    """移动物品位置请求"""
    
    to_location_id: int = Field(..., description="目标位置ID")