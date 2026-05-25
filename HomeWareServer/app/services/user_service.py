"""
用户服务模块
处理用户相关业务逻辑
"""
import logging

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException, UnauthorizedException
from app.core.security import get_password_hash, verify_password
from app.models.user import User
from app.repositories.user_repo import UserRepository

logger = logging.getLogger(__name__)


class UserService:
    """用户服务"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_repo = UserRepository(db)
    
    async def get_user(self, user_id: int) -> User:
        """
        获取用户信息
        :param user_id: 用户ID
        :return: 用户对象
        """
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("用户不存在")
        return user
    
    async def update_user(self, user_id: int, data: dict) -> User:
        """
        更新用户信息
        :param user_id: 用户ID
        :param data: 更新数据
        :return: 更新后的用户对象
        """
        logger.info(f"更新用户信息 - 用户ID: {user_id}")
        
        # 过滤无效字段
        allowed_fields = ["nickname", "email", "avatar_url"]
        update_data = {k: v for k, v in data.items() if k in allowed_fields and v is not None}
        
        if not update_data:
            raise NotFoundException("没有需要更新的字段")
        
        user = await self.user_repo.update(user_id, update_data)
        if not user:
            raise NotFoundException("用户不存在")
        
        logger.info(f"用户信息更新成功 - 用户ID: {user_id}")
        return user
    
    async def change_password(self, user_id: int, old_password: str, new_password: str) -> User:
        """
        修改密码
        :param user_id: 用户ID
        :param old_password: 旧密码
        :param new_password: 新密码
        :return: 用户对象
        """
        logger.info(f"修改密码 - 用户ID: {user_id}")
        
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("用户不存在")
        
        # 验证旧密码
        if not verify_password(old_password, user.password_hash):
            raise UnauthorizedException("旧密码不正确")
        
        # 更新密码
        new_password_hash = get_password_hash(new_password)
        user = await self.user_repo.update(user_id, {"password_hash": new_password_hash})
        
        logger.info(f"密码修改成功 - 用户ID: {user_id}")
        return user