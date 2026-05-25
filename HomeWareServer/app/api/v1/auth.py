"""
认证路由模块
定义用户注册、登录、刷新Token、登出等接口
"""
from typing import Optional

from fastapi import APIRouter, Depends, Header
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_redis_optional
from app.core.security import decode_token
from app.models.user import User
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.schemas.common import ResponseSchema
from app.schemas.user import UserResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", summary="用户注册")
async def register(
    request: RegisterRequest,
    db: AsyncSession = Depends(get_db),
    redis: Optional[Redis] = Depends(get_redis_optional)
):
    auth_service = AuthService(db, redis)
    user, access_token, refresh_token = await auth_service.register(
        request.phone,
        request.password,
        request.nickname,
        request.email
    )
    
    return ResponseSchema(
        code=200,
        message="注册成功",
        data={
            "user": UserResponse.from_orm(user),
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    )


@router.post("/login", summary="用户登录")
async def login(
    request: LoginRequest,
    db: AsyncSession = Depends(get_db),
    redis: Optional[Redis] = Depends(get_redis_optional)
):
    auth_service = AuthService(db, redis)
    user, access_token, refresh_token = await auth_service.login(
        request.phone,
        request.password
    )
    
    return ResponseSchema(
        code=200,
        message="登录成功",
        data={
            "user": UserResponse.from_orm(user),
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    )


@router.post("/refresh", summary="刷新Token")
async def refresh(
    request: RefreshRequest,
    db: AsyncSession = Depends(get_db),
    redis: Optional[Redis] = Depends(get_redis_optional)
):
    auth_service = AuthService(db, redis)
    access_token, refresh_token = await auth_service.refresh_token(request.refresh_token)
    
    return ResponseSchema(
        code=200,
        message="Token刷新成功",
        data={
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    )


@router.post("/logout", summary="用户登出")
async def logout(
    authorization: str = Header(None),
    db: AsyncSession = Depends(get_db),
    redis: Optional[Redis] = Depends(get_redis_optional),
    current_user: User = Depends(get_current_user)
):
    # 从Header中提取token
    token = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
    
    auth_service = AuthService(db, redis)
    await auth_service.logout(token)
    
    return ResponseSchema(
        code=200,
        message="登出成功",
        data=None
    )