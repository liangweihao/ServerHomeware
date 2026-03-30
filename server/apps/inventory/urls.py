from django.urls import path
from .views import (
    get_inventory_alerts,
    resolve_alerts,
    get_inventory_report,
    get_purchase_suggestions,
    get_inventory_logs,
    log_inventory_action
)

urlpatterns = [
    path('alert/', get_inventory_alerts, name='inventory-alert'),
    path('alert/resolve/', resolve_alerts, name='resolve-alerts'),
    path('report/', get_inventory_report, name='inventory-report'),
    path('suggestions/', get_purchase_suggestions, name='purchase-suggestions'),
    path('logs/', get_inventory_logs, name='inventory-logs'),
    path('logs/log-action/', log_inventory_action, name='log-inventory-action'),
]
