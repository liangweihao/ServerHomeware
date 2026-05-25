"""
Celery 应用配置
"""
from celery import Celery

from app.config import settings

celery = Celery(
    "tasks",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

celery.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='Asia/Shanghai',
    enable_utc=True,
)

# 导入 Celery Beat 定时调度配置
celery.config_from_object('app.tasks.celeryconfig')