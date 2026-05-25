"""
FastAPI 应用入口
"""
import logging

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.staticfiles import StaticFiles
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from app.api.router import api_router
from app.config import settings
from app.core.database import init_db
from app.core.exceptions import AppException
from app.core.limiter import limiter, rate_limit_exceeded_handler, RateLimitExceeded, SLOWAPI_AVAILABLE
from app.core.middleware import RequestLogMiddleware, setup_cors, setup_cleanup
from app.core.logger import setup_logging
from app.services.upload_service import check_pil_availability

# 配置日志
setup_logging()
logger = logging.getLogger(__name__)

# 检查 PIL 可用性（在日志配置之后调用）
check_pil_availability()

# 创建 FastAPI 应用实例
app = FastAPI(
    title=settings.APP_NAME,
    description="HomeStock 家庭物品管理系统 API",
    version=settings.VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
)

# 配置 CORS
setup_cors(app)

# 配置响应清理中间件（放在所有中间件之前）
setup_cleanup(app)

# 注册限流中间件（如果 slowapi 可用）
if SLOWAPI_AVAILABLE and limiter and rate_limit_exceeded_handler and RateLimitExceeded:
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)
else:
    logger.warning("slowapi 不可用，限流功能已禁用")

# 注册请求日志中间件
app.add_middleware(RequestLogMiddleware)

# 注册路由
app.include_router(api_router, prefix=settings.API_PREFIX)

# 静态文件服务
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")


@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    """自定义应用异常处理器"""
    logger.error(f"应用异常 - 路径: {request.url.path}, 异常: {exc}")
    return JSONResponse(
        status_code=exc.code,
        content={"code": exc.code, "message": exc.message, "data": None}
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """请求参数验证异常处理器"""
    logger.error(f"验证异常 - 路径: {request.url.path}, 异常: {exc}")
    return JSONResponse(
        status_code=400,
        content={"code": 400, "message": "请求参数验证失败", "data": None}
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """全局异常处理器"""
    logger.error(f"全局异常 - 路径: {request.url.path}, 异常: {exc}")
    return JSONResponse(
        status_code=500,
        content={"code": 500, "message": "服务器内部错误", "data": None}
    )


@app.on_event("startup")
async def startup_event():
    """应用启动时执行"""
    logger.info("应用启动中...")
    try:
        await init_db()
        logger.info("数据库初始化成功")
    except Exception as e:
        logger.error(f"数据库初始化失败: {e}")


@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时执行"""
    logger.info("应用关闭中...")


@app.get("/", tags=["health"])
async def health_check():
    """健康检查接口"""
    return {"status": "ok", "service": settings.APP_NAME}
