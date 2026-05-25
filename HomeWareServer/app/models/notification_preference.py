"""
用户通知偏好模型模块
定义 NotificationPreference 模型
"""
from sqlalchemy import Boolean, Column, ForeignKey, Time

from app.core.database import Base


class NotificationPreference(Base):
    """用户通知偏好模型"""

    __tablename__ = "notification_preferences"

    user_id = Column(ForeignKey("users.id"), primary_key=True, comment="用户ID")
    push_enabled = Column(Boolean, default=True, comment="全局推送开关")
    expiry_alert = Column(Boolean, default=True, comment="过期提醒")
    stock_alert = Column(Boolean, default=True, comment="库存提醒")
    purchase_alert = Column(Boolean, default=True, comment="补购提醒")
    warranty_alert = Column(Boolean, default=True, comment="保修提醒")
    quiet_start = Column(Time, nullable=True, comment="免打扰开始时间")
    quiet_end = Column(Time, nullable=True, comment="免打扰结束时间")

    def is_notification_enabled(self, notification_type: str) -> bool:
        """
        检查指定类型的通知是否开启
        :param notification_type: 通知类型
        :return: 是否开启
        """
        if not self.push_enabled:
            return False

        type_map = {
            "expiry": self.expiry_alert,
            "stock": self.stock_alert,
            "purchase": self.purchase_alert,
            "warranty": self.warranty_alert,
        }

        return type_map.get(notification_type, True)

    def is_in_quiet_hours(self) -> bool:
        """
        检查当前时间是否在免打扰时段内
        :return: 是否在免打扰时段
        """
        from datetime import datetime, time

        if not self.quiet_start or not self.quiet_end:
            return False

        now = datetime.now().time()

        # 处理跨天的情况（如 22:00 - 08:00）
        if self.quiet_start <= self.quiet_end:
            return self.quiet_start <= now <= self.quiet_end
        else:
            return now >= self.quiet_start or now <= self.quiet_end
