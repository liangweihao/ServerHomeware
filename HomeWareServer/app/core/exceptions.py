"""
自定义异常模块
定义应用中使用的自定义异常类
"""


class AppException(Exception):
    """应用基础异常类"""
    
    def __init__(self, code: int, message: str):
        self.code = code
        self.message = message
        super().__init__(message)


class UnauthorizedException(AppException):
    """未授权异常（401）"""
    
    def __init__(self, message: str = "未授权访问"):
        super().__init__(401, message)


class ForbiddenException(AppException):
    """禁止访问异常（403）"""
    
    def __init__(self, message: str = "禁止访问"):
        super().__init__(403, message)


class NotFoundException(AppException):
    """资源不存在异常（404）"""
    
    def __init__(self, message: str = "资源不存在"):
        super().__init__(404, message)


class ValidationException(AppException):
    """验证失败异常（400）"""
    
    def __init__(self, message: str = "验证失败"):
        super().__init__(400, message)


class ConflictException(AppException):
    """冲突异常（409）"""
    
    def __init__(self, message: str = "资源冲突"):
        super().__init__(409, message)