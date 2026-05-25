"""
使用记录数据访问层
"""
from typing import List

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.usage_record import UsageRecord
from app.repositories.base import BaseRepository


class UsageRecordRepository(BaseRepository[UsageRecord]):
    """使用记录仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, UsageRecord)
    
    async def get_by_item_id(self, item_id: int) -> List[UsageRecord]:
        """根据物品ID获取使用记录"""
        return await self.get_multi_by_field("item_id", item_id)
    
    async def get_recent_by_item(self, item_id: int, limit: int = 5) -> List[UsageRecord]:
        """获取物品最近的使用记录"""
        result = await self.db.execute(
            select(UsageRecord)
            .filter(UsageRecord.item_id == item_id)
            .order_by(UsageRecord.created_at.desc())
            .limit(limit)
        )
        return result.scalars().all()
    
    async def get_by_family_id(self, family_id: int) -> List[UsageRecord]:
        """根据家庭ID获取使用记录"""
        return await self.get_multi_by_field("family_id", family_id)