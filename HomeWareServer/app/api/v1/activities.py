"""
活动路由模块
定义家庭动态流接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.services.activity_service import ActivityService

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", summary="获取家庭动态流")
async def get_family_activities(
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页大小"),
    user_id: int = Query(None, description="筛选特定用户的操作"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前家庭的动态流（活动日志）
    
    - **page**: 页码，默认1
    - **page_size**: 每页大小，默认20，最大100
    - **user_id**: 可选，筛选特定用户的操作记录
    """
    service = ActivityService(db)
    
    if user_id:
        result = await service.get_user_activities(user_id, current_family_id, page, page_size)
    else:
        result = await service.get_family_activities(current_family_id, page, page_size)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )


@router.get("/recent", summary="获取最近动态")
async def get_recent_activities(
    limit: int = Query(5, ge=1, le=20, description="返回数量"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取最近的活动记录（用于首页动态流）
    
    - **limit**: 返回数量，默认5，最大20
    """
    service = ActivityService(db)
    activities = await service.get_recent_activities(current_family_id, limit)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=activities
    )
