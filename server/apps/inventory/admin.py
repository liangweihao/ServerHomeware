from django.contrib import admin
from .models import InventoryAlert, InventoryLog


@admin.register(InventoryAlert)
class InventoryAlertAdmin(admin.ModelAdmin):
    list_display = ['item', 'alert_type', 'is_resolved', 'created_at']
    list_filter = ['alert_type', 'is_resolved', 'created_at']
    search_fields = ['item__name', 'message']
    readonly_fields = ['created_at', 'resolved_at']


@admin.register(InventoryLog)
class InventoryLogAdmin(admin.ModelAdmin):
    list_display = ['item', 'action', 'quantity_before', 'quantity_after', 'quantity_change', 'created_at']
    list_filter = ['action', 'created_at']
    search_fields = ['item__name', 'note']
    readonly_fields = ['created_at']
