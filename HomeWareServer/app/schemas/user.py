"""
用户相关的请求/响应模型
"""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class UserResponse(BaseModel):
    """用户响应模型"""
    
    id: int = Field(..., description="用户ID")
    phone: str = Field(..., description="手机号")
    email: Optional[str] = Field(None, description="邮箱")
    nickname: str = Field(..., description="昵称")
    avatar_url: Optional[str] = Field(None, description="头像URL")
    current_family_id: Optional[int] = Field(None, description="当前家庭ID")
    is_active: bool = Field(..., description="是否激活")
    last_login_at: Optional[datetime] = Field(None, description="最后登录时间")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    
    model_config = {"from_attributes": True}


class UpdateUserRequest(BaseModel):
    """更新用户信息请求"""
    
    nickname: Optional[str] = Field(None, description="昵称")
    email: Optional[str] = Field(None, description="邮箱")
    avatar_url: Optional[str] = Field(None, description="头像URL")


class ChangePasswordRequest(BaseModel):
    """修改密码请求"""
    
    old_password: str = Field(..., description="旧密码")
    new_password: str = Field(..., description="新密码")