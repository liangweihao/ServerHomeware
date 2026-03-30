from django.db import models
from apps.users.models import User, Family
from apps.items.models import Item


class SyncRecord(models.Model):
    SYNC_TYPE_CHOICES = [
        ('full', '全量同步'),
        ('incremental', '增量同步'),
    ]

    STATUS_CHOICES = [
        ('pending', '待处理'),
        ('processing', '处理中'),
        ('completed', '已完成'),
        ('failed', '失败'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sync_records', verbose_name='用户')
    family = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='sync_records', verbose_name='家庭')
    sync_type = models.CharField(max_length=20, choices=SYNC_TYPE_CHOICES, default='incremental', verbose_name='同步类型')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name='状态')
    last_sync_timestamp = models.DateTimeField(blank=True, null=True, verbose_name='上次同步时间')
    current_sync_timestamp = models.DateTimeField(auto_now_add=True, verbose_name='当前同步时间')
    items_count = models.IntegerField(default=0, verbose_name='同步物品数')
    error_message = models.TextField(blank=True, null=True, verbose_name='错误信息')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    completed_at = models.DateTimeField(blank=True, null=True, verbose_name='完成时间')

    class Meta:
        db_table = 'sync_records'
        verbose_name = '同步记录'
        verbose_name_plural = '同步记录'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'family', 'created_at']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f'{self.user.username} - {self.family.name} - {self.get_status_display()}'


class SyncConflict(models.Model):
    CONFLICT_TYPE_CHOICES = [
        ('update', '更新冲突'),
        ('delete', '删除冲突'),
        ('version', '版本冲突'),
    ]

    RESOLUTION_CHOICES = [
        ('server', '以服务器为准'),
        ('client', '以客户端为准'),
        ('manual', '手动处理'),
    ]

    sync_record = models.ForeignKey(SyncRecord, on_delete=models.CASCADE, related_name='conflicts', verbose_name='同步记录')
    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='sync_conflicts', verbose_name='物品')
    conflict_type = models.CharField(max_length=20, choices=CONFLICT_TYPE_CHOICES, verbose_name='冲突类型')
    server_data = models.JSONField(verbose_name='服务器数据')
    client_data = models.JSONField(verbose_name='客户端数据')
    resolution = models.CharField(max_length=20, choices=RESOLUTION_CHOICES, blank=True, null=True, verbose_name='解决方案')
    is_resolved = models.BooleanField(default=False, verbose_name='已解决')
    resolved_at = models.DateTimeField(blank=True, null=True, verbose_name='解决时间')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')

    class Meta:
        db_table = 'sync_conflicts'
        verbose_name = '同步冲突'
        verbose_name_plural = '同步冲突'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['sync_record', 'item']),
            models.Index(fields=['is_resolved']),
        ]

    def __str__(self):
        return f'{self.item.name} - {self.get_conflict_type_display()}'
