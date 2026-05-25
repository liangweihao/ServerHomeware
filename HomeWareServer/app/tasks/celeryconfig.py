"""
Celery Beat 配置模块
定义定时任务调度配置
"""
from celery.schedules import crontab

# Celery Beat 定时调度配置
CELERYBEAT_SCHEDULE = {
    # 每天早上8:00检查即将过期物品
    'check-expiry-daily': {
        'task': 'app.tasks.scheduled_tasks.check_expiry',
        'schedule': crontab(hour=8, minute=0),
    },
    # 每天凌晨1:00自动将已过期物品状态改为2
    'auto-expire-items-daily': {
        'task': 'app.tasks.scheduled_tasks.auto_expire_items',
        'schedule': crontab(hour=1, minute=0),
    },
    # 每天凌晨2:00更新消耗预测（预留接口）
    'update-predictions-daily': {
        'task': 'app.tasks.scheduled_tasks.update_predictions',
        'schedule': crontab(hour=2, minute=0),
    },
    # 每天早上9:00自动生成购物推荐
    'generate-shopping-suggestions-daily': {
        'task': 'app.tasks.scheduled_tasks.generate_shopping_suggestions',
        'schedule': crontab(hour=9, minute=0),
    },
    # 每周日凌晨3:00清理30天前的通知记录
    'clean-old-notifications-weekly': {
        'task': 'app.tasks.scheduled_tasks.clean_old_notifications',
        'schedule': crontab(hour=3, minute=0, day_of_week=0),
    },
}
