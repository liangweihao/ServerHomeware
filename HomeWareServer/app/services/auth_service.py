"""
认证服务模块
处理用户注册、登录、Token刷新等业务逻辑
"""
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple

from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.exceptions import ConflictException, UnauthorizedException
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from app.models.family import Family, FamilyMember
from app.models.user import User
from app.repositories.family_repo import FamilyMemberRepository, FamilyRepository
from app.repositories.user_repo import UserRepository

logger = logging.getLogger(__name__)


class AuthService:
    """认证服务"""
    
    def __init__(self, db: AsyncSession, redis: Optional[Redis] = None):
        self.db = db
        self.redis = redis
        self.user_repo = UserRepository(db)
        self.family_repo = FamilyRepository(db)
        self.family_member_repo = FamilyMemberRepository(db)
    
    async def register(
        self, phone: str, password: str, nickname: str, email: Optional[str] = None
    ) -> Tuple[User, str, str]:
        """
        用户注册
        :param phone: 手机号
        :param password: 密码
        :param nickname: 昵称
        :param email: 邮箱（可选）
        :return: 用户对象、access_token、refresh_token
        """
        logger.info(f"用户注册 - 手机号: {phone}")
        
        # 检查手机号是否已存在
        if await self.user_repo.exists_by_phone(phone):
            raise ConflictException("该手机号已被注册")
        
        # 检查邮箱是否已存在
        if email and await self.user_repo.exists_by_email(email):
            raise ConflictException("该邮箱已被注册")
        
        # 创建用户
        password_hash = get_password_hash(password)
        user = await self.user_repo.create({
            "phone": phone,
            "password_hash": password_hash,
            "nickname": nickname,
            "email": email,
        })
        
        # 自动创建默认家庭
        invite_code = self._generate_invite_code()
        family = await self.family_repo.create({
            "name": f"{nickname}的家庭",
            "invite_code": invite_code,
            "owner_id": user.id,
        })
        
        # 添加用户到家庭
        await self.family_member_repo.create({
            "family_id": family.id,
            "user_id": user.id,
            "role": "owner",
        })
        
        # 更新用户当前家庭
        await self.user_repo.update(user.id, {"current_family_id": family.id})
        
        # 生成token
        access_token = create_access_token({"user_id": user.id, "family_id": family.id})
        refresh_token = create_refresh_token({"user_id": user.id, "family_id": family.id})
        
        logger.info(f"用户注册成功 - 用户ID: {user.id}, 家庭ID: {family.id}")
        
        return user, access_token, refresh_token
    
    async def login(self, phone: str, password: str) -> Tuple[User, str, str]:
        """
        用户登录
        :param phone: 手机号
        :param password: 密码
        :return: 用户对象、access_token、refresh_token
        """
        logger.info(f"用户登录 - 手机号: {phone}")
        
        # 获取用户
        user = await self.user_repo.get_by_phone(phone)
        if not user or not user.is_active:
            raise UnauthorizedException("手机号或密码错误")
        
        # 验证密码
        if not verify_password(password, user.password_hash):
            raise UnauthorizedException("手机号或密码错误")
        
        # 更新最后登录时间
        await self.user_repo.update(user.id, {"last_login_at": datetime.now(timezone.utc)})
        
        # 获取当前家庭
        family_id = user.current_family_id or 0
        
        # 生成token
        access_token = create_access_token({"user_id": user.id, "family_id": family_id})
        refresh_token = create_refresh_token({"user_id": user.id, "family_id": family_id})
        
        logger.info(f"用户登录成功 - 用户ID: {user.id}")
        
        return user, access_token, refresh_token
    
    async def refresh_token(self, refresh_token: str) -> Tuple[str, str]:
        """
        刷新Token
        :param refresh_token: 刷新令牌
        :return: 新的access_token、新的refresh_token
        """
        logger.info("刷新Token")
        
        # 解码refresh_token
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise UnauthorizedException("无效的刷新令牌")
        
        user_id = payload.get("user_id")
        family_id = payload.get("family_id", 0)
        
        if not user_id:
            raise UnauthorizedException("无效的刷新令牌")
        
        # 检查用户是否存在
        user = await self.user_repo.get_by_id(user_id)
        if not user or not user.is_active:
            raise UnauthorizedException("用户不存在或已禁用")
        
        # 生成新token
        new_access_token = create_access_token({"user_id": user.id, "family_id": family_id})
        new_refresh_token = create_refresh_token({"user_id": user.id, "family_id": family_id})
        
        logger.info(f"Token刷新成功 - 用户ID: {user.id}")
        
        return new_access_token, new_refresh_token
    
    async def logout(self, access_token: str):
        """
        用户登出
        :param access_token: 访问令牌
        """
        logger.info("用户登出")
        
        # 如果 Redis 不可用，跳过黑名单操作（开发模式）
        if not self.redis:
            logger.info("Redis 不可用，跳过 token 黑名单操作")
            return
        
        # 获取token过期时间
        payload = decode_token(access_token)
        if not payload:
            return
        
        # 计算剩余有效期
        exp = payload.get("exp")
        if exp:
            expire_time = datetime.fromtimestamp(exp, timezone.utc)
            now = datetime.now(timezone.utc)
            ttl = max(0, (expire_time - now).total_seconds())
            
            # 添加到黑名单
            await self.redis.setex(f"token_blacklist:{access_token}", int(ttl), "1")
        
        logger.info("用户登出成功")
    
    def _generate_invite_code(self) -> str:
        """生成8位邀请码"""
        import random
        import string
        return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))