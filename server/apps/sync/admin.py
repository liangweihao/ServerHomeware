from django.contrib import admin
from .models import SyncRecord, SyncConflict


@admin.register(SyncRecord)
class SyncRecordAdmin(admin.ModelAdmin):
    list_display = ['user', 'family', 'sync_type', 'status', 'items_count', 'created_at']
    list_filter = ['sync_type', 'status', 'created_at']
    search_fields = ['user__username', 'family__name']
    readonly_fields = ['created_at', 'completed_at']


@admin.register(SyncConflict)
class SyncConflictAdmin(admin.ModelAdmin):
    list_display = ['sync_record', 'item', 'conflict_type', 'resolution', 'is_resolved', 'created_at']
    list_filter = ['conflict_type', 'resolution', 'is_resolved', 'created_at']
    search_fields = ['item__name']
    readonly_fields = ['created_at', 'resolved_at']
