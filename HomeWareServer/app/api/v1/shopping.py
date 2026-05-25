"""
购物清单路由模块
定义购物清单CRUD接口
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.shopping import (
    CreateShoppingItemRequest,
    PurchaseRequest,
    ShareTextResponse,
    ShoppingItemWithRelatedResponse,
    ShoppingRecommendationResponse,
    ShoppingListResponse,
    ToItemRequest,
    UpdateShoppingItemRequest
)
from app.services.shopping_service import ShoppingService

router = APIRouter(prefix="/shopping", tags=["shopping"])


@router.get("", summary="获取购物清单")
async def get_shopping_list(
    status: str = Query("all", description="pending/purchased/all"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取购物清单（分页）
    
    - **status**: 状态筛选: pending/purchased/all
    - **page**: 页码，默认1
    - **page_size**: 每页数量，默认20，最大100
    """
    service = ShoppingService(db)
    result = await service.get_shopping_list(
        family_id=current_family_id,
        status=status,
        page=page,
        page_size=page_size
    )

    items = [ShoppingItemWithRelatedResponse.model_validate(item) for item in result["items"]]

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


@router.post("", summary="添加购物项")
async def create_shopping_item(
    request: CreateShoppingItemRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    添加购物项
    
    - **name**: 物品名称
    - **quantity**: 数量，默认1
    - **unit**: 单位，默认"个"
    - **estimated_price**: 预估价格（可选）
    - **related_item_id**: 关联物品ID（可选）
    """
    service = ShoppingService(db)
    item = await service.create_shopping_item(
        family_id=current_family_id,
        user_id=current_user.id,
        name=request.name,
        quantity=request.quantity,
        unit=request.unit,
        estimated_price=request.estimated_price,
        related_item_id=request.related_item_id
    )

    return ResponseSchema(
        code=200,
        message="购物项添加成功",
        data=ShoppingItemWithRelatedResponse.model_validate(item).model_dump()
    )


@router.put("/{item_id}", summary="更新购物项")
async def update_shopping_item(
    item_id: int,
    request: UpdateShoppingItemRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    更新购物项
    
    - **name**: 物品名称（可选）
    - **quantity**: 数量（可选）
    - **unit**: 单位（可选）
    - **estimated_price**: 预估价格（可选）
    - **priority**: 优先级（可选）
    """
    service = ShoppingService(db)
    
    update_data = {}
    if request.name is not None:
        update_data["name"] = request.name
    if request.quantity is not None:
        update_data["quantity"] = request.quantity
    if request.unit is not None:
        update_data["unit"] = request.unit
    if request.estimated_price is not None:
        update_data["estimated_price"] = request.estimated_price
    if request.priority is not None:
        update_data["priority"] = request.priority
    if request.notes is not None:
        update_data["notes"] = request.notes
    
    if not update_data:
        return ResponseSchema(code=400, message="没有需要更新的字段", data=None)
    
    item = await service.repo.update(item_id, update_data)
    
    if not item:
        return ResponseSchema(code=404, message="购物项不存在", data=None)
    
    return ResponseSchema(
        code=200,
        message="购物项更新成功",
        data=ShoppingItemWithRelatedResponse.model_validate(item).model_dump()
    )


@router.put("/{item_id}/purchase", summary="标记已购买")
async def mark_as_purchased(
    item_id: int,
    request: Optional[PurchaseRequest] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    标记购物项为已购买
    
    - **actual_price**: 实际价格（可选）
    """
    service = ShoppingService(db)
    actual_price = request.actual_price if request else None
    result = await service.mark_as_purchased(item_id, current_user.id, actual_price)

    if not result["success"]:
        return ResponseSchema(code=404, message=result["message"], data=None)

    return ResponseSchema(
        code=200,
        message=result["message"],
        data={
            "need_inventory": result["need_inventory"],
            "related_item_id": result["related_item_id"]
        }
    )


@router.post("/{item_id}/to-item", summary="一键入库")
async def to_item(
    item_id: int,
    request: Optional[ToItemRequest] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    从已购物品一键创建入库
    
    - **location_id**: 位置ID（可选）
    - **expiry_date**: 过期日期（可选）
    """
    service = ShoppingService(db)
    location_id = request.location_id if request else None
    expiry_date = request.expiry_date if request else None
    
    item = await service.to_item(item_id, current_user.id, location_id, expiry_date)

    if not item:
        return ResponseSchema(code=400, message="无法创建入库物品", data=None)

    return ResponseSchema(
        code=200,
        message="入库成功",
        data={
            "item_id": item.id,
            "name": item.name,
            "quantity": float(item.current_quantity),
            "unit": item.unit
        }
    )


@router.put("/purchase-all", summary="全部标记已购买")
async def mark_all_purchased(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    批量标记所有未购买的购物项为已购买
    """
    service = ShoppingService(db)
    count = await service.mark_all_purchased(current_family_id, current_user.id)

    return ResponseSchema(
        code=200,
        message=f"已标记{count}个购物项为已购买",
        data={"count": count}
    )


@router.delete("/{item_id}", summary="删除购物项")
async def delete_shopping_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    删除购物项
    """
    service = ShoppingService(db)
    success = await service.repo.delete(item_id)
    
    if not success:
        return ResponseSchema(code=404, message="购物项不存在", data=None)
    
    return ResponseSchema(
        code=200,
        message="购物项删除成功",
        data=None
    )


@router.get("/share-text", summary="生成分享文本")
async def get_share_text(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    生成购物清单分享文本
    """
    service = ShoppingService(db)
    result = await service.generate_share_text(current_family_id)

    return ResponseSchema(
        code=200,
        message="success",
        data={
            "text": result["text"],
            "total_estimated": result["total_estimated"]
        }
    )


@router.get("/recommendations", summary="获取购物推荐")
async def get_recommendations(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取智能购物推荐
    
    根据库存状态和预计用完日期生成推荐列表
    """
    service = ShoppingService(db)
    recommendations = await service.get_recommendations(current_family_id)

    # 转换为响应模型
    response_items = [ShoppingRecommendationResponse.model_validate(r) for r in recommendations]

    return ResponseSchema(
        code=200,
        message="success",
        data={"recommendations": [r.model_dump() for r in response_items]}
    )
