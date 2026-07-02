"""
贡献度统计服务 — 基于 usage_records 聚合本月家庭协作数据
"""
from datetime import datetime
from typing import Any, Dict, List, Optional

from sqlalchemy import and_, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.usage_record import UsageRecord


class ContributionService:
    """家庭/用户贡献度统计"""

    def __init__(self, db: AsyncSession):
        self.db = db

    @staticmethod
    def _month_start() -> datetime:
        now = datetime.now()
        return now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    def _operator_filter(self, user_id: int, nickname: Optional[str]):
        """按操作人 ID 或昵称匹配记录"""
        clauses = [UsageRecord.operator_id == user_id]
        if nickname and nickname.strip():
            clauses.append(UsageRecord.operator_name == nickname.strip())
        return or_(*clauses)

    async def _count_user_actions(
        self,
        family_id: int,
        month_start: datetime,
        user_id: int,
        nickname: Optional[str],
        record_type: int,
    ) -> int:
        result = await self.db.scalar(
            select(func.count())
            .select_from(UsageRecord)
            .where(
                UsageRecord.family_id == family_id,
                UsageRecord.created_at >= month_start,
                UsageRecord.type == record_type,
                self._operator_filter(user_id, nickname),
            )
        )
        return int(result or 0)

    async def _count_family_actions(self, family_id: int, month_start: datetime) -> int:
        result = await self.db.scalar(
            select(func.count())
            .select_from(UsageRecord)
            .where(
                UsageRecord.family_id == family_id,
                UsageRecord.created_at >= month_start,
                UsageRecord.type.in_([0, 1]),
            )
        )
        return int(result or 0)

    async def get_user_contribution(
        self,
        family_id: int,
        user_id: int,
        nickname: Optional[str] = None,
    ) -> Dict[str, Any]:
        """获取指定用户本月贡献（客户端 record_count / consume_count 对齐）"""
        month_start = self._month_start()
        added = await self._count_user_actions(
            family_id, month_start, user_id, nickname, 0
        )
        used = await self._count_user_actions(
            family_id, month_start, user_id, nickname, 1
        )
        family_total = await self._count_family_actions(family_id, month_start)
        user_total = added + used
        contribution = (
            int(user_total / family_total * 100) if family_total > 0 else 0
        )

        ranking = await self._resolve_user_rank(
            family_id, month_start, user_id, nickname, user_total
        )

        return {
            "user_id": user_id,
            "record_count": added,
            "consume_count": used,
            "added_items": added,
            "used_count": used,
            "contribution": min(contribution, 100),
            "total_score": user_total,
            "ranking": ranking,
        }

    async def _resolve_user_rank(
        self,
        family_id: int,
        month_start: datetime,
        user_id: int,
        nickname: Optional[str],
        user_total: int,
    ) -> int:
        leaderboard = await self.get_family_leaderboard(family_id, limit=100)
        display_name = (nickname or "").strip()
        for entry in leaderboard:
            if entry.get("user_id") == user_id:
                return entry["rank"]
            if display_name and entry.get("name") == display_name:
                return entry["rank"]
        # 未上榜时按总量估算
        higher = sum(
            1
            for e in leaderboard
            if (e.get("record_count", 0) + e.get("consume_count", 0)) > user_total
        )
        return higher + 1 if user_total > 0 else len(leaderboard) + 1

    async def get_family_leaderboard(
        self, family_id: int, limit: int = 20
    ) -> List[Dict[str, Any]]:
        """家庭本月贡献排行 — 按 operator_name 聚合"""
        month_start = self._month_start()
        result = await self.db.execute(
            select(
                UsageRecord.operator_name,
                UsageRecord.operator_id,
                UsageRecord.type,
                func.count().label("cnt"),
            )
            .where(
                and_(
                    UsageRecord.family_id == family_id,
                    UsageRecord.created_at >= month_start,
                    UsageRecord.type.in_([0, 1]),
                )
            )
            .group_by(
                UsageRecord.operator_name,
                UsageRecord.operator_id,
                UsageRecord.type,
            )
        )

        agg: Dict[str, Dict[str, Any]] = {}
        for operator_name, operator_id, record_type, cnt in result.all():
            key = (operator_name or "未署名").strip() or "未署名"
            if key not in agg:
                agg[key] = {
                    "name": key,
                    "user_id": operator_id,
                    "record_count": 0,
                    "consume_count": 0,
                    "added_items": 0,
                    "used_count": 0,
                }
            if operator_id and not agg[key].get("user_id"):
                agg[key]["user_id"] = operator_id
            if record_type == 0:
                agg[key]["record_count"] += int(cnt)
                agg[key]["added_items"] += int(cnt)
            elif record_type == 1:
                agg[key]["consume_count"] += int(cnt)
                agg[key]["used_count"] += int(cnt)

        ranked = sorted(
            agg.values(),
            key=lambda x: x["record_count"] + x["consume_count"],
            reverse=True,
        )
        for i, entry in enumerate(ranked[:limit]):
            entry["rank"] = i + 1
            entry["total_actions"] = entry["record_count"] + entry["consume_count"]
        return ranked[:limit]
