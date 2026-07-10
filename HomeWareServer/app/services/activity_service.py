"""
活动服务模块
处理活动日志相关业务逻辑
"""
import logging
from datetime import datetime
from typing import Dict, List

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.activity_log import ActivityLog
from app.repositories.activity_log_repo import ActivityLogRepository

logger = logging.getLogger(__name__)


class ActivityService:
    """活动服务"""

    def __init__(self, db: AsyncSession):
        self.repo = ActivityLogRepository(db)

    async def log_activity(self, family_id: int, user_id: int, action: str, 
                          target_type: str = None, target_id: int = None, 
                          target_name: str = None, detail: Dict = None):
        """
        记录活动日志
        :param family_id: 家庭ID
        :param user_id: 用户ID
        :param action: 操作类型
        :param target_type: 目标类型
        :param target_id: 目标ID
        :param target_name: 目标名称
        :param detail: 详细信息
        """
        await self.repo.create({
            "family_id": family_id,
            "user_id": user_id,
            "action": action,
            "target_type": target_type,
            "target_id": target_id,
            "target_name": target_name,
            "detail": detail
        })
        logger.debug(f"记录活动日志: user={user_id}, action={action}, target={target_type}:{target_id}")

    async def get_family_activities(self, family_id: int, page: int = 1, page_size: int = 20) -> Dict:
        """
        获取家庭的活动日志
        :param family_id: 家庭ID
        :param page: 页码
        :param page_size: 每页大小
        :return: 分页结果
        """
        return await self.repo.get_by_family(family_id, page, page_size)

    async def get_user_activities(self, user_id: int, family_id: int = None, page: int = 1, page_size: int = 20) -> Dict:
        """
        获取用户的活动日志
        :param user_id: 用户ID
        :param family_id: 家庭ID（可选）
        :param page: 页码
        :param page_size: 每页大小
        :return: 分页结果
        """
        return await self.repo.get_by_user(user_id, family_id, page, page_size)

    async def get_recent_activities(self, family_id: int, limit: int = 5) -> List[Dict]:
        """
        获取最近的活动记录（用于首页动态流）
        :param family_id: 家庭ID
        :param limit: 返回数量
        :return: 活动列表（包含格式化后的描述）
        """
        logs = await self.repo.get_recent(family_id, limit)
        return [self._format_activity(log) for log in logs]

    def _format_activity(self, log: ActivityLog) -> Dict:
        """
        格式化活动日志为可读格式
        :param log: 活动日志对象
        :return: 格式化后的活动信息
        """
        action_map = {
            ActivityLog.ACTION_CREATE_ITEM: "创建了物品",
            ActivityLog.ACTION_UPDATE_ITEM: "更新了物品",
            ActivityLog.ACTION_DELETE_ITEM: "删除了物品",
            ActivityLog.ACTION_USE_ITEM: "使用了",
            ActivityLog.ACTION_FINISH_ITEM: "标记物品已用完",
            ActivityLog.ACTION_DISCARD_ITEM: "丢弃了物品",
            ActivityLog.ACTION_MOVE_ITEM: "移动了物品",
            ActivityLog.ACTION_CREATE_LOCATION: "创建了位置",
            ActivityLog.ACTION_UPDATE_LOCATION: "更新了位置",
            ActivityLog.ACTION_DELETE_LOCATION: "删除了位置",
            ActivityLog.ACTION_CREATE_CATEGORY: "创建了分类",
            ActivityLog.ACTION_UPDATE_CATEGORY: "更新了分类",
            ActivityLog.ACTION_DELETE_CATEGORY: "删除了分类",
            ActivityLog.ACTION_ADD_SHOPPING_ITEM: "添加到购物清单",
            ActivityLog.ACTION_PURCHASE_SHOPPING_ITEM: "标记已购买",
            ActivityLog.ACTION_JOIN_FAMILY: "加入了家庭",
            ActivityLog.ACTION_LEAVE_FAMILY: "离开了家庭",
            ActivityLog.ACTION_UPDATE_MEMBER_ROLE: "修改了成员角色",
            ActivityLog.ACTION_ASSISTANT_CHAT: "使用了 AI 助手",
        }

        action_text = action_map.get(log.action, log.action)
        
        return {
            "id": log.id,
            "user_id": log.user_id,
            "action": log.action,
            "action_text": action_text,
            "target_type": log.target_type,
            "target_id": log.target_id,
            "target_name": log.target_name,
            "detail": log.detail,
            "created_at": log.created_at.isoformat() if log.created_at else None
        }
