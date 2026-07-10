"""
问管管对话消息数据访问层
"""
import logging
from typing import Dict, List, Optional

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.assistant_chat_message import AssistantChatMessage

logger = logging.getLogger(__name__)


class AssistantChatRepository:
    """问管管对话 Repository"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(
        self,
        family_id: int,
        user_id: int,
        role: str,
        content: str,
        meta_json: Optional[Dict] = None,
    ) -> AssistantChatMessage:
        """写入一条对话消息"""
        row = AssistantChatMessage(
            family_id=family_id,
            user_id=user_id,
            role=role,
            content=content,
            meta_json=meta_json,
        )
        self.db.add(row)
        await self.db.commit()
        await self.db.refresh(row)
        return row

    async def get_recent(
        self,
        family_id: int,
        user_id: int,
        limit: int = 50,
    ) -> List[AssistantChatMessage]:
        """按时间正序返回最近 N 条（供 UI 展示）"""
        query = (
            select(AssistantChatMessage)
            .where(
                AssistantChatMessage.family_id == family_id,
                AssistantChatMessage.user_id == user_id,
            )
            .order_by(AssistantChatMessage.created_at.desc())
            .limit(limit)
        )
        result = await self.db.execute(query)
        rows = list(result.scalars().all())
        rows.reverse()
        return rows

    async def get_llm_context(
        self,
        family_id: int,
        user_id: int,
        limit: int = 12,
    ) -> List[Dict[str, str]]:
        """返回 LLM 多轮上下文 [{role, content}, ...]"""
        rows = await self.get_recent(family_id, user_id, limit=limit)
        return [{"role": r.role, "content": r.content} for r in rows]

    async def delete_all(self, family_id: int, user_id: int) -> int:
        """清空当前用户在该家庭下的对话"""
        stmt = delete(AssistantChatMessage).where(
            AssistantChatMessage.family_id == family_id,
            AssistantChatMessage.user_id == user_id,
        )
        result = await self.db.execute(stmt)
        await self.db.commit()
        deleted = result.rowcount or 0
        logger.info(
            "[AssistantChatRepo] INFO: 清空对话 family=%d user=%d deleted=%d",
            family_id,
            user_id,
            deleted,
        )
        return deleted

    async def trim(self, family_id: int, user_id: int, keep: int = 100) -> None:
        """保留最近 keep 条，删除更早记录"""
        count_q = select(func.count()).select_from(AssistantChatMessage).where(
            AssistantChatMessage.family_id == family_id,
            AssistantChatMessage.user_id == user_id,
        )
        total = await self.db.scalar(count_q) or 0
        if total <= keep:
            return

        ids_q = (
            select(AssistantChatMessage.id)
            .where(
                AssistantChatMessage.family_id == family_id,
                AssistantChatMessage.user_id == user_id,
            )
            .order_by(AssistantChatMessage.created_at.asc())
            .limit(total - keep)
        )
        result = await self.db.execute(ids_q)
        old_ids = [row[0] for row in result.all()]
        if not old_ids:
            return

        await self.db.execute(
            delete(AssistantChatMessage).where(AssistantChatMessage.id.in_(old_ids))
        )
        await self.db.commit()
        logger.info(
            "[AssistantChatRepo] INFO: 裁剪对话 family=%d user=%d removed=%d keep=%d",
            family_id,
            user_id,
            len(old_ids),
            keep,
        )
