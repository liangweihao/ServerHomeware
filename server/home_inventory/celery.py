import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'home_inventory.settings')

app = Celery('home_inventory')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
