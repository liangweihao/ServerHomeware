"""
家庭数据访问层
"""
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.family import Family, FamilyMember
from app.repositories.base import BaseRepository


class FamilyRepository(BaseRepository[Family]):
    """家庭仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Family)
    
    async def get_by_invite_code(self, invite_code: str) -> Optional[Family]:
        """根据邀请码获取家庭"""
        return await self.get_by_field("invite_code", invite_code)
    
    async def get_by_owner_id(self, owner_id: int) -> Optional[Family]:
        """根据创建者ID获取家庭"""
        return await self.get_by_field("owner_id", owner_id)
    
    async def exists_by_invite_code(self, invite_code: str) -> bool:
        """检查邀请码是否存在"""
        return await self.exists_by_field("invite_code", invite_code)


class FamilyMemberRepository(BaseRepository[FamilyMember]):
    """家庭成员仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, FamilyMember)
    
    async def get_by_user_id(self, user_id: int) -> List[FamilyMember]:
        """根据用户ID获取所有家庭关系"""
        return await self.get_multi_by_field("user_id", user_id)
    
    async def get_by_family_id(self, family_id: int) -> List[FamilyMember]:
        """根据家庭ID获取所有成员"""
        return await self.get_multi_by_field("family_id", family_id)
    
    async def get_by_user_and_family(self, user_id: int, family_id: int) -> Optional[FamilyMember]:
        """根据用户ID和家庭ID获取成员关系"""
        result = await self.db.execute(
            select(FamilyMember).filter(
                FamilyMember.user_id == user_id,
                FamilyMember.family_id == family_id
            )
        )
        return result.scalar_one_or_none()
    
    async def is_member(self, user_id: int, family_id: int) -> bool:
        """检查用户是否是家庭成员"""
        return (await self.get_by_user_and_family(user_id, family_id)) is not None