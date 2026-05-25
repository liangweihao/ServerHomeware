"""
统计服务模块
实现数据统计业务逻辑
"""
import logging
from datetime import date, datetime, timedelta
from typing import Dict, List, Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.category import Category
from app.models.item import Item
from app.models.usage_record import UsageRecord

logger = logging.getLogger(__name__)

# 分类颜色配置
CATEGORY_COLORS = [
    "#FF8A65", "#4DB6AC", "#42A5F5", "#AB47BC",
    "#EC407A", "#FF7043", "#66BB6A", "#FFCA28",
    "#78909C", "#8D6E63", "#BDBDBD", "#90CAF9"
]


class StatisticsService:
    """统计服务"""

    def __init__(self, db: AsyncSession):
        self.db = db

    def _get_date_range(self, period: str, target_date: Optional[date] = None) -> Dict[str, date]:
        """
        获取日期范围
        :param period: 周期: week/month/year
        :param target_date: 目标日期（默认今天）
        :return: 包含 start, end, previous_start, previous_end 的字典
        """
        if not target_date:
            target_date = date.today()

        if period == "week":
            # 本周：周一到周日
            start = target_date - timedelta(days=target_date.weekday())
            end = start + timedelta(days=6)
            previous_start = start - timedelta(weeks=1)
            previous_end = previous_start + timedelta(days=6)
        elif period == "year":
            # 本年：1月1日到12月31日
            start = date(target_date.year, 1, 1)
            end = date(target_date.year, 12, 31)
            previous_start = date(target_date.year - 1, 1, 1)
            previous_end = date(target_date.year - 1, 12, 31)
        else:  # month
            # 本月：月初到月末
            start = date(target_date.year, target_date.month, 1)
            if target_date.month == 12:
                end = date(target_date.year, 12, 31)
            else:
                end = (date(target_date.year, target_date.month + 1, 1) - timedelta(days=1))
            if target_date.month == 1:
                previous_start = date(target_date.year - 1, 12, 1)
                previous_end = date(target_date.year - 1, 12, 31)
            else:
                previous_start = date(target_date.year, target_date.month - 1, 1)
                previous_end = (date(target_date.year, target_date.month, 1) - timedelta(days=1))

        return {
            "start": start,
            "end": end,
            "previous_start": previous_start,
            "previous_end": previous_end
        }

    async def get_overview(
        self,
        family_id: int,
        period: str = "month",
        date_str: Optional[str] = None
    ) -> Dict:
        """
        获取统计概览
        :param family_id: 家庭ID
        :param period: 周期: week/month/year
        :param date_str: 日期字符串（可选）
        :return: 统计概览数据
        """
        target_date = date.fromisoformat(date_str) if date_str else date.today()
        date_range = self._get_date_range(period, target_date)

        # 计算当前周期消费
        current_expense = await self._calculate_expense(family_id, date_range["start"], date_range["end"])

        # 计算上一周期消费
        previous_expense = await self._calculate_expense(family_id, date_range["previous_start"], date_range["previous_end"])

        # 计算趋势
        if previous_expense > 0:
            trend_percentage = ((current_expense - previous_expense) / previous_expense) * 100
            trend_direction = "up" if trend_percentage > 0 else ("down" if trend_percentage < 0 else "same")
        else:
            trend_percentage = 0
            trend_direction = "same"

        # 库存统计
        inventory_data = await self._get_inventory_stats(family_id)

        return {
            "period": period,
            "date_range": {
                "start": date_range["start"].isoformat(),
                "end": date_range["end"].isoformat()
            },
            "expense": {
                "total": current_expense,
                "previous_total": previous_expense,
                "trend_percentage": round(trend_percentage, 1),
                "trend_direction": trend_direction
            },
            "inventory": inventory_data
        }

    async def _calculate_expense(self, family_id: int, start_date: date, end_date: date) -> float:
        """
        计算指定时间段的消费金额
        :param family_id: 家庭ID
        :param start_date: 开始日期
        :param end_date: 结束日期
        :return: 消费金额
        """
        result = await self.db.execute(
            select(func.sum(Item.total_price))
            .filter(
                Item.family_id == family_id,
                Item.status != 3,  # 排除已删除
                Item.purchase_date >= start_date,
                Item.purchase_date <= end_date
            )
        )
        total = result.scalar_one_or_none()
        return float(total) if total else 0.0

    async def _get_inventory_stats(self, family_id: int) -> Dict:
        """
        获取库存统计
        :param family_id: 家庭ID
        :return: 库存统计数据
        """
        today = date.today()

        # 物品总数
        total_result = await self.db.execute(
            select(func.count(Item.id))
            .filter(Item.family_id == family_id, Item.status == 0)
        )
        total_items = total_result.scalar_one_or_none() or 0

        # 预警物品数（过期或库存不足）
        warning_result = await self.db.execute(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.status == 0,
                (Item.expiry_date.isnot(None) & (Item.expiry_date <= today + timedelta(days=7))) |
                (Item.current_quantity <= Item.safety_stock)
            )
        )
        warning_items = warning_result.scalar_one_or_none() or 0

        # 本月新增物品数
        this_month_start = date(today.year, today.month, 1)
        new_result = await self.db.execute(
            select(func.count(Item.id))
            .filter(
                Item.family_id == family_id,
                Item.created_at >= this_month_start
            )
        )
        new_items = new_result.scalar_one_or_none() or 0

        # 本月消耗物品数（使用记录 type=1）
        consumed_result = await self.db.execute(
            select(func.count(UsageRecord.id))
            .filter(
                UsageRecord.family_id == family_id,
                UsageRecord.type == 1,
                UsageRecord.created_at >= this_month_start
            )
        )
        consumed_items = consumed_result.scalar_one_or_none() or 0

        return {
            "total_items": total_items,
            "new_items": new_items,
            "consumed_items": consumed_items,
            "warning_items": warning_items
        }

    async def get_expense_trend(self, family_id: int, months: int = 6) -> List[Dict]:
        """
        获取消费趋势
        :param family_id: 家庭ID
        :param months: 近几个月
        :return: 消费趋势数据
        """
        today = date.today()
        result = []

        for i in range(months - 1, -1, -1):
            # 计算每个月的起始和结束日期
            year = today.year
            month = today.month - i

            if month <= 0:
                month += 12
                year -= 1

            month_start = date(year, month, 1)
            if month == 12:
                month_end = date(year, 12, 31)
            else:
                month_end = (date(year, month + 1, 1) - timedelta(days=1))

            # 计算该月消费
            expense = await self._calculate_expense(family_id, month_start, month_end)

            result.append({
                "month": f"{year}-{month:02d}",
                "amount": round(expense, 2)
            })

        return result

    async def get_category_breakdown(self, family_id: int, period: str = "month", date_str: Optional[str] = None) -> List[Dict]:
        """
        获取分类占比
        :param family_id: 家庭ID
        :param period: 周期: week/month/year
        :param date_str: 日期字符串（可选）
        :return: 分类占比数据
        """
        target_date = date.fromisoformat(date_str) if date_str else date.today()
        date_range = self._get_date_range(period, target_date)

        # 按分类统计消费
        result = await self.db.execute(
            select(
                Category.id.label("category_id"),
                Category.name.label("category_name"),
                func.sum(Item.total_price).label("total_amount")
            )
            .join(Item, Category.id == Item.category_id)
            .filter(
                Item.family_id == family_id,
                Item.status != 3,
                Item.purchase_date >= date_range["start"],
                Item.purchase_date <= date_range["end"]
            )
            .group_by(Category.id, Category.name)
            .order_by(func.sum(Item.total_price).desc())
        )

        category_data = result.all()

        # 计算总计
        total_amount = sum(float(row[2]) for row in category_data if row[2])

        # 构建响应
        breakdown = []
        for i, row in enumerate(category_data):
            category_id, category_name, amount = row
            if amount:
                percentage = (float(amount) / total_amount) * 100 if total_amount > 0 else 0
                breakdown.append({
                    "category_id": category_id,
                    "name": category_name,
                    "color": CATEGORY_COLORS[i % len(CATEGORY_COLORS)],
                    "amount": round(float(amount), 2),
                    "percentage": round(percentage, 1)
                })

        return breakdown

    async def get_waste_statistics(self, family_id: int, period: str = "month", date_str: Optional[str] = None) -> Dict:
        """
        获取浪费统计
        :param family_id: 家庭ID
        :param period: 周期: week/month/year
        :param date_str: 日期字符串（可选）
        :return: 浪费统计数据
        """
        target_date = date.fromisoformat(date_str) if date_str else date.today()
        date_range = self._get_date_range(period, target_date)

        # 查询丢弃记录（type=2）
        result = await self.db.execute(
            select(
                Item.name,
                Item.purchase_price,
                Item.expiry_date,
                UsageRecord.created_at,
                UsageRecord.notes
            )
            .join(UsageRecord, Item.id == UsageRecord.item_id)
            .filter(
                Item.family_id == family_id,
                UsageRecord.type == 2,  # 丢弃
                UsageRecord.created_at >= date_range["start"],
                UsageRecord.created_at <= date_range["end"]
            )
        )

        waste_items = []
        total_count = 0
        total_amount = 0.0

        for row in result.all():
            name, price, expiry_date, created_at, notes = row

            # 判断浪费原因
            if expiry_date and expiry_date < created_at.date():
                reason = "过期未食用"
            else:
                reason = notes if notes else "其他原因"

            item_price = float(price) if price else 0.0
            total_amount += item_price
            total_count += 1

            waste_items.append({
                "name": name,
                "price": round(item_price, 2),
                "expired_at": created_at.strftime("%Y-%m-%d"),
                "reason": reason
            })

        # 生成建议
        suggestion = self._generate_waste_suggestion(waste_items)

        return {
            "total_count": total_count,
            "total_amount": round(total_amount, 2),
            "items": waste_items,
            "suggestion": suggestion
        }

    def _generate_waste_suggestion(self, waste_items: List[Dict]) -> str:
        """
        根据浪费数据生成建议
        :param waste_items: 浪费物品列表
        :return: 建议文本
        """
        if not waste_items:
            return "暂无浪费记录，继续保持！"

        # 统计各类原因
        reason_counts = {}
        for item in waste_items:
            reason = item["reason"]
            reason_counts[reason] = reason_counts.get(reason, 0) + 1

        # 找出最主要的浪费原因
        main_reason = max(reason_counts, key=reason_counts.get)

        if main_reason == "过期未食用":
            return "建议：减少一次性购买量，注意食品保质期"
        elif "破损" in main_reason:
            return "建议：检查储存条件，避免物品损坏"
        else:
            return "建议：定期清理库存，避免物品闲置"

    async def get_consumption_ranking(self, family_id: int, period: str = "month", limit: int = 10) -> List[Dict]:
        """
        获取消耗排行
        :param family_id: 家庭ID
        :param period: 周期: week/month/year
        :param limit: 返回数量限制
        :return: 消耗排行数据
        """
        target_date = date.today()
        date_range = self._get_date_range(period, target_date)

        # 按物品统计消耗
        result = await self.db.execute(
            select(
                Item.name.label("item_name"),
                Item.unit,
                func.sum(UsageRecord.quantity).label("total_consumed"),
                func.sum(Item.purchase_price * UsageRecord.quantity).label("total_cost")
            )
            .join(UsageRecord, Item.id == UsageRecord.item_id)
            .filter(
                Item.family_id == family_id,
                UsageRecord.type == 1,  # 使用
                UsageRecord.created_at >= date_range["start"],
                UsageRecord.created_at <= date_range["end"]
            )
            .group_by(Item.id, Item.name, Item.unit)
            .order_by(func.sum(UsageRecord.quantity).desc())
            .limit(limit)
        )

        ranking = []
        for row in result.all():
            item_name, unit, total_consumed, total_cost = row
            ranking.append({
                "item_name": item_name,
                "total_consumed": round(float(total_consumed), 2) if total_consumed else 0,
                "unit": unit or "件",
                "total_cost": round(float(total_cost), 2) if total_cost else 0
            })

        return ranking
