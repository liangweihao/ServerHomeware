from rest_framework import serializers
from .models import InventoryAlert, InventoryLog
from apps.items.serializers import ItemSerializer


class InventoryAlertSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source='item.name', read_only=True)
    item_details = ItemSerializer(source='item', read_only=True)

    class Meta:
        model = InventoryAlert
        fields = [
            'id', 'item', 'item_name', 'item_details', 'alert_type', 
            'threshold', 'message', 'is_resolved', 'created_at', 'resolved_at'
        ]
        read_only_fields = ['id', 'created_at', 'resolved_at']


class InventoryLogSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source='item.name', read_only=True)
    action_display = serializers.CharField(source='get_action_display', read_only=True)

    class Meta:
        model = InventoryLog
        fields = [
            'id', 'item', 'item_name', 'action', 'action_display',
            'quantity_before', 'quantity_after', 'quantity_change',
            'note', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class InventoryReportSerializer(serializers.Serializer):
    total_items = serializers.IntegerField()
    total_value = serializers.DecimalField(max_digits=12, decimal_places=2)
    category_stats = serializers.ListField()
    location_stats = serializers.ListField()
    low_stock_count = serializers.IntegerField()
    expired_count = serializers.IntegerField()
    expiring_soon_count = serializers.IntegerField()


class PurchaseSuggestionSerializer(serializers.Serializer):
    item_id = serializers.IntegerField()
    item_name = serializers.CharField()
    current_quantity = serializers.IntegerField()
    suggested_quantity = serializers.IntegerField()
    reason = serializers.CharField()
    priority = serializers.CharField()
