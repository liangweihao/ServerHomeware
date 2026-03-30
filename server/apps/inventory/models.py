from django.db import models
from apps.items.models import Item


class InventoryAlert(models.Model):
    ALERT_TYPE_CHOICES = [
        ('low_stock', '库存不足'),
        ('expired', '已过期'),
        ('expiring_soon', '即将过期'),
    ]

    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='alerts', verbose_name='物品')
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPE_CHOICES, verbose_name='预警类型')
    threshold = models.IntegerField(blank=True, null=True, verbose_name='阈值')
    message = models.TextField(verbose_name='预警信息')
    is_resolved = models.BooleanField(default=False, verbose_name='已解决')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    resolved_at = models.DateTimeField(blank=True, null=True, verbose_name='解决时间')

    class Meta:
        db_table = 'inventory_alerts'
        verbose_name = '库存预警'
        verbose_name_plural = '库存预警'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['item', 'alert_type']),
            models.Index(fields=['is_resolved']),
        ]

    def __str__(self):
        return f'{self.item.name} - {self.get_alert_type_display()}'


class InventoryLog(models.Model):
    ACTION_CHOICES = [
        ('add', '添加'),
        ('update', '更新'),
        ('delete', '删除'),
        ('consume', '消耗'),
        ('restock', '补货'),
    ]

    item = models.ForeignKey(Item, on_delete=models.CASCADE, related_name='logs', verbose_name='物品')
    action = models.CharField(max_length=20, choices=ACTION_CHOICES, verbose_name='操作类型')
    quantity_before = models.IntegerField(verbose_name='操作前数量')
    quantity_after = models.IntegerField(verbose_name='操作后数量')
    quantity_change = models.IntegerField(verbose_name='数量变化')
    note = models.TextField(blank=True, null=True, verbose_name='备注')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')

    class Meta:
        db_table = 'inventory_logs'
        verbose_name = '库存日志'
        verbose_name_plural = '库存日志'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['item', 'created_at']),
        ]

    def __str__(self):
        return f'{self.item.name} - {self.get_action_display()} ({self.quantity_change})'
