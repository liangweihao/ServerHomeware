"""
提醒服务模块
处理提醒相关业务逻辑
"""
import logging
from datetime import date, timedelta
from typing import Dict, List, Literal, Tuple, Union

from sqlalchemy.ext.asyncio import AsyncSession

from app.repositories.alert_repo import AlertRepository

logger = logging.getLogger(__name__)

AlertType = Literal["all", "expiry", "stock", "replenish", "warranty"]


class AlertService:
    """提醒服务"""

    def __init__(self, db: AsyncSession):
        self.repo = AlertRepository(db)

    async def get_alerts(self, family_id: int, alert_type: AlertType = "all") -> List[Dict]:
        """
        获取提醒列表
        :param family_id: 当前家庭ID
        :param alert_type: 提醒类型（all/expiry/stock/replenish/warranty）
        :return: 提醒列表
        """
        if alert_type == "all":
            return await self.get_all_alerts(family_id)
        elif alert_type == "expiry":
            return await self._format_expiry_alerts(await self.repo.get_expiry_alerts(family_id))
        elif alert_type == "stock":
            return await self._format_stock_alerts(await self.repo.get_stock_alerts(family_id))
        elif alert_type == "replenish":
            return await self._format_replenish_alerts(await self.repo.get_replenish_alerts(family_id))
        elif alert_type == "warranty":
            return await self._format_warranty_alerts(await self.repo.get_warranty_alerts(family_id))
        else:
            return []

    async def get_all_alerts(self, family_id: int) -> List[Dict]:
        """
        获取所有类型的提醒（按紧急程度排序）
        :param family_id: 当前家庭ID
        :return: 合并后的提醒列表
        """
        # 并行获取各类提醒
        expiry_alerts = await self._format_expiry_alerts(await self.repo.get_expiry_alerts(family_id))
        stock_alerts = await self._format_stock_alerts(await self.repo.get_stock_alerts(family_id))
        replenish_alerts = await self._format_replenish_alerts(await self.repo.get_replenish_alerts(family_id))
        warranty_alerts = await self._format_warranty_alerts(await self.repo.get_warranty_alerts(family_id))

        # 合并并按紧急程度排序（紧急程度高的在前）
        all_alerts = expiry_alerts + stock_alerts + replenish_alerts + warranty_alerts
        all_alerts.sort(key=lambda x: x["urgency"], reverse=True)

        return all_alerts

    async def get_alert_summary(self, family_id: int) -> Dict[str, int]:
        """
        获取提醒统计摘要（增强版）
        :param family_id: 当前家庭ID
        :return: 各类提醒数量统计及最近物品信息
        """
        today = date.today()

        # 获取基本统计
        base_counts = await self.repo.get_alert_counts(family_id)

        # 获取增强统计
        expiring_count = await self.repo.get_expiring_count_within_days(family_id, 7)
        expired_count = await self.repo.get_expired_count(family_id)
        low_stock_items = await self.repo.get_low_stock_items(family_id)
        low_stock_count = len(low_stock_items)

        # 获取最近过期物品
        nearest_expiry_raw = await self.repo.get_nearest_expiry_item(family_id)
        nearest_expiry = None
        if nearest_expiry_raw:
            expiry_date = nearest_expiry_raw[2]
            days_until = (expiry_date - today).days if expiry_date else 0
            nearest_expiry = {
                "id": nearest_expiry_raw[0],
                "name": nearest_expiry_raw[1],
                "days_until_expiry": days_until,
                "expiry_date": expiry_date.isoformat() if expiry_date else None,
                "category_name": nearest_expiry_raw[9],
                "location_path": nearest_expiry_raw[10]
            }

        # 获取最近要用完的物品
        nearest_empty_raw = await self.repo.get_nearest_empty_item(family_id)
        nearest_empty = None
        if nearest_empty_raw:
            nearest_empty = {
                "id": nearest_empty_raw[0],
                "name": nearest_empty_raw[1],
                "current_quantity": float(nearest_empty_raw[2]) if nearest_empty_raw[2] else 0,
                "safety_stock": float(nearest_empty_raw[3]) if nearest_empty_raw[3] else 0,
                "unit": nearest_empty_raw[4],
                "category_name": nearest_empty_raw[8],
                "location_path": nearest_empty_raw[9]
            }

        # 获取待购数量（status=1 物品数量）
        from app.models.item import Item
        from sqlalchemy import select, func
        shopping_count = await self.db.scalar(
            select(func.count(Item.id)).filter(
                Item.family_id == family_id,
                Item.status == 1
            )
        ) or 0

        return {
            **base_counts,
            "expiring_count": expiring_count,
            "expired_count": expired_count,
            "low_stock_count": low_stock_count,
            "shopping_count": shopping_count,
            "nearest_expiry": nearest_expiry,
            "nearest_empty": nearest_empty
        }

    async def get_expiring_items(
        self,
        family_id: int,
        days: int = 7
    ) -> List[Dict]:
        """
        获取即将过期物品列表
        :param family_id: 家庭ID
        :param days: 几天内过期
        :return: 物品列表
        """
        today = date.today()
        raw_items = await self.repo.get_expiring_items(family_id, days)

        result = []
        for row in raw_items:
            expiry_date = row[2]
            days_until = (expiry_date - today).days if expiry_date else 0

            result.append({
                "id": row[0],
                "name": row[1],
                "days_until_expiry": days_until,
                "expiry_date": expiry_date.isoformat() if expiry_date else None,
                "location_path": row[10],
                "category_name": row[9],
                "current_quantity": float(row[6]) if row[6] else 0,
                "unit": row[7]
            })

        return result

    async def get_low_stock_items_list(self, family_id: int) -> List[Dict]:
        """
        获取库存不足物品列表
        :param family_id: 家庭ID
        :return: 物品列表
        """
        raw_items = await self.repo.get_low_stock_items(family_id)

        result = []
        for row in raw_items:
            result.append({
                "id": row[0],
                "name": row[1],
                "current_quantity": float(row[2]) if row[2] else 0,
                "safety_stock": float(row[3]) if row[3] else 0,
                "unit": row[4],
                "location_path": row[9],
                "category_name": row[8]
            })

        return result

    async def _format_expiry_alerts(self, raw_alerts: List[Tuple]) -> List[Dict]:
        """格式化过期提醒数据"""
        today = date.today()
        alerts = []
        
        for row in raw_alerts:
            expiry_date = row[2]
            days_left = (expiry_date - today).days
            
            # 计算紧急程度：过期或即将过期为最高紧急
            if days_left < 0:
                urgency = 1  # 已过期，最紧急
                message = f"{row[1]}已过期{abs(days_left)}天"
            elif days_left == 0:
                urgency = 1  # 今天过期
                message = f"{row[1]}今天过期"
            elif days_left <= 3:
                urgency = 2  # 即将过期
                message = f"{row[1]}还剩{days_left}天过期"
            else:
                urgency = 3  # 一般提醒
                message = f"{row[1]}还剩{days_left}天过期"
            
            alerts.append({
                "id": row[0],
                "item_id": row[0],
                "name": row[1],
                "type": "expiry",
                "urgency": urgency,
                "message": message,
                "location_path": row[10],
                "category_name": row[9],
                "expiry_date": expiry_date.isoformat() if expiry_date else None,
                "current_quantity": float(row[6]) if row[6] else 0,
                "unit": row[7],
                "created_at": row[8].isoformat() if row[8] else None
            })
        
        return alerts

    async def _format_stock_alerts(self, raw_alerts: List[Tuple]) -> List[Dict]:
        """格式化库存提醒数据"""
        alerts = []
        
        for row in raw_alerts:
            current_qty = float(row[2]) if row[2] else 0
            safety_stock = float(row[3]) if row[3] else 0
            
            # 计算紧急程度：库存越少越紧急
            if current_qty <= 0:
                urgency = 1
                message = f"{row[1]}库存已耗尽"
            elif current_qty <= safety_stock * 0.5:
                urgency = 2
                message = f"{row[1]}库存不足，仅剩{current_qty}{row[4]}"
            else:
                urgency = 3
                message = f"{row[1]}库存偏低，剩余{current_qty}{row[4]}"
            
            alerts.append({
                "id": row[0],
                "item_id": row[0],
                "name": row[1],
                "type": "stock",
                "urgency": urgency,
                "message": message,
                "location_path": row[9],
                "category_name": row[8],
                "current_quantity": current_qty,
                "safety_stock": safety_stock,
                "unit": row[4],
                "created_at": row[7].isoformat() if row[7] else None
            })
        
        return alerts

    async def _format_replenish_alerts(self, raw_alerts: List[Tuple]) -> List[Dict]:
        """格式化补购提醒数据"""
        alerts = []
        
        for row in raw_alerts:
            alerts.append({
                "id": row[0],
                "item_id": row[0],
                "name": row[1],
                "type": "replenish",
                "urgency": 2,  # 补购提醒优先级中等
                "message": f"{row[1]}已用完，需要补购",
                "location_path": row[8],
                "category_name": row[7],
                "purchase_price": float(row[2]) if row[2] else None,
                "purchase_date": row[3].isoformat() if row[3] else None,
                "created_at": row[6].isoformat() if row[6] else None
            })
        
        return alerts

    async def _format_warranty_alerts(self, raw_alerts: List[Tuple]) -> List[Dict]:
        """格式化保修提醒数据"""
        today = date.today()
        alerts = []
        
        for row in raw_alerts:
            warranty_date = row[2]
            days_left = (warranty_date - today).days
            
            if days_left < 0:
                urgency = 2
                message = f"{row[1]}保修已过期{abs(days_left)}天"
            elif days_left <= 7:
                urgency = 2
                message = f"{row[1]}保修还剩{days_left}天到期"
            else:
                urgency = 3
                message = f"{row[1]}保修还剩{days_left}天到期"
            
            alerts.append({
                "id": row[0],
                "item_id": row[0],
                "name": row[1],
                "type": "warranty",
                "urgency": urgency,
                "message": message,
                "location_path": row[5],
                "category_name": row[4],
                "warranty_date": warranty_date.isoformat() if warranty_date else None,
                "created_at": row[6].isoformat() if row[6] else None
            })
        
        return alerts
