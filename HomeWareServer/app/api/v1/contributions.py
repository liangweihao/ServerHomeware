"""
贡献度路由模块 — 用户贡献与家庭排行
"""
import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_family, get_current_user
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.services.contribution_service import ContributionService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/contributions", tags=["contributions"])


@router.get("/user/{user_id}", summary="获取用户贡献度")
async def get_user_contribution(
    user_id: int,
    current_user: User = Depends(get_current_user),
    family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """获取指定用户本月贡献 — 字段含 record_count/consume_count 与 added_items/used_count"""
    if current_user.id != user_id:
        logger.warning(
            "贡献度查询 user_id=%s 与当前用户 %s 不一致，仍返回目标用户统计",
            user_id,
            current_user.id,
        )

    service = ContributionService(db)
    data = await service.get_user_contribution(
        family_id=family_id,
        user_id=user_id,
        nickname=current_user.nickname if user_id == current_user.id else None,
    )
    logger.info(
        "INFO: 用户贡献 user_id=%s record=%s consume=%s",
        user_id,
        data["record_count"],
        data["consume_count"],
    )
    return ResponseSchema(code=200, message="success", data=data)


@router.get("/family/leaderboard", summary="家庭贡献排行")
async def get_family_leaderboard(
    current_user: User = Depends(get_current_user),
    family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """当前家庭本月贡献排行（按操作人聚合）"""
    service = ContributionService(db)
    leaderboard = await service.get_family_leaderboard(family_id)
    logger.info(
        "INFO: 家庭排行 family_id=%s members=%s",
        family_id,
        len(leaderboard),
    )
    return ResponseSchema(
        code=200,
        message="success",
        data={"members": leaderboard},
    )


@router.get("/user/{user_id}/history", summary="获取用户贡献度历史")
async def get_user_contribution_history(
    user_id: int,
    current_user: User = Depends(get_current_user),
    family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """近 7 日入库/消耗趋势（added_items / used_count）"""
    from datetime import datetime, timedelta

    from sqlalchemy import func, select

    from app.models.usage_record import UsageRecord

    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="无权查看其他用户历史")

    service = ContributionService(db)
    nickname = current_user.nickname
    result = []

    for i in range(7):
        day = (datetime.now() - timedelta(days=6 - i)).date()
        day_start = datetime.combine(day, datetime.min.time())
        day_end = datetime.combine(day, datetime.max.time())

        added = await db.scalar(
            select(func.count())
            .select_from(UsageRecord)
            .where(
                UsageRecord.family_id == family_id,
                UsageRecord.type == 0,
                UsageRecord.created_at >= day_start,
                UsageRecord.created_at <= day_end,
                service._operator_filter(user_id, nickname),
            )
        )
        used = await db.scalar(
            select(func.count())
            .select_from(UsageRecord)
            .where(
                UsageRecord.family_id == family_id,
                UsageRecord.type == 1,
                UsageRecord.created_at >= day_start,
                UsageRecord.created_at <= day_end,
                service._operator_filter(user_id, nickname),
            )
        )
        result.append(
            {
                "date": str(day),
                "record_count": int(added or 0),
                "consume_count": int(used or 0),
                "added_items": int(added or 0),
                "used_count": int(used or 0),
            }
        )

    return ResponseSchema(code=200, message="success", data=result)
