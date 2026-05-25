"""
通知路由模块
定义通知相关接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.notification import NotificationListResponse, NotificationResponse, UnreadCountResponse
from app.schemas.common import ResponseSchema
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", summary="获取通知列表", response_model=ResponseSchema)
async def get_notifications(
    type: Optional[str] = Query(None, description="通知类型筛选"),
    is_read: Optional[bool] = Query(None, description="是否已读筛选"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的通知列表（分页）

    - **type**: 通知类型筛选，可选值：expiry, stock, purchase, warranty, system
    - **is_read**: 是否已读筛选
    - **page**: 页码，默认1
    - **page_size**: 每页数量，默认20，最大100
    """
    service = NotificationService(db)
    result = await service.get_notifications(
        family_id=current_family_id,
        user_id=current_user.id,
        notification_type=type,
        is_read=is_read,
        page=page,
        page_size=page_size
    )

    # 转换 items 为响应模型
    items = [NotificationResponse.model_validate(item) for item in result["items"]]

    return ResponseSchema(
        code=200,
        message="success",
        data={
            "items": [item.model_dump() for item in items],
            "total": result["total"],
            "page": result["page"],
            "page_size": result["page_size"],
            "pages": result["pages"]
        }
    )


@router.get("/unread-count", summary="获取未读通知数量", response_model=ResponseSchema)
async def get_unread_count(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的未读通知数量
    用于 Flutter 端角标显示
    """
    service = NotificationService(db)
    count = await service.get_unread_count(
        family_id=current_family_id,
        user_id=current_user.id
    )

    return ResponseSchema(
        code=200,
        message="success",
        data={"count": count}
    )


@router.put("/{notification_id}/read", summary="标记通知已读", response_model=ResponseSchema)
async def mark_notification_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    标记指定通知为已读
    """
    service = NotificationService(db)
    success = await service.mark_read(notification_id, current_family_id)

    if success:
        return ResponseSchema(
            code=200,
            message="标记成功",
            data=None
        )
    else:
        return ResponseSchema(
            code=404,
            message="通知不存在",
            data=None
        )


@router.put("/read-all", summary="标记所有通知已读", response_model=ResponseSchema)
async def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    标记当前用户所有通知为已读
    """
    service = NotificationService(db)
    count = await service.mark_all_read(
        family_id=current_family_id,
        user_id=current_user.id
    )

    return ResponseSchema(
        code=200,
        message=f"已标记{count}条通知为已读",
        data={"count": count}
    )


@router.delete("/{notification_id}", summary="删除通知", response_model=ResponseSchema)
async def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    删除指定通知
    """
    service = NotificationService(db)
    success = await service.delete_notification(notification_id, current_family_id)

    if success:
        return ResponseSchema(
            code=200,
            message="删除成功",
            data=None
        )
    else:
        return ResponseSchema(
            code=404,
            message="通知不存在",
            data=None
        )
