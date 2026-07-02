"""
提醒路由模块
定义提醒相关接口
"""
from datetime import date
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Literal, Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.alert import AlertResponse, AlertSummaryResponse, ExpiringItemResponse, LowStockItemResponse
from app.schemas.common import ResponseSchema
from app.services.alert_service import AlertService

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.get("", summary="获取提醒列表", response_model=ResponseSchema)
async def get_alerts(
    type: Literal["all", "expiry", "stock", "replenish", "warranty"] = Query("all", description="提醒类型"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前家庭的提醒列表
    
    - **type**: 提醒类型过滤，可选值：all(全部), expiry(过期), stock(库存), replenish(补购), warranty(保修)
    """
    service = AlertService(db)
    alerts = await service.get_alerts(current_family_id, type)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=alerts
    )


@router.get("/summary", summary="获取提醒统计摘要", response_model=ResponseSchema)
async def get_alert_summary(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前家庭各类提醒的数量统计，用于 Tab Badge 角标显示
    
    返回数据：
    - expiry: 过期提醒数量
    - stock: 库存提醒数量
    - replenish: 补购提醒数量
    - warranty: 保修提醒数量
    - total: 总提醒数量
    """
    service = AlertService(db)
    summary = await service.get_alert_summary(current_family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=summary
    )


@router.post("/{alert_id}/read", summary="标记提醒为已读")
async def mark_alert_read(
    alert_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    标记提醒为已读（前端本地处理，此处预留接口）
    """
    return ResponseSchema(
        code=200,
        message="标记成功",
        data=None
    )


@router.get("/expiring", summary="获取即将过期物品列表", response_model=ResponseSchema)
async def get_expiring_items(
    days: int = Query(7, ge=1, le=30, description="几天内过期"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取即将过期物品列表
    :param days: 几天内过期，默认7天
    """
    service = AlertService(db)
    items = await service.get_expiring_items(current_family_id, days)

    return ResponseSchema(
        code=200,
        message="success",
        data=items
    )


@router.get("/low-stock", summary="获取库存不足物品列表", response_model=ResponseSchema)
async def get_low_stock_items(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取库存不足物品列表
    """
    service = AlertService(db)
    items = await service.get_low_stock_items_list(current_family_id)

    return ResponseSchema(
        code=200,
        message="success",
        data=items
    )


@router.get("/expired", summary="获取已过期物品列表", response_model=ResponseSchema)
async def get_expired_items(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取已过期物品列表（使用中且 expiry_date 早于今日）
    """
    service = AlertService(db)
    items = await service.get_expired_items_list(current_family_id)

    return ResponseSchema(
        code=200,
        message="success",
        data=items
    )
