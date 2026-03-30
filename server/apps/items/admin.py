from django.contrib import admin
from .models import Category, Location, Item


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'family', 'created_at']
    list_filter = ['family', 'created_at']
    search_fields = ['name']


@admin.register(Location)
class LocationAdmin(admin.ModelAdmin):
    list_display = ['name', 'family', 'parent', 'created_at']
    list_filter = ['family', 'created_at']
    search_fields = ['name']


@admin.register(Item)
class ItemAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'location', 'quantity', 'unit', 'expiry_date', 'family', 'created_at']
    list_filter = ['family', 'category', 'location', 'created_at']
    search_fields = ['name', 'description', 'barcode']
    readonly_fields = ['created_at', 'updated_at']
