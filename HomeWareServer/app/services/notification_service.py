"""
通知服务模块
处理通知相关的业务逻辑
"""
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification
from app.models.notification_preference import NotificationPreference
from app.repositories.notification_repo import NotificationRepository

logger = logging.getLogger(__name__)


class NotificationService:
    """通知服务"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.repo = NotificationRepository(db)

    async def create_notification(
        self,
        family_id: int,
        notification_type: str,
        title: str,
        body: str,
        user_id: Optional[int] = None,
        item_id: Optional[int] = None,
        priority: str = "medium",
        action_url: Optional[str] = None,
        send_push: bool = True
    ) -> Notification:
        """
        创建通知
        :param family_id: 家庭ID
        :param notification_type: 通知类型
        :param title: 通知标题
        :param body: 通知内容
        :param user_id: 用户ID（null=全家庭）
        :param item_id: 物品ID
        :param priority: 优先级
        :param action_url: 点击跳转路径
        :param send_push: 是否发送推送
        :return: 创建的通知
        """
        logger.info(f"创建通知: family={family_id}, type={notification_type}, title={title}")

        # 创建通知记录
        notification = await self.repo.create({
            "family_id": family_id,
            "user_id": user_id,
            "type": notification_type,
            "title": title,
            "body": body,
            "item_id": item_id,
            "priority": priority,
            "action_url": action_url
        })

        # 发送推送通知
        if send_push:
            await self._send_push_notification(family_id, user_id, notification_type, title, body, item_id, action_url)

        return notification

    async def _send_push_notification(
        self,
        family_id: int,
        user_id: Optional[int],
        notification_type: str,
        title: str,
        body: str,
        item_id: Optional[int],
        action_url: Optional[str]
    ):
        """
        发送推送通知
        :param family_id: 家庭ID
        :param user_id: 用户ID
        :param notification_type: 通知类型
        :param title: 标题
        :param body: 内容
        :param item_id: 物品ID
        :param action_url: 跳转路径
        """
        from app.services.push_service import PushService

        try:
            push_service = PushService(self.db)

            # 准备推送数据
            data = {
                "type": notification_type,
                "item_id": str(item_id) if item_id else "",
                "route": action_url or ""
            }

            # 推送给指定用户或全家
            if user_id:
                # 检查用户是否应该接收通知
                should_send, reason = await self.should_send_notification(user_id, notification_type)
                if should_send:
                    await push_service.push_to_user(user_id, title, body, data)
                    logger.info(f"推送已发送给用户 {user_id}: {title}")
                else:
                    logger.info(f"跳过推送给用户 {user_id}: {reason}")
            else:
                # 推送给家庭所有成员
                await push_service.push_to_family(family_id, title, body, data)
                logger.info(f"推送已发送给家庭 {family_id}: {title}")

        except Exception as e:
            logger.error(f"发送推送失败: {e}")

    async def should_send_notification(
        self,
        user_id: int,
        notification_type: str
    ) -> Tuple[bool, str]:
        """
        检查是否应发送通知，考虑用户偏好和免打扰时段
        :param user_id: 用户ID
        :param notification_type: 通知类型
        :return: (是否应发送, 原因)
        """
        # 获取用户通知偏好
        result = await self.db.get(NotificationPreference, user_id)

        if not result:
            # 如果没有偏好设置，默认允许发送
            return True, "用户未设置偏好"

        preference = result

        # 检查全局推送开关
        if not preference.push_enabled:
            return False, "用户全局关闭推送"

        # 检查对应类型的推送开关
        if not preference.is_notification_enabled(notification_type):
            return False, f"用户关闭了{notification_type}类型通知"

        # 检查免打扰时段
        if preference.is_in_quiet_hours():
            return False, "用户在免打扰时段"

        return True, "允许发送"

    async def get_notifications(
        self,
        family_id: int,
        user_id: Optional[int] = None,
        notification_type: Optional[str] = None,
        is_read: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Dict:
        """
        获取通知列表（分页）
        :param family_id: 家庭ID
        :param user_id: 用户ID（可选）
        :param notification_type: 通知类型（可选）
        :param is_read: 是否已读（可选）
        :param page: 页码
        :param page_size: 每页大小
        :return: 分页结果
        """
        return await self.repo.get_list(
            family_id=family_id,
            user_id=user_id,
            notification_type=notification_type,
            is_read=is_read,
            page=page,
            page_size=page_size
        )

    async def get_unread_count(self, family_id: int, user_id: Optional[int] = None) -> int:
        """
        获取未读通知数量
        :param family_id: 家庭ID
        :param user_id: 用户ID（可选）
        :return: 未读数量
        """
        return await self.repo.get_unread_count(family_id, user_id)

    async def mark_read(self, notification_id: int, family_id: int) -> bool:
        """
        标记通知为已读
        :param notification_id: 通知ID
        :param family_id: 家庭ID
        :return: 是否成功
        """
        return await self.repo.mark_read(notification_id, family_id)

    async def mark_all_read(self, family_id: int, user_id: Optional[int] = None) -> int:
        """
        标记所有通知为已读
        :param family_id: 家庭ID
        :param user_id: 用户ID（可选）
        :return: 影响的行数
        """
        return await self.repo.mark_all_read(family_id, user_id)

    async def delete_notification(self, notification_id: int, family_id: int) -> bool:
        """
        删除通知
        :param notification_id: 通知ID
        :param family_id: 家庭ID
        :return: 是否成功
        """
        return await self.repo.delete(notification_id, family_id)

    async def check_and_create_expiry_notification(
        self,
        family_id: int,
        item_id: int,
        item_name: str,
        days_until_expiry: int
    ) -> bool:
        """
        检查是否需要创建过期通知（去重）
        :param family_id: 家庭ID
        :param item_id: 物品ID
        :param item_name: 物品名称
        :param days_until_expiry: 距离过期的天数
        :return: 是否创建了通知
        """
        # 检查今天是否已发送过该通知
        is_sent = await self.repo.check_sent_today(family_id, item_id, Notification.TYPE_EXPIRY)
        if is_sent:
            logger.info(f"物品 {item_name} 今天已发送过期通知，跳过")
            return False

        # 确定优先级和消息
        if days_until_expiry < 0:
            priority = Notification.PRIORITY_HIGH
            title = "⚠️ 物品已过期"
            body = f"{item_name} 已过期{abs(days_until_expiry)}天，请及时处理"
        elif days_until_expiry == 0:
            priority = Notification.PRIORITY_HIGH
            title = "⚠️ 物品今天过期"
            body = f"{item_name} 今天过期，请尽快处理"
        elif days_until_expiry <= 3:
            priority = Notification.PRIORITY_HIGH
            title = "⚠️ 物品即将过期"
            body = f"{item_name} 还剩{days_until_expiry}天过期，请及时处理"
        else:
            priority = Notification.PRIORITY_MEDIUM
            title = "📅 物品即将过期"
            body = f"{item_name} 还剩{days_until_expiry}天过期"

        # 创建通知
        await self.create_notification(
            family_id=family_id,
            notification_type=Notification.TYPE_EXPIRY,
            title=title,
            body=body,
            item_id=item_id,
            priority=priority,
            action_url=f"/items/{item_id}"
        )

        logger.info(f"已创建过期通知: {item_name}, {days_until_expiry}天后过期")
        return True

    async def create_stock_notification(
        self,
        family_id: int,
        item_id: int,
        item_name: str,
        current_quantity: float,
        unit: str,
        safety_stock: float
    ) -> bool:
        """
        创建库存不足通知
        :param family_id: 家庭ID
        :param item_id: 物品ID
        :param item_name: 物品名称
        :param current_quantity: 当前库存
        :param unit: 单位
        :param safety_stock: 安全库存
        :return: 是否创建了通知
        """
        # 检查今天是否已发送过该通知
        is_sent = await self.repo.check_sent_today(family_id, item_id, Notification.TYPE_STOCK)
        if is_sent:
            logger.info(f"物品 {item_name} 今天已发送库存通知，跳过")
            return False

        # 确定优先级和消息
        if current_quantity <= 0:
            priority = Notification.PRIORITY_HIGH
            title = "📦 库存已耗尽"
            body = f"{item_name} 库存已耗尽，请及时补充"
        elif current_quantity <= safety_stock * 0.5:
            priority = Notification.PRIORITY_HIGH
            title = "📦 库存严重不足"
            body = f"{item_name} 库存严重不足，剩余{current_quantity}{unit}"
        else:
            priority = Notification.PRIORITY_MEDIUM
            title = "📦 库存不足"
            body = f"{item_name} 库存不足，剩余{current_quantity}{unit}，安全线为{safety_stock}{unit}"

        # 创建通知
        await self.create_notification(
            family_id=family_id,
            notification_type=Notification.TYPE_STOCK,
            title=title,
            body=body,
            item_id=item_id,
            priority=priority,
            action_url=f"/items/{item_id}"
        )

        logger.info(f"已创建库存通知: {item_name}, 剩余{current_quantity}{unit}")
        return True
