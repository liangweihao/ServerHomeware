"""
物品数据访问层
"""
from typing import Dict, List, Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload

from app.models.category import Category
from app.models.item import Item
from app.models.location import Location
from app.repositories.base import BaseRepository


class ItemRepository(BaseRepository[Item]):
    """物品仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Item)
    
    async def get_by_id_with_relations(self, item_id: int) -> Optional[Item]:
        """获取物品及其关联数据（分类、位置、图片）"""
        result = await self.db.execute(
            select(Item)
            .options(joinedload(Item.category))
            .options(joinedload(Item.location))
            .options(joinedload(Item.images))
            .filter(Item.id == item_id)
        )
        return result.unique().scalar_one_or_none()
    
    async def get_by_family_id(self, family_id: int) -> List[Item]:
        """根据家庭ID获取物品列表"""
        return await self.get_multi_by_field("family_id", family_id)

    async def count_by_family_id(self, family_id: int) -> int:
        """统计家庭物品数量（仅 COUNT，不拉列表）"""
        result = await self.db.scalar(
            select(func.count()).select_from(Item).where(Item.family_id == family_id)
        )
        return int(result or 0)
    
    async def get_by_category_id(self, category_id: int) -> List[Item]:
        """根据分类ID获取物品列表"""
        return await self.get_multi_by_field("category_id", category_id)
    
    async def get_by_location_id(self, location_id: int) -> List[Item]:
        """根据位置ID获取物品列表"""
        return await self.get_multi_by_field("location_id", location_id)
    
    async def get_by_barcode(self, barcode: str, family_id: int) -> Optional[Item]:
        """根据条码查询物品"""
        result = await self.db.execute(
            select(Item).filter(
                Item.barcode == barcode,
                Item.family_id == family_id
            )
        )
        return result.scalar_one_or_none()
    
    async def soft_delete_by_family(self, family_id: int, deleted_at):
        """软删除家庭的所有物品"""
        await self.db.execute(
            Item.__table__.update()
            .where(Item.family_id == family_id)
            .values(deleted_at=deleted_at)
        )
        await self.db.commit()
    
    async def get_category_names(self, family_id: int) -> Dict[int, str]:
        """获取分类ID到名称的映射"""
        result = await self.db.execute(
            select(Category.id, Category.name).filter(
                (Category.family_id == family_id) | (Category.is_system == True)
            )
        )
        return {row[0]: row[1] for row in result.all()}
    
    async def get_location_paths(self, family_id: int) -> Dict[int, str]:
        """获取位置ID到完整路径的映射"""
        result = await self.db.execute(
            select(Location.id, Location.full_path).filter(
                Location.family_id == family_id
            )
        )
        return {row[0]: row[1] for row in result.all()}

    async def get_preview_images(self, item_ids: list[int]) -> Dict[int, str]:
        """
        批量获取物品首张预览图 URL
        :param item_ids: 物品 ID 列表
        :return: {item_id: first_image_url}
        """
        if not item_ids:
            return {}

        from app.models.item import ItemImage

        # 使用子查询获取每个物品的第一张图片（最小 sort_order）
        from sqlalchemy import and_
        result = await self.db.execute(
            select(ItemImage.item_id, ItemImage.url)
            .filter(ItemImage.item_id.in_(item_ids))
            .order_by(ItemImage.item_id, ItemImage.sort_order)
        )

        # 只取每个 item 的第一张（已按 sort_order 排序）
        preview_map = {}
        for row in result.all():
            if row[0] not in preview_map:
                preview_map[row[0]] = row[1]

        return preview_map