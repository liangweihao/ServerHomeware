"""
购物清单数据访问层
"""
from typing import Dict, List, Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item
from app.models.shopping import ShoppingItem
from app.repositories.base import BaseRepository


class ShoppingRepository(BaseRepository[ShoppingItem]):
    """购物清单仓库"""
    
    def __init__(self, db: AsyncSession):
        super().__init__(db, ShoppingItem)
    
    async def get_by_family_id(self, family_id: int) -> List[ShoppingItem]:
        """根据家庭ID获取购物清单"""
        return await self.get_multi_by_field("family_id", family_id)
    
    async def get_unpurchased_by_family(self, family_id: int) -> List[ShoppingItem]:
        """获取家庭未购买的购物项"""
        result = await self.db.execute(
            select(ShoppingItem).filter(
                ShoppingItem.family_id == family_id,
                ShoppingItem.is_purchased == False
            )
        )
        return result.scalars().all()

    async def get_list(
        self,
        family_id: int,
        status: str = "all",
        page: int = 1,
        page_size: int = 20
    ) -> Dict:
        """
        获取购物清单（分页）
        :param family_id: 家庭ID
        :param status: 状态筛选: pending/purchased/all
        :param page: 页码
        :param page_size: 每页大小
        :return: 分页结果
        """
        query = select(ShoppingItem).filter(ShoppingItem.family_id == family_id)

        # 状态筛选
        if status == "pending":
            query = query.filter(ShoppingItem.is_purchased == False)
        elif status == "purchased":
            query = query.filter(ShoppingItem.is_purchased == True)

        # 计算总数
        count_query = select(func.count()).select_from(query.subquery())
        total = await self.db.scalar(count_query) or 0

        # 分页
        offset = (page - 1) * page_size
        query = query.offset(offset).limit(page_size).order_by(ShoppingItem.created_at.desc())

        result = await self.db.execute(query)
        items = result.scalars().all()

        # 计算页数
        pages = (total + page_size - 1) // page_size

        return {
            "items": items,
            "total": total,
            "page": page,
            "page_size": page_size,
            "pages": pages
        }

    async def get_with_related_info(self, family_id: int) -> List:
        """
        获取购物清单（含关联物品信息）
        :param family_id: 家庭ID
        :return: 购物项列表（含关联物品名称）
        """
        result = await self.db.execute(
            select(
                ShoppingItem,
                Item.name.label("related_item_name")
            )
            .outerjoin(Item, ShoppingItem.related_item_id == Item.id)
            .filter(ShoppingItem.family_id == family_id)
            .order_by(ShoppingItem.created_at.desc())
        )
        return result.all()
