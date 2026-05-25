"""
配置管理模块
使用 pydantic-settings 从环境变量读取配置，支持 .env 文件
"""
import os
from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """应用配置类"""
    
    # App
    APP_NAME: str = "HomeStock"
    APP_ENV: str = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"
    API_PREFIX: str = "/api/v1"
    VERSION: str = "1.0.0"
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]
    
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:password@localhost:5432/homestock"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # JWT
    JWT_SECRET_KEY: str = "your-secret-key-change-in-production-must-be-at-least-32-characters"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # File Upload
    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE_MB: int = 10
    
    # Image Processing
    MAX_IMAGE_WIDTH: int = 1080
    IMAGE_QUALITY: int = 85
    
    # Rate Limit
    RATE_LIMIT_STORAGE_URL: str = "redis://localhost:6379/1"
    LOGIN_RATE_LIMIT: str = "10/minute"
    REGISTER_RATE_LIMIT: str = "5/hour"
    DEFAULT_RATE_LIMIT: str = "60/minute"
    UPLOAD_RATE_LIMIT: str = "20/minute"
    
    # FCM
    FCM_SERVER_KEY: str = ""
    
    @property
    def DATABASE_TYPE(self) -> str:
        """获取数据库类型"""
        if self.DATABASE_URL.startswith("sqlite"):
            return "sqlite"
        elif self.DATABASE_URL.startswith("postgresql"):
            return "postgresql"
        else:
            return "unknown"
    
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


# 检查是否设置了 ENV_FILE 环境变量
env_file = os.environ.get("ENV_FILE", ".env")

# 全局配置实例
settings = Settings(_env_file=env_file)
