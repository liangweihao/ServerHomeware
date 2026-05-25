"""
WebSocket 管理器模块
管理 WebSocket 连接和实时通知广播
"""
import asyncio
import logging
from datetime import datetime
from typing import Dict, List

from fastapi import WebSocket

logger = logging.getLogger(__name__)


class WebSocketManager:
    """WebSocket 连接管理器"""

    def __init__(self):
        # family_id -> list of WebSocket connections
        self.active_connections: Dict[int, List[WebSocket]] = {}
        # 心跳超时时间（秒）
        self.ping_interval = 30
        self.ping_timeout = 60

    async def connect(self, websocket: WebSocket, family_id: int):
        """
        建立连接
        :param websocket: WebSocket 对象
        :param family_id: 家庭ID
        """
        await websocket.accept()

        if family_id not in self.active_connections:
            self.active_connections[family_id] = []

        self.active_connections[family_id].append(websocket)
        logger.info(f"WebSocket 连接建立: 家庭 {family_id}, 连接数: {len(self.active_connections[family_id])}")

        # 启动心跳检测
        asyncio.create_task(self._ping_loop(websocket, family_id))

    def disconnect(self, websocket: WebSocket, family_id: int):
        """
        断开连接
        :param websocket: WebSocket 对象
        :param family_id: 家庭ID
        """
        if family_id in self.active_connections:
            try:
                self.active_connections[family_id].remove(websocket)
                logger.info(f"WebSocket 连接断开: 家庭 {family_id}, 连接数: {len(self.active_connections[family_id])}")

                # 如果没有连接了，清理键
                if not self.active_connections[family_id]:
                    del self.active_connections[family_id]
            except ValueError:
                pass

    async def broadcast(self, family_id: int, event: str, data: Dict):
        """
        向同家庭所有连接广播消息
        :param family_id: 家庭ID
        :param event: 事件类型
        :param data: 事件数据
        """
        if family_id not in self.active_connections:
            return

        message = {
            "event": event,
            "data": data,
            "timestamp": datetime.utcnow().isoformat()
        }

        disconnected = []

        for connection in self.active_connections[family_id]:
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.warning(f"广播消息失败: {e}")
                disconnected.append(connection)

        # 移除断开的连接
        for conn in disconnected:
            self.disconnect(conn, family_id)

    async def send_personal_message(self, websocket: WebSocket, event: str, data: Dict):
        """
        发送个人消息
        :param websocket: WebSocket 对象
        :param event: 事件类型
        :param data: 事件数据
        """
        message = {
            "event": event,
            "data": data,
            "timestamp": datetime.utcnow().isoformat()
        }
        await websocket.send_json(message)

    async def _ping_loop(self, websocket: WebSocket, family_id: int):
        """
        心跳检测循环
        :param websocket: WebSocket 对象
        :param family_id: 家庭ID
        """
        while True:
            try:
                await asyncio.wait_for(
                    websocket.send_json({"event": "ping"}),
                    timeout=self.ping_timeout
                )
                await asyncio.sleep(self.ping_interval)
            except asyncio.TimeoutError:
                logger.warning(f"WebSocket 心跳超时，断开连接")
                self.disconnect(websocket, family_id)
                break
            except Exception as e:
                logger.warning(f"心跳检测失败: {e}")
                self.disconnect(websocket, family_id)
                break

    def get_connection_count(self, family_id: int) -> int:
        """
        获取家庭连接数
        :param family_id: 家庭ID
        :return: 连接数
        """
        return len(self.active_connections.get(family_id, []))


# 全局 WebSocket 管理器实例
websocket_manager = WebSocketManager()
