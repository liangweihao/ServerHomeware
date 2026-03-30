from celery import shared_task
from django.utils import timezone
from django.db.models import Q
from .models import InventoryAlert
from apps.items.models import Item


@shared_task
def check_inventory_alerts():
    today = timezone.now().date()
    seven_days_later = today + timezone.timedelta(days=7)
    
    low_stock_threshold = 3
    
    low_stock_items = Item.objects.filter(quantity__lte=low_stock_threshold)
    for item in low_stock_items:
        alert, created = InventoryAlert.objects.get_or_create(
            item=item,
            alert_type='low_stock',
            is_resolved=False,
            defaults={
                'threshold': low_stock_threshold,
                'message': f'物品 {item.name} 库存不足，当前数量: {item.quantity}'
            }
        )
    
    expired_items = Item.objects.filter(expiry_date__lt=today)
    for item in expired_items:
        alert, created = InventoryAlert.objects.get_or_create(
            item=item,
            alert_type='expired',
            is_resolved=False,
            defaults={
                'message': f'物品 {item.name} 已过期，过期日期: {item.expiry_date}'
            }
        )
    
    expiring_soon_items = Item.objects.filter(
        expiry_date__gte=today,
        expiry_date__lte=seven_days_later
    )
    for item in expiring_soon_items:
        alert, created = InventoryAlert.objects.get_or_create(
            item=item,
            alert_type='expiring_soon',
            is_resolved=False,
            defaults={
                'message': f'物品 {item.name} 即将过期，过期日期: {item.expiry_date}'
            }
        )
    
    return {
        'low_stock_count': low_stock_items.count(),
        'expired_count': expired_items.count(),
        'expiring_soon_count': expiring_soon_items.count()
    }


@shared_task
def cleanup_old_alerts():
    thirty_days_ago = timezone.now() - timezone.timedelta(days=30)
    
    deleted_count = InventoryAlert.objects.filter(
        is_resolved=True,
        resolved_at__lt=thirty_days_ago
    ).delete()[0]
    
    return {'deleted_count': deleted_count}


@shared_task
def send_daily_inventory_summary():
    from apps.users.models import Family
    
    families = Family.objects.all()
    summaries = []
    
    for family in families:
        items = Item.objects.filter(family=family)
        low_stock_count = items.filter(quantity__lte=3).count()
        expired_count = items.filter(expiry_date__lt=timezone.now().date()).count()
        
        summary = {
            'family_id': family.id,
            'family_name': family.name,
            'total_items': items.count(),
            'low_stock_count': low_stock_count,
            'expired_count': expired_count
        }
        summaries.append(summary)
    
    return summaries
