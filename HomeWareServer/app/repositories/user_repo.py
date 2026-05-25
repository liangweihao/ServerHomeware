"""
用户数据访问层
"""
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """用户仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, User)
    
    async def get_by_phone(self, phone: str) -> Optional[User]:
        """根据手机号获取用户"""
        return await self.get_by_field("phone", phone)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        """根据邮箱获取用户"""
        return await self.get_by_field("email", email)
    
    async def exists_by_phone(self, phone: str) -> bool:
        """检查手机号是否存在"""
        return await self.exists_by_field("phone", phone)
    
    async def exists_by_email(self, email: str) -> bool:
        """检查邮箱是否存在"""
        return await self.exists_by_field("email", email)