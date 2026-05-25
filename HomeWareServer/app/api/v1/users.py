"""
用户路由模块
定义用户信息获取、更新等接口
"""
from fastapi import APIRouter, Body, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.notification_preference import NotificationPreference
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.schemas.notification_preference import NotificationPreferenceResponse, UpdateNotificationPreferenceRequest
from app.schemas.user import ChangePasswordRequest, UpdateUserRequest, UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", summary="获取当前用户信息")
async def get_current_user_info(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户完整信息
    """
    return ResponseSchema(
        code=200,
        message="success",
        data=UserResponse.from_orm(current_user)
    )


@router.get("/{user_id}", summary="获取用户信息")
async def get_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_service = UserService(db)
    user = await user_service.get_user(user_id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=UserResponse.from_orm(user)
    )


@router.put("/me", summary="更新当前用户信息")
async def update_current_user(
    request: UpdateUserRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_service = UserService(db)
    user = await user_service.update_user(current_user.id, request.dict())
    
    return ResponseSchema(
        code=200,
        message="更新成功",
        data=UserResponse.from_orm(user)
    )


@router.put("/me/password", summary="修改密码")
async def change_password(
    request: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_service = UserService(db)
    user = await user_service.change_password(
        current_user.id,
        request.old_password,
        request.new_password
    )
    
    return ResponseSchema(
        code=200,
        message="密码修改成功",
        data=UserResponse.from_orm(user)
    )


@router.delete("/me", summary="注销账户")
async def delete_account(
    password: str = Body(..., embed=True, description="用户密码"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    注销账户（软删除）
    
    - 需要验证用户密码
    - 标记用户状态为已删除
    - 保留数据用于审计和恢复
    """
    user_service = UserService(db)
    
    try:
        await user_service.delete_user(current_user.id, password)
        
        return ResponseSchema(
            code=200,
            message="账户注销成功",
            data=None
        )
    except ValueError as e:
        return ResponseSchema(
            code=400,
            message=str(e),
            data=None
        )


@router.get("/me/notification-preferences", summary="获取通知偏好", response_model=ResponseSchema)
async def get_notification_preferences(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的通知偏好设置
    """
    preference = await db.get(NotificationPreference, current_user.id)

    if not preference:
        # 如果没有偏好设置，返回默认值
        preference = NotificationPreference(
            user_id=current_user.id,
            push_enabled=True,
            expiry_alert=True,
            stock_alert=True,
            purchase_alert=True,
            warranty_alert=True
        )

    return ResponseSchema(
        code=200,
        message="success",
        data=NotificationPreferenceResponse.model_validate(preference).model_dump()
    )


@router.put("/me/notification-preferences", summary="更新通知偏好", response_model=ResponseSchema)
async def update_notification_preferences(
    request: UpdateNotificationPreferenceRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    更新当前用户的通知偏好设置
    """
    preference = await db.get(NotificationPreference, current_user.id)

    if not preference:
        # 创建新偏好设置
        preference = NotificationPreference(user_id=current_user.id)
        db.add(preference)

    # 更新非空字段
    update_data = request.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(preference, key, value)

    await db.commit()
    await db.refresh(preference)

    return ResponseSchema(
        code=200,
        message="更新成功",
        data=NotificationPreferenceResponse.model_validate(preference).model_dump()
    )