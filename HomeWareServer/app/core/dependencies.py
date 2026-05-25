"""
依赖注入模块
提供 FastAPI 依赖注入函数
"""
from datetime import datetime, timezone
from typing import Optional

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import UnauthorizedException
from app.core.redis import get_redis
from app.core.security import decode_token
from app.models.user import User
from app.repositories.user_repo import UserRepository

oauth2_scheme = HTTPBearer(auto_error=False)


async def get_redis_optional() -> Optional[Redis]:
    """
    获取 Redis 客户端（可选）
    在开发模式下，如果 Redis 不可用，返回 None
    """
    try:
        redis = await get_redis()
        # 测试连接
        await redis.ping()
        return redis
    except Exception:
        return None


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
    redis: Optional[Redis] = Depends(get_redis_optional)
) -> User:
    """
    获取当前登录用户
    :param credentials: 认证凭证
    :param db: 数据库会话
    :param redis: Redis 客户端（可选）
    :return: 当前用户对象
    """
    if not credentials:
        raise UnauthorizedException("未提供认证令牌")
    
    token = credentials.credentials
    
    # 检查令牌是否在黑名单中（如果 Redis 可用）
    if redis:
        if await redis.get(f"token_blacklist:{token}"):
            raise UnauthorizedException("令牌已失效")
    
    # 解码令牌
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise UnauthorizedException("无效的访问令牌")
    
    user_id = payload.get("user_id")
    if not user_id:
        raise UnauthorizedException("无效的访问令牌")
    
    # 获取用户
    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)
    if not user or not user.is_active:
        raise UnauthorizedException("用户不存在或已禁用")
    
    return user


async def get_current_user_ws(token: str, db: AsyncSession = Depends(get_db)) -> Optional[User]:
    """
    WebSocket 连接时获取当前用户
    :param token: JWT令牌
    :param db: 数据库会话
    :return: 当前用户对象，如果验证失败返回 None
    """
    if not token:
        return None
    
    # 解码令牌
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        return None
    
    user_id = payload.get("user_id")
    if not user_id:
        return None
    
    # 获取用户
    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)
    if not user or not user.is_active:
        return None
    
    return user


async def get_current_family(
    user: User = Depends(get_current_user)
):
    """
    获取当前用户所在的家庭
    :param user: 当前用户
    :return: 当前家庭对象
    """
    if not user.current_family_id:
        raise UnauthorizedException("用户未加入任何家庭")
    
    return user.current_family_id


async def require_member(
    user: User = Depends(get_current_user),
    family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
) -> str:
    """
    检查用户是否为家庭成员（任意角色）
    :param user: 当前用户
    :param family_id: 当前家庭ID
    :param db: 数据库会话
    :return: 用户角色
    """
    from app.repositories.family_repo import FamilyMemberRepository
    
    member_repo = FamilyMemberRepository(db)
    member = await member_repo.get_by_user_and_family(user.id, family_id)
    
    if not member:
        raise ForbiddenException("不是该家庭成员")
    
    return member.role


async def require_admin(
    role: str = Depends(require_member)
) -> str:
    """
    检查用户是否为管理员（admin 或 owner）
    :param role: 用户角色（由 require_member 注入）
    :return: 用户角色
    """
    if role not in ["admin", "owner"]:
        raise ForbiddenException("需要管理员权限")
    
    return role


async def require_owner(
    role: str = Depends(require_member)
) -> str:
    """
    检查用户是否为家庭所有者
    :param role: 用户角色（由 require_member 注入）
    :return: 用户角色
    """
    if role != "owner":
        raise ForbiddenException("需要家庭所有者权限")
    
    return role