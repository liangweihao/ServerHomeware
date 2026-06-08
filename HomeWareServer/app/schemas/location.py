"""
位置相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class LocationResponse(BaseModel):
    """位置响应模型"""

    id: int = Field(..., description="位置ID")
    name: str = Field(..., description="位置名称")
    icon: Optional[str] = Field(None, description="图标(emoji)")
    full_path: Optional[str] = Field(None, description="完整路径")
    images: Optional[str] = Field(None, description="位置说明图片 JSON")
    family_id: int = Field(..., description="家庭ID")
    parent_id: Optional[int] = Field(None, description="父位置ID")
    level: Optional[int] = Field(None, description="层级")
    sort_order: int = Field(0, description="排序序号")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")

    model_config = {"from_attributes": True}


class CreateLocationRequest(BaseModel):
    """创建位置请求"""

    name: str = Field(..., description="位置名称")
    icon: Optional[str] = Field(None, description="图标(emoji)")
    images: Optional[str] = Field(None, description="位置说明图片 JSON")
    parent_id: Optional[int] = Field(None, description="父位置ID")


class UpdateLocationRequest(BaseModel):
    """更新位置请求"""

    name: Optional[str] = Field(None, description="位置名称")
    icon: Optional[str] = Field(None, description="图标(emoji)")
    images: Optional[str] = Field(None, description="位置说明图片 JSON")
    parent_id: Optional[int] = Field(None, description="父位置ID")
