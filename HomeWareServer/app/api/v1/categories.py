"""
分类路由模块
定义分类CRUD接口
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.category import CategoryResponse, CreateCategoryRequest, UpdateCategoryRequest
from app.schemas.common import ResponseSchema
from app.services.category_service import CategoryService

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("", summary="获取当前家庭分类列表（树形结构）")
async def get_categories(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = CategoryService(db)
    categories = await service.get_categories_tree(current_family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=categories
    )


@router.get("/{category_id}", summary="获取分类详情")
async def get_category(
    category_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = CategoryService(db)
    category = await service.get_category_by_id(category_id, current_family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=CategoryResponse.from_orm(category)
    )


@router.post("", summary="创建自定义分类")
async def create_category(
    request: CreateCategoryRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = CategoryService(db)
    category = await service.create_category(request.dict(), current_family_id)
    
    return ResponseSchema(
        code=200,
        message="分类创建成功",
        data=CategoryResponse.from_orm(category)
    )


@router.put("/{category_id}", summary="更新分类")
async def update_category(
    category_id: int,
    request: UpdateCategoryRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = CategoryService(db)
    category = await service.update_category(category_id, request.dict(), current_family_id)
    
    return ResponseSchema(
        code=200,
        message="分类更新成功",
        data=CategoryResponse.from_orm(category)
    )


@router.delete("/{category_id}", summary="删除分类")
async def delete_category(
    category_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    service = CategoryService(db)
    await service.delete_category(category_id, current_family_id)
    
    return ResponseSchema(
        code=200,
        message="分类删除成功",
        data=None
    )