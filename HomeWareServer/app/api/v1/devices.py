"""
设备管理路由模块
定义用户设备注册、注销等接口
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.repositories.user_device_repo import UserDeviceRepository
from app.schemas.common import ResponseSchema

router = APIRouter(prefix="/devices", tags=["devices"])


@router.post("/register", summary="注册设备")
async def register_device(
    device_token: str,
    device_type: str,
    device_name: str = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    注册或更新用户设备（用于推送通知）
    
    - **device_token**: FCM推送token
    - **device_type**: 设备类型（ios/android）
    - **device_name**: 设备名称（可选）
    """
    repo = UserDeviceRepository(db)
    device = await repo.upsert(
        user_id=current_user.id,
        device_token=device_token,
        device_type=device_type,
        device_name=device_name
    )
    
    return ResponseSchema(
        code=200,
        message="设备注册成功",
        data={
            "id": device.id,
            "device_token": device.device_token,
            "device_type": device.device_type,
            "device_name": device.device_name
        }
    )


@router.delete("/{device_id}", summary="注销设备")
async def unregister_device(
    device_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    注销用户设备（退出登录时调用）
    
    - **device_id**: 设备ID
    """
    repo = UserDeviceRepository(db)
    device = await repo.get_by_id(device_id)
    
    if not device:
        return ResponseSchema(
            code=404,
            message="设备不存在",
            data=None
        )
    
    # 检查设备是否属于当前用户
    if device.user_id != current_user.id:
        return ResponseSchema(
            code=403,
            message="无权操作此设备",
            data=None
        )
    
    await repo.delete(device_id)
    
    return ResponseSchema(
        code=200,
        message="设备注销成功",
        data=None
    )


@router.get("", summary="获取用户设备列表")
async def get_user_devices(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的所有设备
    """
    repo = UserDeviceRepository(db)
    devices = await repo.get_by_user(current_user.id)
    
    return ResponseSchema(
        code=200,
        message="success",
        data=[{
            "id": d.id,
            "device_token": d.device_token,
            "device_type": d.device_type,
            "device_name": d.device_name,
            "last_active_at": d.last_active_at.isoformat() if d.last_active_at else None,
            "created_at": d.created_at.isoformat() if d.created_at else None
        } for d in devices]
    )
