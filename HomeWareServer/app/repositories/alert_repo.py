"""
提醒数据访问层
提供提醒相关的数据库查询操作
"""
from datetime import date, datetime, timedelta
from typing import Dict, List, Optional, Tuple

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.category import Category
from app.models.item import Item
from app.models.location import Location


class AlertRepository:
    """提醒数据访问层"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_expiry_alerts(self, family_id: int) -> List[Tuple]:
        """
        获取过期提醒物品
        查询条件：status=0 AND expiry_date不为空 AND expiry_date - expiry_alert_days <= today
        """
        today = date.today()
        
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.expiry_date,
                Item.expiry_alert_days,
                Item.category_id,
                Item.location_id,
                Item.current_quantity,
                Item.unit,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                func.julianday(Item.expiry_date) - Item.expiry_alert_days <= func.julianday(today)
            )
            .order_by(Item.expiry_date.asc())
        )
        
        return result.all()

    async def get_stock_alerts(self, family_id: int) -> List[Tuple]:
        """
        获取库存提醒物品
        查询条件：status=0 AND current_quantity <= safety_stock AND stock_alert=true
        """
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.current_quantity,
                Item.safety_stock,
                Item.unit,
                Item.category_id,
                Item.location_id,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.current_quantity <= Item.safety_stock,
                Item.stock_alert == True
            )
            .order_by(Item.current_quantity.asc())
        )
        
        return result.all()

    async def get_replenish_alerts(self, family_id: int) -> List[Tuple]:
        """
        获取补购提醒物品
        查询条件：status=1 且最近7天变为用完的
        """
        seven_days_ago = datetime.now() - timedelta(days=7)
        
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.purchase_price,
                Item.purchase_date,
                Item.category_id,
                Item.location_id,
                Item.updated_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 1,
                Item.updated_at >= seven_days_ago
            )
            .order_by(Item.updated_at.desc())
        )
        
        return result.all()

    async def get_warranty_alerts(self, family_id: int) -> List[Tuple]:
        """
        获取保修提醒物品
        查询条件：warranty_date - 30天 <= today
        """
        today = date.today()
        
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.warranty_date,
                Item.category_id,
                Item.location_id,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.warranty_date.isnot(None),
                func.julianday(Item.warranty_date) - 30 <= func.julianday(today)
            )
            .order_by(Item.warranty_date.asc())
        )
        
        return result.all()

    async def get_alert_counts(self, family_id: int) -> Dict[str, int]:
        """
        获取各类提醒数量统计
        返回：{expiry: int, stock: int, replenish: int, warranty: int, total: int}
        """
        today = date.today()
        seven_days_ago = datetime.now() - timedelta(days=7)
        
        # 过期提醒数量
        expiry_count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                func.julianday(Item.expiry_date) - Item.expiry_alert_days <= func.julianday(today)
            )
        )
        
        # 库存提醒数量
        stock_count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.current_quantity <= Item.safety_stock,
                Item.stock_alert == True
            )
        )
        
        # 补购提醒数量
        replenish_count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 1,
                Item.updated_at >= seven_days_ago
            )
        )
        
        # 保修提醒数量
        warranty_count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.warranty_date.isnot(None),
                func.julianday(Item.warranty_date) - 30 <= func.julianday(today)
            )
        )
        
        return {
            "expiry": expiry_count or 0,
            "stock": stock_count or 0,
            "replenish": replenish_count or 0,
            "warranty": warranty_count or 0,
            "total": (expiry_count or 0) + (stock_count or 0) + (replenish_count or 0) + (warranty_count or 0)
        }

    async def get_expiring_items(self, family_id: int, days: int = 7) -> List[Tuple]:
        """
        获取即将过期物品列表
        :param family_id: 家庭ID
        :param days: 几天内过期
        :return: 即将过期物品列表
        """
        today = date.today()
        target_date = today + timedelta(days=days)

        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.expiry_date,
                Item.expiry_alert_days,
                Item.category_id,
                Item.location_id,
                Item.current_quantity,
                Item.unit,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date <= target_date,
                Item.expiry_date >= today
            )
            .order_by(Item.expiry_date.asc())
        )

        return result.all()

    async def get_low_stock_items(self, family_id: int) -> List[Tuple]:
        """
        获取库存不足物品列表
        :param family_id: 家庭ID
        :return: 库存不足物品列表
        """
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.current_quantity,
                Item.safety_stock,
                Item.unit,
                Item.category_id,
                Item.location_id,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.current_quantity <= Item.safety_stock,
                Item.stock_alert == True
            )
            .order_by(Item.current_quantity.asc())
        )

        return result.all()

    async def get_nearest_expiry_item(self, family_id: int) -> Optional[Tuple]:
        """
        获取最近要过期的物品
        :param family_id: 家庭ID
        :return: 最近过期的物品
        """
        today = date.today()

        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.expiry_date,
                Item.expiry_alert_days,
                Item.category_id,
                Item.location_id,
                Item.current_quantity,
                Item.unit,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date >= today
            )
            .order_by(Item.expiry_date.asc())
            .limit(1)
        )

        return result.scalar_one_or_none()

    async def get_nearest_empty_item(self, family_id: int) -> Optional[Tuple]:
        """
        获取最近要用完的物品（库存最少）
        :param family_id: 家庭ID
        :return: 库存最少的物品
        """
        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.current_quantity,
                Item.safety_stock,
                Item.unit,
                Item.category_id,
                Item.location_id,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.stock_alert == True
            )
            .order_by(Item.current_quantity.asc())
            .limit(1)
        )

        return result.scalar_one_or_none()

    async def get_expiring_count_within_days(self, family_id: int, days: int = 7) -> int:
        """
        获取几天内即将过期的物品数量
        :param family_id: 家庭ID
        :param days: 几天内
        :return: 数量
        """
        today = date.today()
        target_date = today + timedelta(days=days)

        count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date <= target_date,
                Item.expiry_date >= today
            )
        )

        return count or 0

    async def get_expired_count(self, family_id: int) -> int:
        """
        获取已过期物品数量
        :param family_id: 家庭ID
        :return: 数量
        """
        today = date.today()

        count = await self.db.scalar(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date < today
            )
        )

        return count or 0

    async def get_expired_items(self, family_id: int) -> List[Tuple]:
        """
        获取已过期物品列表（使用中且 expiry_date 早于今日）
        :param family_id: 家庭ID
        :return: 已过期物品列表，按过期日升序（过期最久在前）
        """
        today = date.today()

        result = await self.db.execute(
            select(
                Item.id,
                Item.name,
                Item.expiry_date,
                Item.expiry_alert_days,
                Item.category_id,
                Item.location_id,
                Item.current_quantity,
                Item.unit,
                Item.created_at,
                Category.name.label('category_name'),
                Location.full_path.label('location_path')
            )
            .join(Category, Item.category_id == Category.id)
            .outerjoin(Location, Item.location_id == Location.id)
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date < today
            )
            .order_by(Item.expiry_date.asc())
        )

        return result.all()
