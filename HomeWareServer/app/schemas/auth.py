"""
认证相关的请求/响应模型
"""
from pydantic import BaseModel, Field, field_validator


class RegisterRequest(BaseModel):
    """用户注册请求"""
    
    phone: str = Field(..., description="手机号")
    password: str = Field(..., description="密码")
    nickname: str = Field(..., description="昵称")
    email: str = Field(None, description="邮箱")
    
    @field_validator("phone")
    def validate_phone(cls, v):
        if not v or len(v) < 11:
            raise ValueError("手机号格式不正确")
        return v
    
    @field_validator("password")
    def validate_password(cls, v):
        if not v or len(v) < 6:
            raise ValueError("密码长度至少6位")
        return v


class LoginRequest(BaseModel):
    """用户登录请求"""
    
    phone: str = Field(..., description="手机号")
    password: str = Field(..., description="密码")


class RefreshRequest(BaseModel):
    """刷新Token请求"""
    
    refresh_token: str = Field(..., description="刷新令牌")


class TokenResponse(BaseModel):
    """Token响应"""
    
    access_token: str = Field(..., description="访问令牌")
    refresh_token: str = Field(..., description="刷新令牌")
    token_type: str = Field("bearer", description="令牌类型")