"""
消耗预测服务模块
实现消耗预测算法
"""
import logging
from datetime import date, datetime, timedelta
from typing import Dict, List, Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item
from app.models.usage_record import UsageRecord

logger = logging.getLogger(__name__)


class PredictionService:
    """消耗预测服务"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def calculate_avg_daily_consumption(self, item_id: int) -> float:
        """
        计算日均消耗量
        算法：
        1. 查询该物品所有 type=1(使用) 的 usage_records，按 created_at 排序
        2. 如果记录 < 2 条：
           - consumed = purchase_quantity - current_quantity
           - days = (today - item.created_at).days
           - 如果 days <= 0：返回 0
           - 返回 consumed / days
        3. 如果记录 >= 2 条：加权平均法
        """
        # 获取物品信息
        item = await self.db.get(Item, item_id)
        if not item:
            return 0.0

        # 查询使用记录（type=1）
        result = await self.db.execute(
            select(UsageRecord)
            .filter(UsageRecord.item_id == item_id, UsageRecord.type == 1)
            .order_by(UsageRecord.created_at.asc())
        )
        usage_records = result.scalars().all()

        if len(usage_records) < 2:
            # 记录不足，使用购买量和当前量计算
            if not item.created_at:
                return 0.0

            today = date.today()
            days = (today - item.created_at.date()).days

            if days <= 0:
                return 0.0

            consumed = item.purchase_quantity - float(item.current_quantity)
            if consumed <= 0:
                return 0.0

            return consumed / days

        # 加权平均法计算
        total_rate = 0.0
        total_weight = 0.0

        for i in range(len(usage_records) - 1):
            current_record = usage_records[i]
            next_record = usage_records[i + 1]

            interval_days = (next_record.created_at - current_record.created_at).days
            if interval_days <= 0:
                continue

            # 计算消耗速率
            rate = float(next_record.quantity) / interval_days
            if rate <= 0:
                continue

            # 权重：越近的记录权重越高
            weight = i + 1
            total_rate += rate * weight
            total_weight += weight

        if total_weight <= 0:
            return 0.0

        return total_rate / total_weight

    async def predict_empty_date(self, item_id: int) -> Optional[date]:
        """
        预测物品用完日期
        :param item_id: 物品ID
        :return: 预计用完日期
        """
        avg = await self.calculate_avg_daily_consumption(item_id)

        if avg <= 0:
            return None

        item = await self.db.get(Item, item_id)
        if not item:
            return None

        current_quantity = float(item.current_quantity)
        if current_quantity <= 0:
            return date.today()

        days_remaining = current_quantity / avg
        return date.today() + timedelta(days=days_remaining)

    async def get_prediction(self, item_id: int) -> Dict:
        """
        获取物品预测信息
        :param item_id: 物品ID
        :return: 预测信息字典
        """
        item = await self.db.get(Item, item_id)
        if not item:
            return {
                "avg_daily_consumption": 0.0,
                "predicted_empty_date": None,
                "days_until_empty": None,
                "confidence": "low",
                "should_repurchase": False,
                "usage_history": []
            }

        # 计算日均消耗
        avg_daily = await self.calculate_avg_daily_consumption(item_id)

        # 预测用完日期
        empty_date = await self.predict_empty_date(item_id)

        # 计算距离用完天数
        days_until_empty = None
        if empty_date:
            days_until_empty = max(0, (empty_date - date.today()).days)

        # 计算置信度
        result = await self.db.execute(
            select(func.count(UsageRecord.id))
            .filter(UsageRecord.item_id == item_id, UsageRecord.type == 1)
        )
        record_count = result.scalar_one_or_none() or 0

        if record_count < 3:
            confidence = "low"
        elif record_count <= 10:
            confidence = "medium"
        else:
            confidence = "high"

        # 判断是否需要补货
        should_repurchase = False
        if days_until_empty is not None and days_until_empty <= 7:
            should_repurchase = True
        elif float(item.current_quantity) <= float(item.safety_stock):
            should_repurchase = True

        # 获取使用历史
        history_result = await self.db.execute(
            select(
                UsageRecord.created_at,
                UsageRecord.quantity,
                UsageRecord.operator_name
            )
            .filter(UsageRecord.item_id == item_id, UsageRecord.type == 1)
            .order_by(UsageRecord.created_at.desc())
            .limit(20)
        )
        history = []
        for row in history_result.all():
            history.append({
                "date": row[0].strftime("%Y-%m-%d") if row[0] else None,
                "quantity": float(row[1]) if row[1] else 0,
                "operator": row[2]
            })
        history.reverse()

        return {
            "avg_daily_consumption": avg_daily,
            "predicted_empty_date": empty_date.isoformat() if empty_date else None,
            "days_until_empty": days_until_empty,
            "confidence": confidence,
            "should_repurchase": should_repurchase,
            "usage_history": history
        }

    async def batch_update_predictions(self, family_id: Optional[int] = None):
        """
        批量更新所有物品的预测数据
        :param family_id: 家庭ID（可选，为空则更新所有家庭）
        """
        logger.info("开始批量更新消耗预测")

        query = select(Item).filter(Item.status == 0)
        if family_id:
            query = query.filter(Item.family_id == family_id)

        result = await self.db.execute(query)
        items = result.scalars().all()

        updated_count = 0
        for item in items:
            try:
                avg_daily = await self.calculate_avg_daily_consumption(item.id)
                empty_date = await self.predict_empty_date(item.id)

                item.avg_daily_consumption = avg_daily
                item.predicted_empty_date = empty_date
                updated_count += 1
            except Exception as e:
                logger.error(f"更新物品 {item.id} 预测失败: {e}")

        await self.db.commit()
        logger.info(f"批量更新消耗预测完成，更新了 {updated_count} 个物品")
