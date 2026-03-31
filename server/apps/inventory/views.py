from rest_framework.decorators import api_view, permission_classes
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django.db.models import Sum, Count, Q, F
from django.db.models.functions import Coalesce
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import InventoryAlert, InventoryLog
from .serializers import (
    InventoryAlertSerializer,
    InventoryLogSerializer,
    InventoryReportSerializer,
    PurchaseSuggestionSerializer
)
from apps.items.models import Item


@extend_schema(
    summary='获取库存预警',
    parameters=[
        OpenApiParameter(name='family_id', type=int, description='家庭ID'),
        OpenApiParameter(name='alert_type', type=str, description='预警类型: low_stock, expired, expiring_soon'),
        OpenApiParameter(name='is_resolved', type=bool, description='是否已解决')
    ],
    responses={200: InventoryAlertSerializer(many=True)}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_inventory_alerts(request):
    family_id = request.query_params.get('family_id')
    alert_type = request.query_params.get('alert_type')
    is_resolved = request.query_params.get('is_resolved')
    
    queryset = InventoryAlert.objects.select_related('item').filter(
        item__family__members__user=request.user
    )
    
    if family_id:
        queryset = queryset.filter(item__family_id=family_id)
    
    if alert_type:
        queryset = queryset.filter(alert_type=alert_type)
    
    if is_resolved is not None:
        queryset = queryset.filter(is_resolved=is_resolved.lower() == 'true')
    
    queryset = queryset.order_by('-created_at')
    
    serializer = InventoryAlertSerializer(queryset, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    summary='解决库存预警',
    request={'application/json': {'alert_ids': [1, 2, 3]}},
    responses={200: {'message': 'success'}}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def resolve_alerts(request):
    alert_ids = request.data.get('alert_ids', [])
    if not alert_ids:
        return Response({'error': '请提供要解决的预警ID列表'}, status=status.HTTP_400_BAD_REQUEST)
    
    queryset = InventoryAlert.objects.filter(
        id__in=alert_ids,
        item__family__members__user=request.user,
        is_resolved=False
    )
    
    updated_count = queryset.update(is_resolved=True, resolved_at=timezone.now())
    
    return Response({
        'message': f'成功解决 {updated_count} 个预警',
        'resolved_count': updated_count
    }, status=status.HTTP_200_OK)


@extend_schema(
    summary='获取库存报表',
    parameters=[
        OpenApiParameter(name='family_id', type=int, description='家庭ID')
    ],
    responses={200: InventoryReportSerializer}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_inventory_report(request):
    family_id = request.query_params.get('family_id')
    
    base_queryset = Item.objects.filter(family__members__user=request.user)
    if family_id:
        base_queryset = base_queryset.filter(family_id=family_id)
    
    total_items = base_queryset.count()
    total_value = base_queryset.aggregate(
        total=Coalesce(Sum(F('quantity') * F('price')), 0)
    )['total'] or 0
    
    category_stats = list(base_queryset.values('category__name').annotate(
        count=Count('id'),
        total_quantity=Sum('quantity'),
        total_value=Coalesce(Sum(F('quantity') * F('price')), 0)
    ).order_by('-count'))
    
    location_stats = list(base_queryset.values('location__name').annotate(
        count=Count('id'),
        total_quantity=Sum('quantity')
    ).order_by('-count'))
    
    today = timezone.now().date()
    low_stock_count = base_queryset.filter(quantity__lte=3).count()
    expired_count = base_queryset.filter(expiry_date__lt=today).count()
    expiring_soon_count = base_queryset.filter(
        expiry_date__gte=today,
        expiry_date__lte=today + timezone.timedelta(days=7)
    ).count()
    
    report_data = {
        'total_items': total_items,
        'total_value': total_value,
        'category_stats': category_stats,
        'location_stats': location_stats,
        'low_stock_count': low_stock_count,
        'expired_count': expired_count,
        'expiring_soon_count': expiring_soon_count
    }
    
    serializer = InventoryReportSerializer(report_data)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    summary='获取采购建议',
    parameters=[
        OpenApiParameter(name='family_id', type=int, description='家庭ID')
    ],
    responses={200: PurchaseSuggestionSerializer(many=True)}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_purchase_suggestions(request):
    family_id = request.query_params.get('family_id')
    
    base_queryset = Item.objects.filter(family__members__user=request.user)
    if family_id:
        base_queryset = base_queryset.filter(family_id=family_id)
    
    suggestions = []
    today = timezone.now().date()
    
    low_stock_items = base_queryset.filter(quantity__lte=3)
    for item in low_stock_items:
        suggested_quantity = 10 - item.quantity
        suggestions.append({
            'item_id': item.id,
            'item_name': item.name,
            'current_quantity': item.quantity,
            'suggested_quantity': suggested_quantity,
            'reason': '库存不足',
            'priority': 'high' if item.quantity == 0 else 'medium'
        })
    
    expiring_soon_items = base_queryset.filter(
        expiry_date__gte=today,
        expiry_date__lte=today + timezone.timedelta(days=7)
    )
    for item in expiring_soon_items:
        if not any(s['item_id'] == item.id for s in suggestions):
            suggestions.append({
                'item_id': item.id,
                'item_name': item.name,
                'current_quantity': item.quantity,
                'suggested_quantity': 0,
                'reason': '即将过期，建议优先使用',
                'priority': 'high'
            })
    
    expired_items = base_queryset.filter(expiry_date__lt=today)
    for item in expired_items:
        if not any(s['item_id'] == item.id for s in suggestions):
            suggestions.append({
                'item_id': item.id,
                'item_name': item.name,
                'current_quantity': item.quantity,
                'suggested_quantity': 0,
                'reason': '已过期，建议清理',
                'priority': 'low'
            })
    
    suggestions.sort(key=lambda x: x['priority'] == 'high', reverse=True)
    
    serializer = PurchaseSuggestionSerializer(suggestions, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    summary='获取库存日志',
    parameters=[
        OpenApiParameter(name='family_id', type=int, description='家庭ID'),
        OpenApiParameter(name='item_id', type=int, description='物品ID'),
        OpenApiParameter(name='action', type=str, description='操作类型: add, update, delete, consume, restock')
    ],
    responses={200: InventoryLogSerializer(many=True)}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_inventory_logs(request):
    family_id = request.query_params.get('family_id')
    item_id = request.query_params.get('item_id')
    action = request.query_params.get('action')
    
    queryset = InventoryLog.objects.select_related('item').filter(
        item__family__members__user=request.user
    )
    
    if family_id:
        queryset = queryset.filter(item__family_id=family_id)
    
    if item_id:
        queryset = queryset.filter(item_id=item_id)
    
    if action:
        queryset = queryset.filter(action=action)
    
    queryset = queryset.order_by('-created_at')[:100]
    
    serializer = InventoryLogSerializer(queryset, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    summary='记录库存操作',
    request={'application/json': {'item_id': 1, 'action': 'consume', 'quantity_change': 2, 'note': ''}},
    responses={201: InventoryLogSerializer}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def log_inventory_action(request):
    item_id = request.data.get('item_id')
    action = request.data.get('action')
    quantity_change = request.data.get('quantity_change', 0)
    note = request.data.get('note', '')
    
    if not item_id or not action:
        return Response({'error': '请提供物品ID和操作类型'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        item = Item.objects.get(
            id=item_id,
            family__members__user=request.user
        )
    except Item.DoesNotExist:
        return Response({'error': '物品不存在或无权访问'}, status=status.HTTP_404_NOT_FOUND)
    
    quantity_before = item.quantity
    quantity_after = quantity_before + quantity_change
    
    if quantity_after < 0:
        return Response({'error': '库存不能为负数'}, status=status.HTTP_400_BAD_REQUEST)
    
    item.quantity = quantity_after
    item.save()
    
    log = InventoryLog.objects.create(
        item=item,
        action=action,
        quantity_before=quantity_before,
        quantity_after=quantity_after,
        quantity_change=quantity_change,
        note=note
    )
    
    serializer = InventoryLogSerializer(log)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
