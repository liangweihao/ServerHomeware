"""
使用记录相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class UsageRecordResponse(BaseModel):
    """使用记录响应模型"""
    
    id: int = Field(..., description="记录ID")
    item_id: int = Field(..., description="物品ID")
    used_quantity: float = Field(..., description="使用数量")
    used_at: datetime = Field(..., description="使用时间")
    used_by: int = Field(..., description="使用人ID")
    notes: Optional[str] = Field(None, description="备注")
    created_at: datetime = Field(..., description="创建时间")
    
    model_config = {"from_attributes": True}


class CreateUsageRecordRequest(BaseModel):
    """创建使用记录请求"""

    item_id: int = Field(..., description="物品ID")
    type: int = Field(default=1, description="记录类型(0入库/1使用/2丢弃/3移动/4调整)")
    quantity: float = Field(..., description="变更数量")
    remaining_quantity: Optional[float] = Field(None, description="变更后剩余数量")
    operator_name: Optional[str] = Field(None, description="操作人名称")
    notes: Optional[str] = Field(None, description="备注")