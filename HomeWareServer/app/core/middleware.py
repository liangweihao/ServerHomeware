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
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.exceptions import AppException

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class RequestLogMiddleware(BaseHTTPMiddleware):
    """请求日志中间件"""
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.time()
        response = await call_next(request)
        process_time = time.time() - start_time
        
        logger.info(
            f"请求日志 - 方法: {request.method}, "
            f"路径: {request.url.path}, "
            f"状态码: {response.status_code}, "
            f"耗时: {process_time:.4f}s"
        )
        
        return response


class ResponseCleanupMiddleware(BaseHTTPMiddleware):
    """响应清理中间件
    移除响应内容开头可能存在的多余换行符
    """
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)
        
        # 读取响应内容
        body = b""
        async for chunk in response.body_iterator:
            body += chunk
        
        # 如果开头有换行符，移除它们
        cleaned_body = body.lstrip(b'\n\r')
        
        # 创建新的响应，移除 Content-Length 让服务器重新计算
        headers = dict(response.headers)
        headers.pop('content-length', None)  # 移除旧的长度，让服务器重新计算
        
        return Response(
            content=cleaned_body,
            status_code=response.status_code,
            headers=headers,
            media_type=response.media_type
        )


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