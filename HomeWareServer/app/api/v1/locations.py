"""
位置路由模块
定义位置CRUD接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.location import CreateLocationRequest, LocationResponse, UpdateLocationRequest
from app.services.location_service import LocationService

router = APIRouter(prefix="/locations", tags=["locations"])


@router.get("", summary="获取当前家庭位置列表（树形结构）")
async def get_locations(
    parent_id: Optional[int] = Query(None, description="父位置ID"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = LocationService(db)
    locations = await service.get_locations_tree(current_family_id, parent_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=locations
    )


@router.get("/{location_id}", summary="获取位置详情")
async def get_location(
    location_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = LocationService(db)
    location = await service.get_location_detail(location_id, current_family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=location
    )


@router.post("", summary="创建位置")
async def create_location(
    request: CreateLocationRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = LocationService(db)
    location = await service.create_location(request.dict(), current_family_id)
    
    return ResponseSchema(
        code=200,
        message="位置创建成功",
        data=LocationResponse.from_orm(location)
    )


@router.put("/{location_id}", summary="更新位置")
async def update_location(
    location_id: int,
    request: UpdateLocationRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = LocationService(db)
    location = await service.update_location(location_id, request.dict(), current_family_id)
    
    return ResponseSchema(
        code=200,
        message="位置更新成功",
        data=LocationResponse.from_orm(location)
    )


@router.delete("/{location_id}", summary="删除位置")
async def delete_location(
    location_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = LocationService(db)
    await service.delete_location(location_id, current_family_id)
    
    return ResponseSchema(
        code=200,
        message="位置删除成功",
        data=None
    )