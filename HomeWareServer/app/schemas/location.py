"""
位置相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class LocationResponse(BaseModel):
    """位置响应模型"""
    
    id: int = Field(..., description="位置ID")
    name: str = Field(..., description="位置名称")
    description: Optional[str] = Field(None, description="位置描述")
    family_id: int = Field(..., description="家庭ID")
    parent_id: Optional[int] = Field(None, description="父位置ID")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    
    model_config = {"from_attributes": True}


class CreateLocationRequest(BaseModel):
    """创建位置请求"""
    
    name: str = Field(..., description="位置名称")
    description: Optional[str] = Field(None, description="位置描述")
    parent_id: Optional[int] = Field(None, description="父位置ID")


class UpdateLocationRequest(BaseModel):
    """更新位置请求"""
    
    name: Optional[str] = Field(None, description="位置名称")
    description: Optional[str] = Field(None, description="位置描述")