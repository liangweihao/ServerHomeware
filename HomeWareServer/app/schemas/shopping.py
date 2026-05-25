"""
购物清单相关的请求/响应模型
"""
from datetime import date, datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class ShoppingItemResponse(BaseModel):
    """购物清单项响应模型"""
    
    id: int = Field(..., description="项ID")
    name: str = Field(..., description="物品名称")
    quantity: float = Field(..., description="数量")
    unit: str = Field(..., description="单位")
    family_id: int = Field(..., description="家庭ID")
    category_id: Optional[int] = Field(None, description="分类ID")
    is_purchased: bool = Field(..., description="是否已购买")
    purchased_at: Optional[datetime] = Field(None, description="购买时间")
    created_by: int = Field(..., description="创建者ID")
    purchased_by: Optional[int] = Field(None, description="购买者ID")
    notes: Optional[str] = Field(None, description="备注")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    
    model_config = {"from_attributes": True}


class ShoppingItemWithRelatedResponse(BaseModel):
    """购物清单项响应模型（含关联物品信息）"""
    
    id: int
    name: str
    quantity: float
    unit: str
    estimated_price: Optional[float]
    actual_price: Optional[float]
    related_item_id: Optional[int]
    related_item_name: Optional[str]
    is_purchased: bool
    is_auto_generated: bool
    priority: int
    purchased_at: Optional[datetime]
    purchased_by: Optional[int]
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class CreateShoppingItemRequest(BaseModel):
    """创建购物清单项请求"""
    
    name: str = Field(..., description="物品名称")
    quantity: float = Field(1.0, description="数量")
    unit: str = Field("个", description="单位")
    estimated_price: Optional[float] = Field(None, description="预估价格")
    related_item_id: Optional[int] = Field(None, description="关联物品ID")
    notes: Optional[str] = Field(None, description="备注")


class UpdateShoppingItemRequest(BaseModel):
    """更新购物清单项请求"""
    
    name: Optional[str] = Field(None, description="物品名称")
    quantity: Optional[float] = Field(None, description="数量")
    unit: Optional[str] = Field(None, description="单位")
    estimated_price: Optional[float] = Field(None, description="预估价格")
    priority: Optional[int] = Field(None, description="优先级")
    notes: Optional[str] = Field(None, description="备注")


class PurchaseRequest(BaseModel):
    """标记购买请求"""
    
    actual_price: Optional[float] = Field(None, description="实际价格")


class ToItemRequest(BaseModel):
    """一键入库请求"""
    
    location_id: Optional[int] = Field(None, description="位置ID")
    expiry_date: Optional[date] = Field(None, description="过期日期")


class ShareTextResponse(BaseModel):
    """分享文本响应"""
    
    text: str = Field(..., description="分享文本")
    total_estimated: float = Field(..., description="预估总价")


class ShoppingRecommendationResponse(BaseModel):
    """购物推荐响应"""
    
    item_id: int = Field(..., description="物品ID")
    item_name: str = Field(..., description="物品名称")
    reason: str = Field(..., description="推荐原因")
    priority: str = Field(..., description="优先级")
    suggested_quantity: int = Field(..., description="建议数量")
    suggested_unit: str = Field(..., description="建议单位")
    last_price: Optional[float] = Field(None, description="上次购买价格")
    last_channel: Optional[str] = Field(None, description="上次购买渠道")


class ShoppingListResponse(BaseModel):
    """购物清单响应（分页）"""
    
    items: List[ShoppingItemWithRelatedResponse]
    total: int
    page: int
    page_size: int
    pages: int