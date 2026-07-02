"""
实时广播模块 — 向家庭 WebSocket 连接推送数据变更事件
"""
import asyncio
import logging
from typing import Any, Dict, Optional

from app.services.websocket_manager import websocket_manager

logger = logging.getLogger(__name__)


def broadcast_family_event(
    family_id: int,
    event: str,
    data: Optional[Dict[str, Any]] = None,
) -> None:
    """
    向同家庭所有 WebSocket 连接广播（fire-and-forget）

    :param family_id: 家庭 ID
    :param event: 事件名（items_changed / usage_changed / alerts_changed）
    :param data: 事件载荷
    """
    if not family_id:
        return

    payload = data or {}
    try:
        loop = asyncio.get_running_loop()
        loop.create_task(websocket_manager.broadcast(family_id, event, payload))
        logger.info(
            "INFO: WebSocket 广播 event=%s family_id=%s payload=%s",
            event,
            family_id,
            payload,
        )
    except RuntimeError:
        logger.warning(
            "WARN: broadcast_family_event 无运行中事件循环 event=%s family_id=%s",
            event,
            family_id,
        )
    except Exception as exc:
        logger.warning(
            "WARN: broadcast_family_event 失败 event=%s family_id=%s error=%s",
            event,
            family_id,
            exc,
        )
