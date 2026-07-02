"""
WebSocket 路由模块
定义 WebSocket 实时通知接口
"""
import logging

from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect

from app.core.database import async_session_maker
from app.core.security import decode_token
from app.models.user import User
from app.repositories.user_repo import UserRepository
from app.services.websocket_manager import websocket_manager

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ws", tags=["websocket"])


@router.websocket("/notifications")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...),
):
    """
    WebSocket 实时通知接口

    - token: 用户登录 token
    - 连接后自动加入当前家庭的通知组
    """
    current_user = await _validate_user(token)

    if not current_user:
        logger.warning("WARN: WebSocket 鉴权失败，拒绝连接")
        await websocket.close(code=1008)
        return

    family_id = current_user.current_family_id

    if not family_id:
        logger.warning(
            "WARN: WebSocket 用户未加入家庭 user_id=%s，拒绝连接",
            current_user.id,
        )
        await websocket.close(code=1008)
        return

    try:
        await websocket_manager.connect(websocket, family_id)
        logger.info(
            "INFO: WebSocket 握手成功 user_id=%s family_id=%s",
            current_user.id,
            family_id,
        )

        while True:
            data = await websocket.receive_json()

            if data.get("event") == "pong":
                continue

    except WebSocketDisconnect:
        websocket_manager.disconnect(websocket, family_id)
        logger.info(
            "INFO: WebSocket 正常断开 family_id=%s",
            family_id,
        )
    except Exception as exc:
        websocket_manager.disconnect(websocket, family_id)
        logger.warning(
            "WARN: WebSocket 异常断开 family_id=%s error=%s",
            family_id,
            exc,
        )


async def _validate_user(token: str) -> User | None:
    """
    验证用户 token
    :param token: JWT 令牌
    :return: 用户对象，验证失败返回 None
    """
    if not token:
        return None

    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        return None

    user_id = payload.get("user_id")
    if not user_id:
        return None

    async with async_session_maker() as db:
        user_repo = UserRepository(db)
        user = await user_repo.get_by_id(user_id)
        if not user or not user.is_active:
            return None
        return user
