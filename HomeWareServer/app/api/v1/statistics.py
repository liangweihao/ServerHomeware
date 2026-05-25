"""
统计路由模块
定义统计相关接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.services.statistics_service import StatisticsService

router = APIRouter(prefix="/statistics", tags=["statistics"])


@router.get("/overview", summary="获取统计概览")
async def get_overview(
    period: str = Query("month", description="统计周期: week/month/year"),
    date: Optional[str] = Query(None, description="目标日期（可选）"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取统计概览
    
    - **period**: 统计周期: week/month/year，默认month
    - **date**: 目标日期（可选），格式: YYYY-MM-DD
    """
    service = StatisticsService(db)
    result = await service.get_overview(current_family_id, period, date)

    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )


@router.get("/expense-trend", summary="获取消费趋势")
async def get_expense_trend(
    months: int = Query(6, ge=1, le=24, description="近几个月"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取消费趋势（用于折线图）
    
    - **months**: 近几个月，默认6，范围1-24
    """
    service = StatisticsService(db)
    result = await service.get_expense_trend(current_family_id, months)

    return ResponseSchema(
        code=200,
        message="success",
        data={"data": result}
    )


@router.get("/category-breakdown", summary="获取分类占比")
async def get_category_breakdown(
    period: str = Query("month", description="统计周期: week/month/year"),
    date: Optional[str] = Query(None, description="目标日期（可选）"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取分类消费占比（用于饼图）
    
    - **period**: 统计周期: week/month/year，默认month
    - **date**: 目标日期（可选），格式: YYYY-MM-DD
    """
    service = StatisticsService(db)
    result = await service.get_category_breakdown(current_family_id, period, date)

    return ResponseSchema(
        code=200,
        message="success",
        data={"data": result}
    )


@router.get("/waste", summary="获取浪费统计")
async def get_waste_statistics(
    period: str = Query("month", description="统计周期: week/month/year"),
    date: Optional[str] = Query(None, description="目标日期（可选）"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取浪费统计
    
    - **period**: 统计周期: week/month/year，默认month
    - **date**: 目标日期（可选），格式: YYYY-MM-DD
    """
    service = StatisticsService(db)
    result = await service.get_waste_statistics(current_family_id, period, date)

    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )


@router.get("/consumption-ranking", summary="获取消耗排行")
async def get_consumption_ranking(
    period: str = Query("month", description="统计周期: week/month/year"),
    limit: int = Query(10, ge=1, le=50, description="返回数量限制"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取消耗排行
    
    - **period**: 统计周期: week/month/year，默认month
    - **limit**: 返回数量限制，默认10，范围1-50
    """
    service = StatisticsService(db)
    result = await service.get_consumption_ranking(current_family_id, period, limit)

    return ResponseSchema(
        code=200,
        message="success",
        data={"data": result}
    )
