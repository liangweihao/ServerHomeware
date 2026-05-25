"""
用户设备数据访问层
提供设备相关的数据库操作
"""
from datetime import datetime, timezone
from typing import Dict, Optional

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user_device import UserDevice


class UserDeviceRepository:
    """用户设备数据访问层"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, data: Dict) -> UserDevice:
        """创建设备记录"""
        device = UserDevice(**data)
        self.db.add(device)
        await self.db.commit()
        await self.db.refresh(device)
        return device

    async def get_by_id(self, device_id: int) -> Optional[UserDevice]:
        """根据ID获取设备"""
        result = await self.db.execute(
            select(UserDevice).filter(UserDevice.id == device_id)
        )
        return result.scalar_one_or_none()

    async def get_by_token(self, device_token: str) -> Optional[UserDevice]:
        """根据设备token获取设备"""
        result = await self.db.execute(
            select(UserDevice).filter(UserDevice.device_token == device_token)
        )
        return result.scalar_one_or_none()

    async def get_by_user(self, user_id: int) -> list:
        """获取用户的所有设备"""
        result = await self.db.execute(
            select(UserDevice).filter(UserDevice.user_id == user_id)
        )
        return result.scalars().all()

    async def update(self, device_id: int, data: Dict) -> Optional[UserDevice]:
        """更新设备信息"""
        device = await self.get_by_id(device_id)
        if not device:
            return None
        
        for key, value in data.items():
            if hasattr(device, key):
                setattr(device, key, value)
        
        await self.db.commit()
        await self.db.refresh(device)
        return device

    async def update_last_active(self, device_token: str):
        """更新设备最后活跃时间"""
        device = await self.get_by_token(device_token)
        if device:
            device.last_active_at = datetime.now(timezone.utc)
            await self.db.commit()

    async def delete(self, device_id: int) -> bool:
        """删除设备"""
        device = await self.get_by_id(device_id)
        if not device:
            return False
        
        await self.db.delete(device)
        await self.db.commit()
        return True

    async def upsert(self, user_id: int, device_token: str, device_type: str, device_name: str = None) -> UserDevice:
        """
        更新或创建设备记录
        如果设备已存在则更新，否则创建新记录
        """
        device = await self.get_by_token(device_token)
        
        if device:
            # 更新现有设备
            device.user_id = user_id
            device.device_type = device_type
            if device_name:
                device.device_name = device_name
            device.last_active_at = datetime.now(timezone.utc)
        else:
            # 创建新设备
            device = UserDevice(
                user_id=user_id,
                device_token=device_token,
                device_type=device_type,
                device_name=device_name,
                last_active_at=datetime.now(timezone.utc)
            )
            self.db.add(device)
        
        await self.db.commit()
        await self.db.refresh(device)
        return device
