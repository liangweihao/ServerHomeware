"""
分类数据访问层
"""
from typing import List, Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.category import Category
from app.models.item import Item
from app.repositories.base import BaseRepository


class CategoryRepository(BaseRepository[Category]):
    """分类仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, Category)
    
    async def get_by_family_id(self, family_id: int) -> List[Category]:
        """根据家庭ID获取分类列表"""
        return await self.get_multi_by_field("family_id", family_id)
    
    async def get_by_parent_id(self, parent_id: int) -> List[Category]:
        """根据父分类ID获取子分类"""
        return await self.get_multi_by_field("parent_id", parent_id)
    
    async def get_top_level_by_family(self, family_id: int) -> List[Category]:
        """获取家庭顶级分类"""
        result = await self.db.execute(
            select(Category).filter(
                Category.family_id == family_id,
                Category.parent_id.is_(None)
            )
        )
        return result.scalars().all()
    
    async def get_categories_with_family(self, family_id: int) -> List[Category]:
        """
        获取系统预设分类和当前家庭的自定义分类
        :param family_id: 家庭ID
        :return: 分类列表
        """
        result = await self.db.execute(
            select(Category).filter(
                (Category.family_id == family_id) | 
                (Category.is_system == True)
            ).filter(Category.is_active == True)
        )
        return result.scalars().all()
    
    async def count_items_in_category(self, category_id: int) -> int:
        """统计分类下的物品数量"""
        result = await self.db.execute(
            select(func.count(Item.id)).filter(Item.category_id == category_id)
        )
        return result.scalar() or 0
    
    async def count_child_categories(self, parent_id: int) -> int:
        """统计子分类数量"""
        result = await self.db.execute(
            select(func.count(Category.id)).filter(Category.parent_id == parent_id)
        )
        return result.scalar() or 0