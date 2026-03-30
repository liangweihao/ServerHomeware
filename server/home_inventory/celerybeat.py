from celery.schedules import crontab

CELERY_BEAT_SCHEDULE = {
    'check-inventory-alerts': {
        'task': 'apps.inventory.tasks.check_inventory_alerts',
        'schedule': crontab(hour=0, minute=0),
    },
    'cleanup-old-alerts': {
        'task': 'apps.inventory.tasks.cleanup_old_alerts',
        'schedule': crontab(hour=2, minute=0),
    },
    'send-daily-inventory-summary': {
        'task': 'apps.inventory.tasks.send_daily_inventory_summary',
        'schedule': crontab(hour=8, minute=0),
    },
}
