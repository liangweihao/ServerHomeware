"""
限流配置模块
使用 slowapi 实现 API 限流
"""
from typing import Any, Callable

# 尝试导入 slowapi，如果失败则使用降级模式
try:
    from slowapi import Limiter, _rate_limit_exceeded_handler
    from slowapi.util import get_remote_address
    from slowapi.errors import RateLimitExceeded
    
    SLOWAPI_AVAILABLE = True
    
    from app.config import settings
    
    # 创建限流实例
    limiter = Limiter(
        key_func=get_remote_address,
        storage_uri=settings.RATE_LIMIT_STORAGE_URL,
        default_limits=[settings.DEFAULT_RATE_LIMIT]
    )
    
    # 限流异常处理器
    def rate_limit_exceeded_handler(request: Any, exc: RateLimitExceeded) -> Any:
        """限流异常处理"""
        return _rate_limit_exceeded_handler(request, exc)

except ImportError:
    SLOWAPI_AVAILABLE = False
    limiter = None
    rate_limit_exceeded_handler = None
    RateLimitExceeded = None
    
    # 降级模式：空装饰器
    class MockLimiter:
        def limit(self, *args, **kwargs) -> Callable:
            def decorator(func: Callable) -> Callable:
                return func
            return decorator
    
    limiter = MockLimiter()