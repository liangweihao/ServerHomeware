from django.db import models
from apps.users.models import User, Family


class Category(models.Model):
    name = models.CharField(max_length=50, verbose_name='分类名称')
    family = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='categories', verbose_name='所属家庭')
    icon = models.CharField(max_length=50, blank=True, null=True, verbose_name='图标')
    color = models.CharField(max_length=20, blank=True, null=True, verbose_name='颜色')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')

    class Meta:
        db_table = 'categories'
        verbose_name = '分类'
        verbose_name_plural = '分类'
        unique_together = ('name', 'family')
        ordering = ['name']

    def __str__(self):
        return self.name


class Location(models.Model):
    name = models.CharField(max_length=50, verbose_name='位置名称')
    description = models.TextField(blank=True, null=True, verbose_name='位置描述')
    parent = models.ForeignKey('self', on_delete=models.CASCADE, blank=True, null=True, related_name='children', verbose_name='父位置')
    family = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='locations', verbose_name='所属家庭')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')

    class Meta:
        db_table = 'locations'
        verbose_name = '位置'
        verbose_name_plural = '位置'
        unique_together = ('name', 'family')
        ordering = ['name']

    def __str__(self):
        return self.name


class Item(models.Model):
    name = models.CharField(max_length=100, verbose_name='物品名称')
    description = models.TextField(blank=True, null=True, verbose_name='物品描述')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='items', verbose_name='分类')
    location = models.ForeignKey(Location, on_delete=models.SET_NULL, null=True, blank=True, related_name='items', verbose_name='位置')
    quantity = models.IntegerField(default=1, verbose_name='数量')
    unit = models.CharField(max_length=20, default='个', verbose_name='单位')
    expiry_date = models.DateField(blank=True, null=True, verbose_name='过期日期')
    purchase_date = models.DateField(blank=True, null=True, verbose_name='购买日期')
    price = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True, verbose_name='价格')
    image = models.ImageField(upload_to='items/', blank=True, null=True, verbose_name='图片')
    barcode = models.CharField(max_length=100, blank=True, null=True, verbose_name='条形码')
    family = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='items', verbose_name='所属家庭')
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_items', verbose_name='创建者')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')

    class Meta:
        db_table = 'items'
        verbose_name = '物品'
        verbose_name_plural = '物品'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['family', 'category']),
            models.Index(fields=['family', 'location']),
            models.Index(fields=['expiry_date']),
            models.Index(fields=['name']),
        ]

    def __str__(self):
        return self.name

    @property
    def is_expired(self):
        from django.utils import timezone
        if self.expiry_date:
            return self.expiry_date < timezone.now().date()
        return False

    @property
    def is_low_stock(self):
        return self.quantity <= 3
