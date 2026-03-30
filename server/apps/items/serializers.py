from rest_framework import serializers
from .models import Category, Location, Item


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'icon', 'color', 'family', 'created_at']
        read_only_fields = ['id', 'created_at']


class LocationSerializer(serializers.ModelSerializer):
    parent_name = serializers.CharField(source='parent.name', read_only=True)

    class Meta:
        model = Location
        fields = ['id', 'name', 'description', 'parent', 'parent_name', 'family', 'created_at']
        read_only_fields = ['id', 'created_at']


class ItemSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    location_name = serializers.CharField(source='location.name', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)
    is_expired = serializers.BooleanField(read_only=True)
    is_low_stock = serializers.BooleanField(read_only=True)
    image_url = serializers.ImageField(source='image', read_only=True)

    class Meta:
        model = Item
        fields = [
            'id', 'name', 'description', 'category', 'category_name', 
            'location', 'location_name', 'quantity', 'unit', 'expiry_date',
            'purchase_date', 'price', 'image', 'image_url', 'barcode',
            'family', 'created_by', 'created_by_username', 'is_expired',
            'is_low_stock', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at', 'is_expired', 'is_low_stock']


class ItemCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = [
            'name', 'description', 'category', 'location', 'quantity', 
            'unit', 'expiry_date', 'purchase_date', 'price', 'image', 'barcode', 'family'
        ]

    def create(self, validated_data):
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)


class ItemUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = [
            'name', 'description', 'category', 'location', 'quantity', 
            'unit', 'expiry_date', 'purchase_date', 'price', 'image', 'barcode'
        ]
