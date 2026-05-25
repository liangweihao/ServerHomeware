"""
WebSocket 路由模块
定义 WebSocket 实时通知接口
"""
from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect

from app.core.database import get_db
from app.core.security import decode_token
from app.models.user import User
from app.repositories.user_repo import UserRepository
from app.services.websocket_manager import websocket_manager

router = APIRouter(prefix="/ws", tags=["websocket"])


@router.websocket("/notifications")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...)
):
    """
    WebSocket 实时通知接口
    
    - token: 用户登录token
    - 连接后自动加入当前家庭的通知组
    """
    # 验证用户
    current_user = await _validate_user(token)
    
    if not current_user:
        await websocket.close(code=1008)
        return

    # 获取用户当前家庭
    family_id = current_user.current_family_id

    if not family_id:
        await websocket.close(code=1008)
        return

    try:
        # 建立连接
        await websocket_manager.connect(websocket, family_id)
        
        # 保持连接
        while True:
            # 接收消息（用于心跳响应等）
            data = await websocket.receive_json()
            
            # 处理心跳响应
            if data.get("event") == "pong":
                continue
            
            # 其他消息可在此处理
            # ...

    except WebSocketDisconnect:
        # 断开连接
        websocket_manager.disconnect(websocket, family_id)
    except Exception as e:
        # 其他异常
        websocket_manager.disconnect(websocket, family_id)


async def _validate_user(token: str) -> User | None:
    """
    验证用户 token
    :param token: JWT令牌
    :return: 用户对象，如果验证失败返回 None
    """
    if not token:
        return None
    
    # 解码令牌
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        return None
    
    user_id = payload.get("user_id")
    if not user_id:
        return None
    
    # 获取用户
    async for db in get_db():
        user_repo = UserRepository(db)
        user = await user_repo.get_by_id(user_id)
        if not user or not user.is_active:
            return None
        return user
    
    return None
