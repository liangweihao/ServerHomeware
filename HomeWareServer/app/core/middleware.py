"""
中间件模块
提供请求日志、CORS、全局异常处理等中间件
"""
import logging
import time
from typing import Callable

from fastapi import Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from app.core.exceptions import AppException

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class RequestLogMiddleware:
    """请求日志中间件（纯 ASGI，兼容 WebSocket）"""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        # WebSocket / lifespan 等非 HTTP 请求直接透传
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        start_time = time.time()
        method = scope.get("method", "")
        path = scope.get("path", "")

        async def send_wrapper(message):
            if message["type"] == "http.response.start":
                process_time = time.time() - start_time
                status = message.get("status", 0)
                logger.info(
                    "请求日志 - 方法: %s, 路径: %s, 状态码: %s, 耗时: %.4fs",
                    method,
                    path,
                    status,
                    process_time,
                )
            await send(message)

        await self.app(scope, receive, send_wrapper)


class ResponseCleanupMiddleware:
    """响应清理中间件（纯 ASGI，兼容 WebSocket）

    移除响应内容开头可能存在的多余换行符
    """

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        status_code = 200
        headers: list = []
        body_chunks: list[bytes] = []
        started = False

        async def send_wrapper(message):
            nonlocal status_code, headers, started

            if message["type"] == "http.response.start":
                started = True
                status_code = message.get("status", 200)
                headers = list(message.get("headers", []))
                return

            if message["type"] == "http.response.body":
                body_chunks.append(message.get("body", b""))
                if message.get("more_body", False):
                    return

                cleaned_body = b"".join(body_chunks).lstrip(b"\n\r")
                new_headers = [
                    (key, value)
                    for key, value in headers
                    if key.lower() != b"content-length"
                ]
                await send(
                    {
                        "type": "http.response.start",
                        "status": status_code,
                        "headers": new_headers,
                    }
                )
                await send(
                    {
                        "type": "http.response.body",
                        "body": cleaned_body,
                        "more_body": False,
                    }
                )
                return

            await send(message)

        await self.app(scope, receive, send_wrapper)


async def global_exception_handler(request: Request, exc: Exception):
    """全局异常处理器"""
    logger.error(f"全局异常 - 路径: {request.url.path}, 异常: {exc}")

    if isinstance(exc, AppException):
        return Response(
            content=f'{{"code": {exc.code}, "message": "{exc.message}", "data": null}}',
            status_code=exc.code,
            media_type="application/json"
        )

    if isinstance(exc, RequestValidationError):
        return Response(
            content=f'{{"code": 400, "message": "请求参数验证失败", "data": null}}',
            status_code=400,
            media_type="application/json"
        )

    return Response(
        content='{"code": 500, "message": "服务器内部错误", "data": null}',
        status_code=500,
        media_type="application/json"
    )


def setup_cors(app):
    """配置 CORS 中间件"""
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


def setup_cleanup(app):
    """配置响应清理中间件"""
    app.add_middleware(ResponseCleanupMiddleware)


def setup_request_log(app):
    """配置请求日志中间件"""
    app.add_middleware(RequestLogMiddleware)
