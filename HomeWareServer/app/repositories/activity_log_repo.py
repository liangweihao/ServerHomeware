"""
活动日志数据访问层
提供活动日志相关的数据库操作
"""
from typing import Dict, List, Optional

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.activity_log import ActivityLog


class ActivityLogRepository:
    """活动日志数据访问层"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, data: Dict) -> ActivityLog:
        """创建活动日志"""
        log = ActivityLog(**data)
        self.db.add(log)
        await self.db.commit()
        await self.db.refresh(log)
        return log

    async def get_by_family(self, family_id: int, page: int = 1, page_size: int = 20) -> Dict:
        """获取家庭的活动日志（分页）"""
        query = select(ActivityLog).filter(
            ActivityLog.family_id == family_id
        ).order_by(ActivityLog.created_at.desc())
        
        # 统计总数
        count_query = select(ActivityLog.id).filter(ActivityLog.family_id == family_id)
        total = await self.db.scalar(select(func.count()).select_from(count_query.subquery()))
        
        # 分页
        offset = (page - 1) * page_size
        query = query.offset(offset).limit(page_size)
        
        result = await self.db.execute(query)
        logs = result.scalars().all()
        
        pages = (total + page_size - 1) // page_size if total else 0
        
        return {
            "items": logs,
            "total": total,
            "page": page,
            "page_size": page_size,
            "pages": pages
        }

    async def get_by_user(self, user_id: int, family_id: int = None, page: int = 1, page_size: int = 20) -> Dict:
        """获取用户的活动日志（分页）"""
        query = select(ActivityLog).filter(ActivityLog.user_id == user_id)
        
        if family_id:
            query = query.filter(ActivityLog.family_id == family_id)
        
        query = query.order_by(ActivityLog.created_at.desc())
        
        count_query = select(ActivityLog.id).filter(ActivityLog.user_id == user_id)
        if family_id:
            count_query = count_query.filter(ActivityLog.family_id == family_id)
        
        total = await self.db.scalar(select(func.count()).select_from(count_query.subquery()))
        
        offset = (page - 1) * page_size
        query = query.offset(offset).limit(page_size)
        
        result = await self.db.execute(query)
        logs = result.scalars().all()
        
        pages = (total + page_size - 1) // page_size if total else 0
        
        return {
            "items": logs,
            "total": total,
            "page": page,
            "page_size": page_size,
            "pages": pages
        }

    async def get_recent(self, family_id: int, limit: int = 5) -> List[ActivityLog]:
        """获取最近的活动日志"""
        query = select(ActivityLog).filter(
            ActivityLog.family_id == family_id
        ).order_by(ActivityLog.created_at.desc()).limit(limit)
        
        result = await self.db.execute(query)
        return result.scalars().all()
