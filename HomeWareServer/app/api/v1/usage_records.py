"""
使用记录路由模块
定义使用记录CRUD接口
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.usage_record import CreateUsageRecordRequest, UsageRecordResponse
from app.repositories.usage_record_repo import UsageRecordRepository

router = APIRouter(prefix="/usage_records", tags=["usage_records"])


@router.get("", summary="获取物品使用记录")
async def get_usage_records(
    item_id: int = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    usage_record_repo = UsageRecordRepository(db)
    
    if item_id:
        records = await usage_record_repo.get_by_item_id(item_id)
    else:
        records = await usage_record_repo.get_by_user_id(current_user.id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=[UsageRecordResponse.from_orm(r) for r in records]
    )


@router.post("", summary="创建使用记录")
async def create_usage_record(
    request: CreateUsageRecordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    usage_record_repo = UsageRecordRepository(db)
    record = await usage_record_repo.create({
        "item_id": request.item_id,
        "used_quantity": request.used_quantity,
        "used_by": current_user.id,
        "notes": request.notes,
    })
    
    return ResponseSchema(
        code=200,
        message="使用记录创建成功",
        data=UsageRecordResponse.from_orm(record)
    )


@router.delete("/{record_id}", summary="删除使用记录")
async def delete_usage_record(
    record_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    usage_record_repo = UsageRecordRepository(db)
    success = await usage_record_repo.delete(record_id)
    
    if not success:
        return ResponseSchema(code=404, message="使用记录不存在", data=None)
    
    return ResponseSchema(
        code=200,
        message="使用记录删除成功",
        data=None
    )