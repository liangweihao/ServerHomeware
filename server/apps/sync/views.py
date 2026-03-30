from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django.db import transaction
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import SyncRecord, SyncConflict
from .serializers import (
    SyncRecordSerializer,
    SyncConflictSerializer,
    SyncRequestSerializer,
    SyncDataSerializer,
    ConflictResolutionSerializer
)
from apps.users.models import Family
from apps.items.models import Item, Category, Location
from apps.inventory.models import InventoryLog


@extend_schema(
    summary='发起数据同步',
    request=SyncRequestSerializer,
    responses={200: SyncDataSerializer}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def initiate_sync(request):
    serializer = SyncRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    family_id = serializer.validated_data['family_id']
    sync_type = serializer.validated_data['sync_type']
    last_sync_timestamp = serializer.validated_data.get('last_sync_timestamp')
    
    try:
        family = Family.objects.get(
            id=family_id,
            members__user=request.user
        )
    except Family.DoesNotExist:
        return Response({'error': '家庭不存在或无权访问'}, status=404)
    
    sync_record = SyncRecord.objects.create(
        user=request.user,
        family=family,
        sync_type=sync_type,
        last_sync_timestamp=last_sync_timestamp,
        status='processing'
    )
    
    try:
        items_queryset = Item.objects.filter(family=family)
        
        if sync_type == 'incremental' and last_sync_timestamp:
            items_queryset = items_queryset.filter(updated_at__gt=last_sync_timestamp)
        
        items = items_queryset.select_related('category', 'location', 'created_by')
        categories = list(Category.objects.filter(family=family).values())
        locations = list(Location.objects.filter(family=family).values())
        
        sync_record.items_count = items.count()
        sync_record.status = 'completed'
        sync_record.completed_at = timezone.now()
        sync_record.save()
        
        sync_data = {
            'items': [{
                'id': item.id,
                'name': item.name,
                'description': item.description,
                'category_id': item.category_id,
                'location_id': item.location_id,
                'quantity': item.quantity,
                'unit': item.unit,
                'expiry_date': item.expiry_date,
                'purchase_date': item.purchase_date,
                'price': item.price,
                'barcode': item.barcode,
                'family_id': item.family_id,
                'created_by_id': item.created_by_id,
                'created_at': item.created_at,
                'updated_at': item.updated_at,
                'image_url': item.image.url if item.image else None
            } for item in items],
            'categories': categories,
            'locations': locations,
            'timestamp': timezone.now()
        }
        
        data_serializer = SyncDataSerializer(sync_data)
        return Response(data_serializer.data, status=200)
    
    except Exception as e:
        sync_record.status = 'failed'
        sync_record.error_message = str(e)
        sync_record.completed_at = timezone.now()
        sync_record.save()
        return Response({'error': f'同步失败: {str(e)}'}, status=500)


@extend_schema(
    summary='上传客户端数据',
    request=SyncDataSerializer,
    responses={200: {'message': 'success', 'conflicts': []}}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_client_data(request):
    serializer = SyncDataSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    family_id = request.data.get('family_id')
    
    try:
        family = Family.objects.get(
            id=family_id,
            members__user=request.user
        )
    except Family.DoesNotExist:
        return Response({'error': '家庭不存在或无权访问'}, status=404)
    
    sync_record = SyncRecord.objects.create(
        user=request.user,
        family=family,
        sync_type='incremental',
        status='processing'
    )
    
    conflicts = []
    
    try:
        with transaction.atomic():
            client_items = request.data.get('items', [])
            
            for item_data in client_items:
                item_id = item_data.get('id')
                
                if item_id:
                    try:
                        server_item = Item.objects.get(id=item_id, family=family)
                        
                        if server_item.updated_at > item_data.get('updated_at'):
                            conflict = SyncConflict.objects.create(
                                sync_record=sync_record,
                                item=server_item,
                                conflict_type='update',
                                server_data={
                                    'id': server_item.id,
                                    'name': server_item.name,
                                    'quantity': server_item.quantity,
                                    'updated_at': server_item.updated_at.isoformat()
                                },
                                client_data=item_data
                            )
                            conflicts.append(SyncConflictSerializer(conflict).data)
                        else:
                            for field, value in item_data.items():
                                if field != 'id' and hasattr(server_item, field):
                                    setattr(server_item, field, value)
                            server_item.save()
                            
                            if server_item.quantity != item_data.get('quantity'):
                                InventoryLog.objects.create(
                                    item=server_item,
                                    action='update',
                                    quantity_before=server_item.quantity,
                                    quantity_after=item_data.get('quantity'),
                                    quantity_change=item_data.get('quantity') - server_item.quantity,
                                    note='客户端同步更新'
                                )
                    
                    except Item.DoesNotExist:
                        pass
                else:
                    Item.objects.create(
                        family=family,
                        created_by=request.user,
                        **item_data
                    )
            
            sync_record.items_count = len(client_items)
            sync_record.status = 'completed'
            sync_record.completed_at = timezone.now()
            sync_record.save()
        
        return Response({
            'message': '数据上传成功',
            'conflicts': conflicts
        }, status=200)
    
    except Exception as e:
        sync_record.status = 'failed'
        sync_record.error_message = str(e)
        sync_record.completed_at = timezone.now()
        sync_record.save()
        return Response({'error': f'上传失败: {str(e)}'}, status=500)


@extend_schema(
    summary='获取同步记录',
    parameters=[
        OpenApiParameter(name='family_id', type=int, description='家庭ID')
    ],
    responses={200: SyncRecordSerializer(many=True)}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_sync_records(request):
    family_id = request.query_params.get('family_id')
    
    queryset = SyncRecord.objects.filter(user=request.user)
    
    if family_id:
        queryset = queryset.filter(family_id=family_id)
    
    queryset = queryset.order_by('-created_at')[:50]
    
    serializer = SyncRecordSerializer(queryset, many=True)
    return Response(serializer.data, status=200)


@extend_schema(
    summary='获取同步冲突',
    parameters=[
        OpenApiParameter(name='sync_record_id', type=int, description='同步记录ID'),
        OpenApiParameter(name='is_resolved', type=bool, description='是否已解决')
    ],
    responses={200: SyncConflictSerializer(many=True)}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_sync_conflicts(request):
    sync_record_id = request.query_params.get('sync_record_id')
    is_resolved = request.query_params.get('is_resolved')
    
    queryset = SyncConflict.objects.filter(
        sync_record__user=request.user
    ).select_related('item', 'sync_record')
    
    if sync_record_id:
        queryset = queryset.filter(sync_record_id=sync_record_id)
    
    if is_resolved is not None:
        queryset = queryset.filter(is_resolved=is_resolved.lower() == 'true')
    
    queryset = queryset.order_by('-created_at')
    
    serializer = SyncConflictSerializer(queryset, many=True)
    return Response(serializer.data, status=200)


@extend_schema(
    summary='解决同步冲突',
    request=ConflictResolutionSerializer,
    responses={200: {'message': 'success'}}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def resolve_conflict(request):
    serializer = ConflictResolutionSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    conflict_id = serializer.validated_data['conflict_id']
    resolution = serializer.validated_data['resolution']
    manual_data = serializer.validated_data.get('manual_data')
    
    try:
        conflict = SyncConflict.objects.get(
            id=conflict_id,
            sync_record__user=request.user
        )
    except SyncConflict.DoesNotExist:
        return Response({'error': '冲突记录不存在或无权访问'}, status=404)
    
    try:
        with transaction.atomic():
            item = conflict.item
            
            if resolution == 'server':
                pass
            elif resolution == 'client':
                client_data = conflict.client_data
                for field, value in client_data.items():
                    if field != 'id' and hasattr(item, field):
                        setattr(item, field, value)
                item.save()
            elif resolution == 'client' and manual_data:
                for field, value in manual_data.items():
                    if field != 'id' and hasattr(item, field):
                        setattr(item, field, value)
                item.save()
            
            conflict.resolution = resolution
            conflict.is_resolved = True
            conflict.resolved_at = timezone.now()
            conflict.save()
        
        return Response({'message': '冲突已解决'}, status=200)
    
    except Exception as e:
        return Response({'error': f'解决冲突失败: {str(e)}'}, status=500)
