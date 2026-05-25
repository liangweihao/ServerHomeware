"""
物品路由模块
定义物品CRUD接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.item import CreateItemRequest, ItemResponse, MoveItemRequest, UpdateItemRequest, UseItemRequest
from app.services.item_service import ItemService
from app.services.prediction_service import PredictionService

router = APIRouter(prefix="/items", tags=["items"])


@router.get("", summary="获取当前家庭物品列表（分页 + 筛选 + 排序）")
async def get_items(
    page: int = Query(1, description="页码"),
    page_size: int = Query(20, description="每页大小"),
    status: Optional[int] = Query(None, description="状态筛选(0使用中/1用完/2过期/3丢弃)"),
    category_id: Optional[int] = Query(None, description="分类筛选"),
    location_id: Optional[int] = Query(None, description="位置筛选"),
    keyword: Optional[str] = Query(None, description="搜索名称/品牌"),
    sort_by: str = Query("created_at", description="排序字段(expiry_date/created_at/current_quantity/purchase_price)"),
    sort_order: str = Query("desc", description="排序方向(asc/desc)"),
    expiring_within_days: Optional[int] = Query(None, description="即将过期筛选(N天内)"),
    low_stock: Optional[bool] = Query(None, description="库存低于安全库存"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    
    params = {
        "page": page,
        "page_size": page_size,
        "status": status,
        "category_id": category_id,
        "location_id": location_id,
        "keyword": keyword,
        "sort_by": sort_by,
        "sort_order": sort_order,
        "expiring_within_days": expiring_within_days,
        "low_stock": low_stock
    }
    
    result = await item_service.get_items(current_user.id, current_family_id, params)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )


@router.get("/{item_id}", summary="获取物品详情")
async def get_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.get_item(current_user.id, item_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=item
    )


@router.post("", summary="创建物品")
async def create_item(
    request: CreateItemRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.create_item(
        user_id=current_user.id,
        family_id=current_family_id,
        data=request.dict()
    )
    
    # 获取物品详情（包含图片和使用记录）
    item_detail = await item_service.get_item(current_user.id, item.id)
    
    return ResponseSchema(
        code=200,
        message="物品创建成功",
        data=item_detail
    )


@router.put("/{item_id}", summary="更新物品")
async def update_item(
    item_id: int,
    request: UpdateItemRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.update_item(
        user_id=current_user.id,
        item_id=item_id,
        data=request.dict(exclude_unset=True)
    )
    
    return ResponseSchema(
        code=200,
        message="物品更新成功",
        data=ItemResponse.from_orm(item)
    )


@router.delete("/{item_id}", summary="删除物品")
async def delete_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    await item_service.delete_item(current_user.id, item_id)
    
    return ResponseSchema(
        code=200,
        message="物品删除成功",
        data=None
    )


@router.post("/{item_id}/use", summary="记录物品使用")
async def use_item(
    item_id: int,
    request: UseItemRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.use_item(
        user_id=current_user.id,
        item_id=item_id,
        quantity=request.quantity,
        operator_name=request.operator_name
    )
    
    return ResponseSchema(
        code=200,
        message="使用记录成功",
        data=item
    )


@router.post("/{item_id}/finish", summary="标记物品用完")
async def finish_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.finish_item(current_user.id, item_id)
    
    return ResponseSchema(
        code=200,
        message="已标记为用完",
        data=item
    )


@router.post("/{item_id}/discard", summary="标记物品丢弃")
async def discard_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.discard_item(current_user.id, item_id)
    
    return ResponseSchema(
        code=200,
        message="已标记为丢弃",
        data=item
    )


@router.post("/{item_id}/move", summary="移动物品位置")
async def move_item(
    item_id: int,
    request: MoveItemRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.move_item(current_user.id, item_id, request.to_location_id)
    
    return ResponseSchema(
        code=200,
        message="位置移动成功",
        data=item
    )


@router.get("/barcode/{barcode}", summary="根据条码查询物品")
async def get_item_by_barcode(
    barcode: str,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    item_service = ItemService(db)
    item = await item_service.get_item_by_barcode(current_user.id, current_family_id, barcode)
    
    if item:
        return ResponseSchema(
            code=200,
            message="success",
            data=item
        )
    else:
        return ResponseSchema(
            code=404,
            message="未找到该条码对应的物品",
            data=None
        )


@router.get("/{item_id}/prediction", summary="获取物品消耗预测")
async def get_item_prediction(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    获取物品消耗预测信息
    
    返回日均消耗量、预计用完日期、置信度等信息
    """
    service = PredictionService(db)
    result = await service.get_prediction(item_id)

    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )