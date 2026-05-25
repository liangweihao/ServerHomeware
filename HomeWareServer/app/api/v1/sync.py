"""
数据同步路由模块
定义增量同步和批量推送接口
"""
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.category import Category
from app.models.item import Item
from app.models.location import Location
from app.models.shopping import ShoppingItem
from app.models.user import User
from app.schemas.common import ResponseSchema

router = APIRouter(prefix="/sync", tags=["sync"])


@router.get("/changes", summary="获取增量变更")
async def get_changes(
    since: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取自指定时间以来的所有数据变更（增量同步）
    
    - **since**: ISO时间戳，上次同步时间（可选，不传则返回所有数据）
    """
    # 解析时间戳
    since_datetime = None
    if since:
        try:
            since_datetime = datetime.fromisoformat(since.replace("Z", "+00:00"))
        except ValueError:
            pass
    
    server_time = datetime.utcnow().isoformat() + "Z"
    
    changes = {
        "items": {"created": [], "updated": [], "deleted": []},
        "categories": {"created": [], "updated": [], "deleted": []},
        "locations": {"created": [], "updated": [], "deleted": []},
        "shopping_list": {"created": [], "updated": [], "deleted": []}
    }
    
    # 查询物品变更
    items_query = select(Item).filter(Item.family_id == current_family_id)
    if since_datetime:
        # 查询更新或删除的记录
        updated_items_query = items_query.filter(Item.updated_at > since_datetime)
        deleted_items_query = items_query.filter(Item.deleted_at != None)
    else:
        updated_items_query = items_query
        deleted_items_query = items_query.filter(Item.deleted_at != None)
    
    items_result = await db.execute(updated_items_query)
    items = items_result.scalars().all()
    
    for item in items:
        item_dict = {
            "id": item.id,
            "name": item.name,
            "category_id": item.category_id,
            "location_id": item.location_id,
            "status": item.status,
            "current_quantity": float(item.current_quantity) if item.current_quantity else 0,
            "updated_at": item.updated_at.isoformat() if item.updated_at else None,
            "deleted_at": item.deleted_at.isoformat() if item.deleted_at else None
        }
        
        if item.deleted_at:
            changes["items"]["deleted"].append(item.id)
        elif since_datetime and item.created_at > since_datetime:
            changes["items"]["created"].append(item_dict)
        else:
            changes["items"]["updated"].append(item_dict)
    
    # 查询分类变更
    categories_query = select(Category).filter(
        (Category.family_id == current_family_id) | (Category.family_id == None)
    )
    if since_datetime:
        categories_query = categories_query.filter(Category.updated_at > since_datetime)
    
    categories_result = await db.execute(categories_query)
    categories = categories_result.scalars().all()
    
    for cat in categories:
        cat_dict = {
            "id": cat.id,
            "name": cat.name,
            "parent_id": cat.parent_id,
            "is_system": cat.is_system,
            "is_active": cat.is_active,
            "updated_at": cat.updated_at.isoformat() if cat.updated_at else None
        }
        
        if since_datetime and cat.created_at > since_datetime:
            changes["categories"]["created"].append(cat_dict)
        else:
            changes["categories"]["updated"].append(cat_dict)
    
    # 查询位置变更
    locations_query = select(Location).filter(Location.family_id == current_family_id)
    if since_datetime:
        locations_query = locations_query.filter(Location.updated_at > since_datetime)
    
    locations_result = await db.execute(locations_query)
    locations = locations_result.scalars().all()
    
    for loc in locations:
        loc_dict = {
            "id": loc.id,
            "name": loc.name,
            "parent_id": loc.parent_id,
            "level": loc.level,
            "full_path": loc.full_path,
            "is_active": loc.is_active,
            "updated_at": loc.updated_at.isoformat() if loc.updated_at else None
        }
        
        if since_datetime and loc.created_at > since_datetime:
            changes["locations"]["created"].append(loc_dict)
        else:
            changes["locations"]["updated"].append(loc_dict)
    
    # 查询购物清单变更
    shopping_query = select(ShoppingItem).filter(ShoppingItem.family_id == current_family_id)
    if since_datetime:
        shopping_query = shopping_query.filter(ShoppingItem.updated_at > since_datetime)
    
    shopping_result = await db.execute(shopping_query)
    shopping_items = shopping_result.scalars().all()
    
    for item in shopping_items:
        item_dict = {
            "id": item.id,
            "name": item.name,
            "related_item_id": item.related_item_id,
            "quantity": float(item.quantity) if item.quantity else 0,
            "is_purchased": item.is_purchased,
            "is_auto_generated": item.is_auto_generated,
            "updated_at": item.updated_at.isoformat() if item.updated_at else None
        }
        
        if since_datetime and item.created_at > since_datetime:
            changes["shopping_list"]["created"].append(item_dict)
        else:
            changes["shopping_list"]["updated"].append(item_dict)
    
    return ResponseSchema(
        code=200,
        message="success",
        data={
            "server_time": server_time,
            "changes": changes
        }
    )


@router.post("/push", summary="批量推送变更")
async def push_changes(
    data: dict,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    批量推送客户端离线操作（离线后同步）
    
    请求体格式：
    {
        "items": [
            {"action": "create", "data": {...}, "client_id": "temp_123"},
            {"action": "update", "data": {...}, "id": 45},
            {"action": "delete", "id": 46}
        ],
        "usage_records": [...]
    }
    """
    results = []
    conflicts = []
    
    # 处理物品变更
    items = data.get("items", [])
    for item_op in items:
        action = item_op.get("action")
        client_id = item_op.get("client_id")
        item_data = item_op.get("data", {})
        
        try:
            if action == "create":
                # 创建物品
                new_item = Item(
                    **item_data,
                    family_id=current_family_id,
                    created_by=current_user.id
                )
                db.add(new_item)
                await db.flush()
                results.append({
                    "client_id": client_id,
                    "server_id": new_item.id,
                    "status": "ok"
                })
            
            elif action == "update":
                # 更新物品
                item_id = item_op.get("id")
                if item_id:
                    result = await db.execute(
                        select(Item).filter(Item.id == item_id, Item.family_id == current_family_id)
                    )
                    item = result.scalar_one_or_none()
                    
                    if item:
                        # 检查冲突
                        server_updated_at = item.updated_at
                        client_updated_at = item_data.get("updated_at")
                        
                        if client_updated_at and server_updated_at:
                            client_dt = datetime.fromisoformat(client_updated_at.replace("Z", "+00:00"))
                            if server_updated_at > client_dt:
                                conflicts.append({
                                    "id": item_id,
                                    "type": "item",
                                    "reason": "conflict",
                                    "server_data": {"updated_at": server_updated_at.isoformat()}
                                })
                                continue
                        
                        # 更新字段
                        for key, value in item_data.items():
                            if hasattr(item, key) and key != "id":
                                setattr(item, key, value)
                        
                        results.append({
                            "client_id": client_id,
                            "server_id": item_id,
                            "status": "ok"
                        })
            
            elif action == "delete":
                # 删除物品（软删除）
                item_id = item_op.get("id")
                if item_id:
                    result = await db.execute(
                        select(Item).filter(Item.id == item_id, Item.family_id == current_family_id)
                    )
                    item = result.scalar_one_or_none()
                    
                    if item:
                        item.deleted_at = datetime.utcnow()
                        results.append({
                            "client_id": client_id,
                            "server_id": item_id,
                            "status": "ok"
                        })
        
        except Exception as e:
            results.append({
                "client_id": client_id,
                "status": "error",
                "message": str(e)
            })
    
    await db.commit()
    
    return ResponseSchema(
        code=200,
        message="success",
        data={
            "results": results,
            "conflicts": conflicts
        }
    )
