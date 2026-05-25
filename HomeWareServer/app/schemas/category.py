"""
分类相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class CategoryResponse(BaseModel):
    """分类响应模型"""
    
    id: int = Field(..., description="分类ID")
    name: str = Field(..., description="分类名称")
    icon: Optional[str] = Field(None, description="图标名称")
    color: Optional[str] = Field(None, description="颜色代码")
    family_id: int = Field(..., description="家庭ID")
    parent_id: Optional[int] = Field(None, description="父分类ID")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    
    model_config = {"from_attributes": True}


class CreateCategoryRequest(BaseModel):
    """创建分类请求"""
    
    name: str = Field(..., description="分类名称")
    icon: Optional[str] = Field(None, description="图标名称")
    color: Optional[str] = Field(None, description="颜色代码")
    parent_id: Optional[int] = Field(None, description="父分类ID")


class UpdateCategoryRequest(BaseModel):
    """更新分类请求"""
    
    name: Optional[str] = Field(None, description="分类名称")
    icon: Optional[str] = Field(None, description="图标名称")
    color: Optional[str] = Field(None, description="颜色代码")