"""
AI 助手路由模块
提供基于 DeepSeek 大模型的家庭物品智能对话接口
对话历史持久化在服务端（按家庭 + 用户）
"""
import logging
from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_family, get_current_user
from app.models.activity_log import ActivityLog
from app.models.user import User
from app.repositories.assistant_chat_repo import AssistantChatRepository
from app.schemas.common import ResponseSchema
from app.services.activity_service import ActivityService
from app.services.llm_service import LlmService

router = APIRouter(prefix="/assistant", tags=["assistant"])

logger = logging.getLogger(__name__)

# 每个用户最多保留的对话条数
_MAX_STORED_MESSAGES = 100


# ──────────────────────────────────────────────
# Request / Response Schemas
# ──────────────────────────────────────────────

class ChatHistoryItem(BaseModel):
    """单条历史消息（客户端可选上传，服务端优先用 DB）"""
    role: str = Field(..., description="user 或 assistant")
    content: str = Field(..., description="消息内容")


class AssistantChatRequest(BaseModel):
    """对话请求"""
    message: str = Field(..., min_length=1, max_length=500, description="用户消息")
    history: Optional[List[ChatHistoryItem]] = Field(
        default=None, description="历史消息（可选，服务端 DB 优先）"
    )
    local_items: Optional[List[Dict[str, Any]]] = Field(
        default=None,
        description="客户端本地库存快照 [{name, quantity, unit, location}]，服务端 DB 无数据时兜底",
    )


class AssistantItemCard(BaseModel):
    """助手回复中可点击跳转的物品卡片"""
    name: str = Field(..., description="物品名称")
    subtitle: str = Field(default="", description="位置 · 数量等副信息")
    item_id: Optional[int] = Field(default=None, description="服务端 items.id")
    local_id: Optional[int] = Field(default=None, description="客户端 Drift 本地主键")


class AssistantChatResponse(BaseModel):
    """对话响应"""
    text: str = Field(..., description="助手回复文本")
    shopping_added: List[str] = Field(default=[], description="本轮自动加入购物清单的物品名称")
    action: Optional[str] = Field(default=None, description="附加动作（预留）")
    items: List[AssistantItemCard] = Field(default=[], description="本轮查询命中的可点击物品")


class AssistantHistoryMessage(BaseModel):
    """历史消息条目"""
    id: int
    role: str
    content: str
    meta: Optional[Dict[str, Any]] = None
    created_at: datetime


class AssistantHistoryResponse(BaseModel):
    """历史列表响应"""
    messages: List[AssistantHistoryMessage]
    total: int


# ──────────────────────────────────────────────
# 内部工具
# ──────────────────────────────────────────────

def _format_assistant_display(text: str, shopping_added: List[str]) -> str:
    """组装客户端展示用助手正文"""
    if not shopping_added:
        return text
    joined = "、".join(shopping_added)
    return f"{text}\n\n已将【{joined}】加入购物清单 ✓"


async def _resolve_llm_history(
    repo: AssistantChatRepository,
    family_id: int,
    user_id: int,
    client_history: Optional[List[ChatHistoryItem]],
) -> Optional[List[Dict[str, str]]]:
    """优先从 DB 读取 LLM 上下文，无记录时回退客户端上传"""
    db_history = await repo.get_llm_context(family_id, user_id, limit=12)
    if db_history:
        logger.info(
            "[AssistantRouter] INFO: 使用 DB 历史 context_len=%d",
            len(db_history),
        )
        return db_history
    if client_history:
        logger.info(
            "[AssistantRouter] INFO: 使用客户端上传历史 context_len=%d",
            len(client_history),
        )
        return [{"role": h.role, "content": h.content} for h in client_history]
    return None


# ──────────────────────────────────────────────
# 路由
# ──────────────────────────────────────────────

@router.get("/history", summary="获取问管管对话历史")
async def get_assistant_history(
    limit: int = Query(50, ge=1, le=100, description="最多返回条数"),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """按当前登录用户 + 家庭加载服务端持久化的对话记录"""
    repo = AssistantChatRepository(db)
    rows = await repo.get_recent(current_family_id, current_user.id, limit=limit)
    messages = [
        AssistantHistoryMessage(
            id=r.id,
            role=r.role,
            content=r.content,
            meta=r.meta_json,
            created_at=r.created_at,
        )
        for r in rows
    ]
    logger.info(
        "[AssistantRouter] INFO: 加载历史 family=%d user=%d count=%d",
        current_family_id,
        current_user.id,
        len(messages),
    )
    return ResponseSchema(
        code=200,
        message="success",
        data=AssistantHistoryResponse(messages=messages, total=len(messages)),
    )


@router.delete("/history", summary="清空问管管对话历史")
async def clear_assistant_history(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """清空当前用户在该家庭下的全部对话"""
    repo = AssistantChatRepository(db)
    deleted = await repo.delete_all(current_family_id, current_user.id)
    return ResponseSchema(
        code=200,
        message="success",
        data={"deleted": deleted},
    )


@router.post("/chat", summary="AI 助手多轮对话")
async def assistant_chat(
    body: AssistantChatRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db),
):
    """
    AI 助手对话接口（支持多轮）

    - 对话历史持久化在服务端，重装 App 可恢复
    - LLM 上下文优先从 DB 加载
    - 支持 Function Calling 查询家庭库存
    """
    logger.info(
        "[AssistantRouter] INFO: family=%d user=%d msg_preview=%s local_items=%d",
        current_family_id,
        current_user.id,
        body.message[:30],
        len(body.local_items or []),
    )

    repo = AssistantChatRepository(db)
    history = await _resolve_llm_history(
        repo, current_family_id, current_user.id, body.history
    )

    # 持久化用户消息
    try:
        await repo.create(
            family_id=current_family_id,
            user_id=current_user.id,
            role="user",
            content=body.message,
        )
    except Exception as e:
        logger.warning("[AssistantRouter] WARN: 用户消息保存失败 err=%s", e)

    service = LlmService(
        db,
        family_id=current_family_id,
        user_id=current_user.id,
        local_items=body.local_items,
    )
    result = await service.chat(user_message=body.message, history=history)

    reply_text = result.get("text") or ""
    shopping_added = result.get("shopping_added", []) or []
    referenced_items = result.get("items", []) or []
    display_text = _format_assistant_display(reply_text, shopping_added)

    item_cards = [
        AssistantItemCard(
            name=str(i.get("name") or ""),
            subtitle=str(i.get("subtitle") or ""),
            item_id=i.get("item_id"),
            local_id=i.get("local_id"),
        )
        for i in referenced_items
        if i.get("name")
    ]

    logger.info(
        "[AssistantRouter] INFO: 管管回复 family=%d user=%d text=%s items=%s",
        current_family_id,
        current_user.id,
        display_text[:500],
        [c.name for c in item_cards],
    )

    # 持久化助手回复（meta 含物品卡片，历史恢复时可点击）
    meta_json: Optional[Dict[str, Any]] = None
    if shopping_added or item_cards:
        meta_json = {}
        if shopping_added:
            meta_json["shopping_added"] = shopping_added
        if item_cards:
            meta_json["items"] = [
                {
                    "itemId": c.local_id or 0,
                    "item_id": c.item_id,
                    "local_id": c.local_id,
                    "name": c.name,
                    "subtitle": c.subtitle,
                }
                for c in item_cards
            ]

    # 持久化助手回复
    try:
        await repo.create(
            family_id=current_family_id,
            user_id=current_user.id,
            role="assistant",
            content=display_text,
            meta_json=meta_json,
        )
        await repo.trim(current_family_id, current_user.id, keep=_MAX_STORED_MESSAGES)
    except Exception as e:
        logger.warning("[AssistantRouter] WARN: 助手消息保存失败 err=%s", e)

    # 活动日志（意图分析）
    history_turns = len(history) // 2 if history else 0
    try:
        activity = ActivityService(db)
        await activity.log_activity(
            family_id=current_family_id,
            user_id=current_user.id,
            action=ActivityLog.ACTION_ASSISTANT_CHAT,
            target_type="assistant",
            target_name=body.message[:50],
            detail={
                "message": body.message,
                "reply_preview": reply_text[:200],
                "shopping_added": shopping_added,
                "history_turns": history_turns,
            },
        )
    except Exception as e:
        logger.warning("[AssistantRouter] WARN: 对话记录失败 err=%s", e)

    return ResponseSchema(
        code=200,
        message="success",
        data=AssistantChatResponse(
            text=display_text,
            shopping_added=shopping_added,
            action=result.get("action"),
            items=item_cards,
        ),
    )


class EnrichItemDraftRequest(BaseModel):
    """入库草稿 AI 增强：生成备注 + 检索别名"""
    name: str = Field(..., min_length=1, max_length=100, description="物品名称")
    brand: Optional[str] = Field(None, max_length=50, description="品牌")
    category_name: Optional[str] = Field(None, max_length=50, description="分类名")
    specification: Optional[str] = Field(None, max_length=100, description="规格")
    existing_notes: Optional[str] = Field(None, max_length=500, description="已有备注")


class EnrichItemDraftResponse(BaseModel):
    notes: str = Field(..., description="生成的备注文案")
    search_aliases: List[str] = Field(default=[], description="检索别名列表")


@router.post("/enrich-item", summary="入库草稿魔法备注（备注+检索别名）")
async def enrich_item_draft(
    body: EnrichItemDraftRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
):
    """
    根据已填入库信息生成口语化备注与检索别名。
    不写库；由客户端填入表单，保存物品时一并提交 search_aliases。
    """
    from app.services.item_enrich_service import ItemEnrichService

    logger.info(
        "[AssistantRouter] INFO: enrich-item user=%s family=%s name=%s",
        current_user.id,
        current_family_id,
        body.name,
    )
    result = await ItemEnrichService().enrich_draft(
        name=body.name,
        brand=body.brand,
        category_name=body.category_name,
        specification=body.specification,
        existing_notes=body.existing_notes,
    )
    return ResponseSchema(
        code=200,
        message="success",
        data=EnrichItemDraftResponse(
            notes=result.get("notes") or "",
            search_aliases=result.get("search_aliases") or [],
        ),
    )
