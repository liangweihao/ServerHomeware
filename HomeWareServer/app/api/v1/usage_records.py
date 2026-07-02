"""
使用记录路由模块
定义使用记录CRUD接口
"""
import logging
from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.usage_record import CreateUsageRecordRequest
from app.repositories.item_repo import ItemRepository
from app.repositories.usage_record_repo import UsageRecordRepository
from app.services.realtime_broadcast import broadcast_family_event

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/usage_records", tags=["usage_records"])


def _default_operator_name(user: User) -> str:
    """操作人昵称为空时回退手机号"""
    nickname = (user.nickname or "").strip()
    if nickname:
        return nickname
    return (user.phone or "").strip() or "未署名"


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
            "operator_id": r.operator_id,
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
    operator_name = (request.operator_name or "").strip() or _default_operator_name(
        current_user
    )
    record = await usage_record_repo.create({
        "item_id": request.item_id,
        "family_id": current_family_id,
        "type": request.type,
        "quantity": request.quantity,
        "remaining_quantity": request.remaining_quantity,
        "operator_id": current_user.id,
        "operator_name": operator_name,
        "notes": request.notes,
    })

    logger.info(
        "INFO: 创建使用记录 item_id=%s type=%s operator_id=%s operator_name=%s",
        request.item_id,
        request.type,
        current_user.id,
        operator_name,
    )

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

    broadcast_family_event(
        current_family_id,
        "usage_changed",
        {"item_id": request.item_id},
    )
    broadcast_family_event(
        current_family_id,
        "items_changed",
        {"action": "usage_record", "item_id": request.item_id},
    )
    broadcast_family_event(current_family_id, "alerts_changed", {})

    return ResponseSchema(
        code=200,
        message="使用记录创建成功",
        data={
            "id": record.id,
            "item_id": record.item_id,
            "type": record.type,
            "quantity": float(record.quantity),
            "remaining_quantity": float(record.remaining_quantity),
            "operator_id": record.operator_id,
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