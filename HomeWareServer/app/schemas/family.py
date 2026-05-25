"""
家庭相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class FamilyResponse(BaseModel):
    """家庭响应模型"""
    
    id: int = Field(..., description="家庭ID")
    name: str = Field(..., description="家庭名称")
    invite_code: str = Field(..., description="邀请码")
    owner_id: int = Field(..., description="创建者ID")
    created_at: datetime = Field(..., description="创建时间")
    
    model_config = {"from_attributes": True}


class FamilyMemberResponse(BaseModel):
    """家庭成员响应模型"""
    
    id: int = Field(..., description="成员ID")
    family_id: int = Field(..., description="家庭ID")
    user_id: int = Field(..., description="用户ID")
    role: str = Field(..., description="角色")
    nickname_in_family: Optional[str] = Field(None, description="家庭内昵称")
    joined_at: datetime = Field(..., description="加入时间")
    
    model_config = {"from_attributes": True}


class CreateFamilyRequest(BaseModel):
    """创建家庭请求"""
    
    name: str = Field(..., description="家庭名称")


class JoinFamilyRequest(BaseModel):
    """加入家庭请求"""
    
    invite_code: str = Field(..., description="邀请码")


class UpdateFamilyRequest(BaseModel):
    """更新家庭请求"""
    
    name: Optional[str] = Field(None, description="家庭名称")


class UpdateFamilyMemberRequest(BaseModel):
    """更新家庭成员请求"""
    
    role: Optional[str] = Field(None, description="角色")
    nickname_in_family: Optional[str] = Field(None, description="家庭内昵称")