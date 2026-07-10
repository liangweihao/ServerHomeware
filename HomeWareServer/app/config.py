"""
配置管理模块
使用 pydantic-settings 从环境变量读取配置，支持 .env 文件
"""
import os
import warnings
from typing import Optional

from pydantic import field_validator, model_validator
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

    # CORS（环境变量用逗号分隔字符串，如 "http://a.com,http://b.com" 或 "*"）
    CORS_ORIGINS: str = "*"

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:password@localhost:5432/homestock"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # JWT
    JWT_SECRET_KEY: str = "your-secret-key-change-in-production-must-be-at-least-32-characters"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 天
    REFRESH_TOKEN_EXPIRE_DAYS: int = 90        # 90 天未使用才需重新登录

    # File Upload
    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE_MB: int = 10

    # Image Processing（720px + WebP 75% ≈ 60-100KB/张，50G 可存约 50 万张）
    MAX_IMAGE_WIDTH: int = 720
    IMAGE_QUALITY: int = 75

    # Rate Limit
    RATE_LIMIT_STORAGE_URL: str = "redis://localhost:6379/1"
    LOGIN_RATE_LIMIT: str = "10/minute"
    REGISTER_RATE_LIMIT: str = "5/hour"
    DEFAULT_RATE_LIMIT: str = "60/minute"
    UPLOAD_RATE_LIMIT: str = "20/minute"

    # FCM
    FCM_SERVER_KEY: str = ""

    # DeepSeek LLM（AI 助手功能）
    # 在 .env 文件中填写：DEEPSEEK_API_KEY=sk-xxxxxxxx
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com"
    DEEPSEEK_MODEL: str = "deepseek-chat"
    # 单次对话最大历史轮数（节省 token）
    DEEPSEEK_MAX_HISTORY_TURNS: int = 6
    # LLM 请求超时秒数
    DEEPSEEK_TIMEOUT_SECONDS: int = 30

    # ========== Validators ==========

    @field_validator("APP_ENV")
    @classmethod
    def validate_app_env(cls, v: str) -> str:
        allowed = {"development", "staging", "production"}
        if v not in allowed:
            raise ValueError(f"APP_ENV must be one of {allowed}, got '{v}'")
        return v

    @field_validator("LOG_LEVEL")
    @classmethod
    def validate_log_level(cls, v: str) -> str:
        allowed = {"DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"}
        v_upper = v.upper()
        if v_upper not in allowed:
            raise ValueError(f"LOG_LEVEL must be one of {allowed}, got '{v}'")
        return v_upper

    @field_validator("DATABASE_URL")
    @classmethod
    def validate_database_url(cls, v: str) -> str:
        valid_schemes = ("sqlite", "sqlite+aiosqlite", "postgresql", "postgresql+asyncpg")
        if not any(v.startswith(s + "://") for s in valid_schemes):
            raise ValueError(
                f"DATABASE_URL 必须以 {valid_schemes} 之一开头，当前值: {v[:50]}..."
            )
        return v

    @field_validator("JWT_SECRET_KEY")
    @classmethod
    def validate_jwt_secret_key(cls, v: str) -> str:
        if len(v) < 16:
            raise ValueError(f"JWT_SECRET_KEY 至少需要 16 个字符，当前 {len(v)} 个")
        return v

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_jwt_algorithm(cls, v: str) -> str:
        allowed = {"HS256", "HS384", "HS512", "RS256", "RS384", "RS512", "ES256"}
        if v not in allowed:
            raise ValueError(f"JWT_ALGORITHM must be one of {allowed}, got '{v}'")
        return v

    @field_validator("REDIS_URL")
    @classmethod
    def validate_redis_url(cls, v: str) -> str:
        if not v.startswith(("redis://", "rediss://")):
            raise ValueError(f"REDIS_URL 必须以 redis:// 或 rediss:// 开头，当前值: {v}")
        return v

    @field_validator("UPLOAD_DIR")
    @classmethod
    def validate_upload_dir(cls, v: str) -> str:
        # 标准化并转为绝对路径，避免进程 cwd 变化导致文件检测/静态服务路径不一致
        normalized = os.path.normpath(v)
        if not os.path.isabs(normalized):
            normalized = os.path.abspath(normalized)
        try:
            os.makedirs(normalized, exist_ok=True)
        except OSError as e:
            raise ValueError(f"无法创建 UPLOAD_DIR '{normalized}': {e}")
        return normalized

    @field_validator("MAX_FILE_SIZE_MB")
    @classmethod
    def validate_max_file_size(cls, v: int) -> int:
        if v <= 0:
            raise ValueError(f"MAX_FILE_SIZE_MB 必须 > 0，当前值: {v}")
        if v > 100:
            raise ValueError(f"MAX_FILE_SIZE_MB 不能超过 100MB，当前值: {v}")
        return v

    @field_validator("MAX_IMAGE_WIDTH")
    @classmethod
    def validate_max_image_width(cls, v: int) -> int:
        if v <= 0:
            raise ValueError(f"MAX_IMAGE_WIDTH 必须 > 0，当前值: {v}")
        if v > 4096:
            raise ValueError(f"MAX_IMAGE_WIDTH 不能超过 4096px，当前值: {v}")
        return v

    @field_validator("IMAGE_QUALITY")
    @classmethod
    def validate_image_quality(cls, v: int) -> int:
        if v < 1 or v > 100:
            raise ValueError(f"IMAGE_QUALITY 必须在 1-100 之间，当前值: {v}")
        return v

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        """生产环境安全检查"""
        if self.APP_ENV == "production":
            # JWT 密钥不能使用默认值
            if "change-in-production" in self.JWT_SECRET_KEY or "your-secret-key" in self.JWT_SECRET_KEY:
                raise ValueError(
                    "生产环境必须设置强 JWT_SECRET_KEY，不能使用默认值"
                )
            if len(self.JWT_SECRET_KEY) < 32:
                raise ValueError(
                    f"生产环境 JWT_SECRET_KEY 至少 32 个字符，当前 {len(self.JWT_SECRET_KEY)}"
                )
            # 生产不应开启 DEBUG
            if self.DEBUG:
                raise ValueError("生产环境 DEBUG 必须设为 false")
            # CORS 不能为通配符
            if self.CORS_ORIGINS.strip() == "*":
                warnings.warn(
                    "生产环境 CORS_ORIGINS 设为 '*' 存在安全风险，建议指定具体域名",
                    RuntimeWarning,
                )
        return self

    # ========== Computed Properties ==========

    @property
    def DATABASE_TYPE(self) -> str:
        """获取数据库类型"""
        if self.DATABASE_URL.startswith("sqlite"):
            return "sqlite"
        elif self.DATABASE_URL.startswith("postgresql"):
            return "postgresql"
        else:
            return "unknown"

    @property
    def is_production(self) -> bool:
        return self.APP_ENV == "production"

    @property
    def CORS_ORIGIN_LIST(self) -> list[str]:
        """将逗号分隔字符串转为 list（给 FastAPI CORSMiddleware 用）"""
        if self.CORS_ORIGINS.strip() == "*":
            return ["*"]
        return [s.strip() for s in self.CORS_ORIGINS.split(",") if s.strip()]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",  # 忽略 env 文件中已废弃的旧字段
    )


# 检查是否设置了 ENV_FILE 环境变量（默认读取 HomeWareServer/.env）
env_file = os.environ.get("ENV_FILE", ".env")

# 全局配置实例
settings = Settings(_env_file=env_file)
