from rest_framework import serializers
from .models import SyncRecord, SyncConflict
from apps.items.serializers import ItemSerializer


class SyncRecordSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    family_name = serializers.CharField(source='family.name', read_only=True)
    sync_type_display = serializers.CharField(source='get_sync_type_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = SyncRecord
        fields = [
            'id', 'user', 'username', 'family', 'family_name', 'sync_type',
            'sync_type_display', 'status', 'status_display', 'last_sync_timestamp',
            'current_sync_timestamp', 'items_count', 'error_message',
            'created_at', 'completed_at'
        ]
        read_only_fields = ['id', 'current_sync_timestamp', 'created_at', 'completed_at']


class SyncConflictSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source='item.name', read_only=True)
    conflict_type_display = serializers.CharField(source='get_conflict_type_display', read_only=True)
    resolution_display = serializers.CharField(source='get_resolution_display', read_only=True)

    class Meta:
        model = SyncConflict
        fields = [
            'id', 'sync_record', 'item', 'item_name', 'conflict_type',
            'conflict_type_display', 'server_data', 'client_data',
            'resolution', 'resolution_display', 'is_resolved',
            'resolved_at', 'created_at'
        ]
        read_only_fields = ['id', 'created_at', 'resolved_at']


class SyncRequestSerializer(serializers.Serializer):
    family_id = serializers.IntegerField()
    sync_type = serializers.ChoiceField(choices=['full', 'incremental'], default='incremental')
    last_sync_timestamp = serializers.DateTimeField(required=False, allow_null=True)


class SyncDataSerializer(serializers.Serializer):
    items = ItemSerializer(many=True, required=False)
    categories = serializers.ListField(required=False)
    locations = serializers.ListField(required=False)
    timestamp = serializers.DateTimeField()


class ConflictResolutionSerializer(serializers.Serializer):
    conflict_id = serializers.IntegerField()
    resolution = serializers.ChoiceField(choices=['server', 'client', 'manual'])
    manual_data = serializers.JSONField(required=False, allow_null=True)
