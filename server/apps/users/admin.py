from django.contrib import admin
from .models import User, Family, FamilyMember


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'is_verified', 'created_at']
    list_filter = ['is_verified', 'created_at']
    search_fields = ['username', 'email']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Family)
class FamilyAdmin(admin.ModelAdmin):
    list_display = ['name', 'invite_code', 'created_by', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name', 'invite_code']
    readonly_fields = ['invite_code', 'created_at', 'updated_at']


@admin.register(FamilyMember)
class FamilyMemberAdmin(admin.ModelAdmin):
    list_display = ['user', 'family', 'role', 'joined_at']
    list_filter = ['role', 'joined_at']
    search_fields = ['user__username', 'family__name']
