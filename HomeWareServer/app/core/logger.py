"""
日志配置模块
提供 JSON 格式日志、文件轮转、多输出支持
"""
import logging
import os
import sys
from datetime import time
from logging.handlers import TimedRotatingFileHandler
from pythonjsonlogger import jsonlogger

from app.config import settings


def setup_logging() -> None:
    """配置应用日志系统"""
    # 获取日志级别
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

    # 创建 root logger
    logger = logging.getLogger()
    logger.setLevel(log_level)

    # 清除已有的 handlers
    logger.handlers = []

    # 日志格式
    json_formatter = jsonlogger.JsonFormatter(
        "%(asctime)s %(name)s %(levelname)s %(message)s",
        rename_fields={"levelname": "level", "asctime": "timestamp"},
        timestamp=True
    )

    # 输出到 stderr，避免干扰 HTTP 响应
    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setFormatter(json_formatter)
    logger.addHandler(console_handler)

    # 输出到文件（如果配置了日志目录）
    log_dir = os.path.join(settings.UPLOAD_DIR, "..", "logs")
    log_dir = os.path.abspath(log_dir)

    if not os.path.exists(log_dir):
        os.makedirs(log_dir, exist_ok=True)

    log_file = os.path.join(log_dir, "app.log")

    # 每天一个文件，保留 30 天
    file_handler = TimedRotatingFileHandler(
        log_file,
        when="midnight",
        interval=1,
        backupCount=30,
        encoding="utf-8"
    )
    file_handler.setFormatter(json_formatter)
    logger.addHandler(file_handler)

    # 记录初始化日志
    logger.info("Log system initialized", extra={
        "environment": settings.APP_ENV,
        "log_level": settings.LOG_LEVEL
    })
