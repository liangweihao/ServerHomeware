"""
通知数据访问层
提供通知相关的数据库操作
"""
from typing import Dict, List, Optional

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification


class NotificationRepository:
    """通知数据访问层"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, data: Dict) -> Notification:
        """创建通知"""
        notification = Notification(**data)
        self.db.add(notification)
        await self.db.commit()
        await self.db.refresh(notification)
        return notification

    async def get_by_id(self, notification_id: int, family_id: int) -> Optional[Notification]:
        """根据ID获取通知"""
        result = await self.db.execute(
            select(Notification).filter(
                Notification.id == notification_id,
                Notification.family_id == family_id
            )
        )
        return result.scalar_one_or_none()

    async def get_list(
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
        query = select(Notification).filter(Notification.family_id == family_id)

        # 筛选条件
        if user_id is not None:
            query = query.filter(
                (Notification.user_id == user_id) | (Notification.user_id.is_(None))
            )
        if notification_type:
            query = query.filter(Notification.type == notification_type)
        if is_read is not None:
            query = query.filter(Notification.is_read == is_read)

        query = query.order_by(Notification.created_at.desc())

        # 统计总数
        count_query = select(func.count()).select_from(query.subquery())
        total = await self.db.scalar(count_query)

        # 分页
        offset = (page - 1) * page_size
        query = query.offset(offset).limit(page_size)

        result = await self.db.execute(query)
        notifications = result.scalars().all()

        pages = (total + page_size - 1) // page_size if total else 0

        return {
            "items": notifications,
            "total": total,
            "page": page,
            "page_size": page_size,
            "pages": pages
        }

    async def get_unread_count(self, family_id: int, user_id: Optional[int] = None) -> int:
        """
        获取未读通知数量
        :param family_id: 家庭ID
        :param user_id: 用户ID（可选）
        :return: 未读数量
        """
        query = select(func.count()).select_from(Notification).filter(
            Notification.family_id == family_id,
            Notification.is_read == False
        )

        if user_id is not None:
            query = query.filter(
                (Notification.user_id == user_id) | (Notification.user_id.is_(None))
            )

        return await self.db.scalar(query) or 0

    async def mark_read(self, notification_id: int, family_id: int) -> bool:
        """
        标记通知为已读
        :param notification_id: 通知ID
        :param family_id: 家庭ID
        :return: 是否成功
        """
        notification = await self.get_by_id(notification_id, family_id)
        if not notification:
            return False

        notification.is_read = True
        await self.db.commit()
        return True

    async def mark_all_read(self, family_id: int, user_id: Optional[int] = None) -> int:
        """
        标记所有通知为已读
        :param family_id: 家庭ID
        :param user_id: 用户ID（可选）
        :return: 影响的行数
        """
        query = select(Notification).filter(
            Notification.family_id == family_id,
            Notification.is_read == False
        )

        if user_id is not None:
            query = query.filter(
                (Notification.user_id == user_id) | (Notification.user_id.is_(None))
            )

        result = await self.db.execute(query)
        notifications = result.scalars().all()

        for notification in notifications:
            notification.is_read = True

        await self.db.commit()
        return len(notifications)

    async def delete(self, notification_id: int, family_id: int) -> bool:
        """
        删除通知
        :param notification_id: 通知ID
        :param family_id: 家庭ID
        :return: 是否成功
        """
        notification = await self.get_by_id(notification_id, family_id)
        if not notification:
            return False

        await self.db.delete(notification)
        await self.db.commit()
        return True

    async def delete_old(self, days: int = 30) -> int:
        """
        删除旧通知
        :param days: 保留天数
        :return: 删除数量
        """
        from datetime import datetime, timedelta

        cutoff_date = datetime.now() - timedelta(days=days)

        result = await self.db.execute(
            select(Notification).filter(Notification.created_at < cutoff_date)
        )
        notifications = result.scalars().all()

        count = len(notifications)
        for notification in notifications:
            await self.db.delete(notification)

        await self.db.commit()
        return count

    async def check_sent_today(self, family_id: int, item_id: int, notification_type: str) -> bool:
        """
        检查今天是否已发送过该通知（用于去重）
        :param family_id: 家庭ID
        :param item_id: 物品ID
        :param notification_type: 通知类型
        :return: 是否已发送
        """
        from datetime import datetime, timedelta

        today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

        result = await self.db.execute(
            select(func.count()).select_from(Notification).filter(
                Notification.family_id == family_id,
                Notification.item_id == item_id,
                Notification.type == notification_type,
                Notification.created_at >= today_start
            )
        )
        count = await self.db.scalar(result)
        return (count or 0) > 0
