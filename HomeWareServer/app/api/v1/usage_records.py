"""
使用记录路由模块
定义使用记录CRUD接口
"""
from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.usage_record import CreateUsageRecordRequest, UsageRecordResponse
from app.repositories.item_repo import ItemRepository
from app.repositories.usage_record_repo import UsageRecordRepository

router = APIRouter(prefix="/usage_records", tags=["usage_records"])


@router.get("", summary="获取使用记录（按物品 or 全家庭）")
async def get_usage_records(
    item_id: Optional[int] = Query(None, description="物品ID（不传则返回全家庭记录）"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页大小"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    usage_record_repo = UsageRecordRepository(db)
    item_repo = ItemRepository(db)

    if item_id:
        # 单物品使用记录
        records = await usage_record_repo.get_by_item_id(item_id)
        total = len(records)
    else:
        # 全家庭使用记录，分页
        records = await usage_record_repo.get_recent_by_family(
            current_family_id,
            page=page,
            page_size=page_size
        )
        total = await usage_record_repo.count_by_family(current_family_id)

    # 统一组装返回（含物品名称）
    items_data = []
    for r in records:
        item = await item_repo.get_by_id(r.item_id)
        items_data.append({
            "id": r.id,
            "item_id": r.item_id,
            "item_name": item.name if item else None,
            "type": r.type,
            "quantity": float(r.quantity),
            "remaining_quantity": float(r.remaining_quantity),
            "operator_name": r.operator_name,
            "notes": r.notes,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        })

    return ResponseSchema(
        code=200,
        message="success",
        data={
            "items": items_data,
            "total": total,
            "page": page,
            "page_size": page_size,
        }
    )


@router.post("", summary="创建使用记录")
async def create_usage_record(
    request: CreateUsageRecordRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    usage_record_repo = UsageRecordRepository(db)
    record = await usage_record_repo.create({
        "item_id": request.item_id,
        "family_id": current_family_id,
        "type": request.type,
        "quantity": request.quantity,
        "remaining_quantity": request.remaining_quantity,
        "operator_id": current_user.id,
        "operator_name": request.operator_name,
        "notes": request.notes,
    })

    # 同步更新物品的 current_quantity 和 status
    from app.repositories.item_repo import ItemRepository
    item_repo = ItemRepository(db)
    item = await item_repo.get_by_id(request.item_id)
    if item and request.remaining_quantity is not None:
        new_status = item.status
        if request.remaining_quantity <= 0:
            new_status = 1  # 已用完
        await item_repo.update(item.id, {
            "current_quantity": request.remaining_quantity,
            "status": new_status,
        })

    return ResponseSchema(
        code=200,
        message="使用记录创建成功",
        data={
            "id": record.id,
            "item_id": record.item_id,
            "type": record.type,
            "quantity": float(record.quantity),
            "remaining_quantity": float(record.remaining_quantity),
            "operator_name": record.operator_name,
            "created_at": record.created_at.isoformat() if record.created_at else None,
        }
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