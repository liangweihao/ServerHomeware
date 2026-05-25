"""
位置数据访问层
"""
from typing import List

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item
from app.models.location import Location
from app.repositories.base import BaseRepository


class LocationRepository(BaseRepository[Location]):
    """位置仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Location)
    
    async def get_by_family_id(self, family_id: int) -> List[Location]:
        """根据家庭ID获取位置列表"""
        return await self.get_multi_by_field("family_id", family_id)
    
    async def get_by_parent_id(self, parent_id: int) -> List[Location]:
        """根据父位置ID获取子位置"""
        return await self.get_multi_by_field("parent_id", parent_id)
    
    async def get_top_level_by_family(self, family_id: int) -> List[Location]:
        """获取家庭顶级位置"""
        result = await self.db.execute(
            select(Location).filter(
                Location.family_id == family_id,
                Location.parent_id.is_(None)
            )
        )
        return result.scalars().all()
    
    async def get_location_item_counts(self, family_id: int) -> List[tuple]:
        """获取每个位置的物品数量"""
        result = await self.db.execute(
            select(
                Item.location_id,
                func.count(Item.id)
            ).filter(
                Item.family_id == family_id
            ).group_by(Item.location_id)
        )
        return result.all()
    
    async def get_items_in_location(self, location_id: int, family_id: int) -> List[Item]:
        """获取位置下的物品列表"""
        result = await self.db.execute(
            select(Item).filter(
                Item.location_id == location_id,
                Item.family_id == family_id
            )
        )
        return result.scalars().all()
    
    async def count_items_in_locations(self, location_ids: List[int]) -> int:
        """统计多个位置下的物品数量"""
        if not location_ids:
            return 0
        result = await self.db.execute(
            select(func.count(Item.id)).filter(
                Item.location_id.in_(location_ids)
            )
        )
        return result.scalar() or 0