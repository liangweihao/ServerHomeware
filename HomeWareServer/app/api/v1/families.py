"""
家庭路由模块
定义家庭创建、加入、切换、成员管理等接口
"""
from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_family, get_current_user, require_owner
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.family import (
    CreateFamilyRequest,
    FamilyMemberResponse,
    FamilyResponse,
    JoinFamilyRequest,
    UpdateFamilyMemberRequest,
)
from app.services.family_service import FamilyService

router = APIRouter(prefix="/families", tags=["families"])


@router.get("", summary="获取用户的所有家庭")
async def get_user_families(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    families = await family_service.get_user_families(current_user.id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=[FamilyResponse.from_orm(f) for f in families]
    )


@router.post("", summary="创建新家庭")
async def create_family(
    request: CreateFamilyRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    family = await family_service.create_family(
        name=request.name,
        owner_id=current_user.id
    )
    
    return ResponseSchema(
        code=200,
        message="家庭创建成功",
        data=FamilyResponse.from_orm(family)
    )


@router.post("/join", summary="加入家庭")
async def join_family(
    request: JoinFamilyRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    family = await family_service.join_family(
        user_id=current_user.id,
        invite_code=request.invite_code
    )
    
    return ResponseSchema(
        code=200,
        message="加入家庭成功",
        data=FamilyResponse.from_orm(family)
    )


@router.post("/{family_id}/switch", summary="切换当前家庭")
async def switch_family(
    family_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    family = await family_service.switch_family(
        user_id=current_user.id,
        family_id=family_id
    )
    
    return ResponseSchema(
        code=200,
        message="切换家庭成功",
        data=FamilyResponse.from_orm(family)
    )


@router.post("/{family_id}/leave", summary="离开家庭")
async def leave_family(
    family_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    await family_service.leave_family(
        user_id=current_user.id,
        family_id=family_id
    )
    
    return ResponseSchema(
        code=200,
        message="离开家庭成功",
        data=None
    )


@router.get("/{family_id}/members", summary="获取家庭成员列表")
async def get_family_members(
    family_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    members = await family_service.get_family_members(family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=[FamilyMemberResponse.from_orm(m) for m in members]
    )


@router.put("/{family_id}/members/{user_id}", summary="更新家庭成员角色")
async def update_member_role(
    family_id: int,
    user_id: int,
    request: UpdateFamilyMemberRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    await family_service.update_member_role(
        family_id=family_id,
        user_id=user_id,
        role=request.role
    )
    
    return ResponseSchema(
        code=200,
        message="更新成功",
        data=None
    )


@router.get("/current", summary="获取当前家庭详情")
async def get_current_family_detail(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前家庭信息，包含成员列表、邀请码和统计数据
    """
    family_service = FamilyService(db)
    
    # 获取家庭信息
    family = await family_service.get_family_by_id(current_family_id)
    if not family:
        return ResponseSchema(
            code=404,
            message="家庭不存在",
            data=None
        )
    
    # 获取成员列表
    members = await family_service.get_family_members(current_family_id)
    
    # 获取物品统计
    item_count = await family_service.get_family_item_count(current_family_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data={
            "id": family.id,
            "name": family.name,
            "invite_code": family.invite_code,
            "owner_id": family.owner_id,
            "member_count": len(members),
            "item_count": item_count,
            "members": [FamilyMemberResponse.from_orm(m) for m in members],
            "created_at": family.created_at.isoformat() if family.created_at else None
        }
    )


@router.post("/current/refresh-invite-code", summary="刷新邀请码")
async def refresh_invite_code(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    _: str = Depends(require_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    刷新家庭邀请码（仅 owner 可操作）
    """
    family_service = FamilyService(db)
    new_code = await family_service.refresh_invite_code(current_family_id)
    
    return ResponseSchema(
        code=200,
        message="邀请码刷新成功",
        data={
            "invite_code": new_code
        }
    )