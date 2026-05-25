"""
推送服务模块
处理 FCM 推送通知
"""
import logging
from typing import Dict, List, Optional

import httpx
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.user_device import UserDevice
from app.repositories.user_device_repo import UserDeviceRepository

logger = logging.getLogger(__name__)


class PushService:
    """推送服务"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.device_repo = UserDeviceRepository(db)
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"

    async def push_to_user(
        self,
        user_id: int,
        title: str,
        body: str,
        data: Optional[Dict] = None
    ) -> Dict:
        """
        向指定用户推送通知
        :param user_id: 用户ID
        :param title: 通知标题
        :param body: 通知内容
        :param data: 自定义数据
        :return: 推送结果
        """
        logger.info(f"推送通知给用户 {user_id}: {title}")

        # 获取用户的所有设备
        devices = await self.device_repo.get_by_user(user_id)

        if not devices:
            logger.warning(f"用户 {user_id} 没有注册设备")
            return {"success": 0, "failed": 0, "message": "没有注册设备"}

        # 向每个设备发送推送
        success_count = 0
        failed_count = 0

        for device in devices:
            result = await self._send_fcm(
                device_token=device.device_token,
                title=title,
                body=body,
                data=data
            )

            if result["success"]:
                success_count += 1
            else:
                failed_count += 1
                # 如果 token 失效，删除该设备记录
                if result.get("invalid_token"):
                    await self.device_repo.delete(device.id)
                    logger.info(f"删除失效设备: {device.id}")

        return {
            "success": success_count,
            "failed": failed_count,
            "total": len(devices)
        }

    async def push_to_family(
        self,
        family_id: int,
        title: str,
        body: str,
        data: Optional[Dict] = None,
        exclude_user_id: Optional[int] = None
    ) -> Dict:
        """
        向家庭所有成员推送通知
        :param family_id: 家庭ID
        :param title: 通知标题
        :param body: 通知内容
        :param data: 自定义数据
        :param exclude_user_id: 排除的用户ID（可选）
        :return: 推送结果
        """
        from app.models.family import FamilyMember
        from sqlalchemy import select

        logger.info(f"推送通知给家庭 {family_id}: {title}")

        # 获取家庭所有成员
        result = await self.db.execute(
            select(FamilyMember.user_id).filter(FamilyMember.family_id == family_id)
        )
        user_ids = [row[0] for row in result.all()]

        # 排除指定用户
        if exclude_user_id:
            user_ids = [uid for uid in user_ids if uid != exclude_user_id]

        if not user_ids:
            return {"success": 0, "failed": 0, "message": "没有家庭成员"}

        # 向每个成员推送
        total_success = 0
        total_failed = 0

        for user_id in user_ids:
            result = await self.push_to_user(user_id, title, body, data)
            total_success += result.get("success", 0)
            total_failed += result.get("failed", 0)

        return {
            "success": total_success,
            "failed": total_failed,
            "total": len(user_ids)
        }

    async def _send_fcm(
        self,
        device_token: str,
        title: str,
        body: str,
        data: Optional[Dict] = None
    ) -> Dict:
        """
        发送 FCM 推送
        :param device_token: 设备 token
        :param title: 通知标题
        :param body: 通知内容
        :param data: 自定义数据
        :return: 发送结果
        """
        if not settings.FCM_SERVER_KEY:
            logger.warning("FCM_SERVER_KEY 未配置，跳过推送")
            return {"success": False, "message": "FCM未配置"}

        try:
            headers = {
                "Authorization": f"key={settings.FCM_SERVER_KEY}",
                "Content-Type": "application/json"
            }

            payload = {
                "notification": {
                    "title": title,
                    "body": body,
                    "sound": "default"
                },
                "data": data or {},
                "to": device_token
            }

            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.fcm_url,
                    headers=headers,
                    json=payload,
                    timeout=10.0
                )

            if response.status_code == 200:
                result = response.json()
                if result.get("success", 0) > 0:
                    logger.info(f"推送成功: {device_token[:20]}...")
                    return {"success": True}
                else:
                    error = result.get("results", [{}])[0].get("error", "Unknown")
                    logger.warning(f"推送失败: {error}")
                    return {
                        "success": False,
                        "error": error,
                        "invalid_token": error in ["InvalidRegistration", "NotRegistered"]
                    }
            else:
                logger.error(f"FCM 请求失败: {response.status_code}")
                return {"success": False, "message": f"HTTP {response.status_code}"}

        except Exception as e:
            logger.error(f"推送异常: {e}")
            return {"success": False, "message": str(e)}


class SyncPushService:
    """同步推送服务（用于 Celery 任务）"""

    @staticmethod
    def push_to_user_sync(
        db_url: str,
        user_id: int,
        title: str,
        body: str,
        data: Optional[Dict] = None
    ):
        """
        同步方式向用户推送通知（用于 Celery 任务）
        """
        from sqlalchemy import create_engine, select
        from sqlalchemy.orm import sessionmaker

        engine = create_engine(db_url)
        Session = sessionmaker(bind=engine)
        session = Session()

        try:
            # 获取用户设备
            result = session.execute(
                select(UserDevice).filter(UserDevice.user_id == user_id)
            )
            devices = result.scalars().all()

            if not devices:
                logger.info(f"用户 {user_id} 没有注册设备")
                return {"success": 0, "failed": 0}

            success_count = 0
            failed_count = 0

            for device in devices:
                try:
                    headers = {
                        "Authorization": f"key={settings.FCM_SERVER_KEY}",
                        "Content-Type": "application/json"
                    }

                    payload = {
                        "notification": {
                            "title": title,
                            "body": body,
                            "sound": "default"
                        },
                        "data": data or {},
                        "to": device.device_token
                    }

                    import requests
                    response = requests.post(
                        "https://fcm.googleapis.com/fcm/send",
                        headers=headers,
                        json=payload,
                        timeout=10
                    )

                    if response.status_code == 200:
                        result = response.json()
                        if result.get("success", 0) > 0:
                            success_count += 1
                        else:
                            failed_count += 1
                    else:
                        failed_count += 1

                except Exception as e:
                    logger.error(f"推送异常: {e}")
                    failed_count += 1

            return {"success": success_count, "failed": failed_count}

        finally:
            session.close()
