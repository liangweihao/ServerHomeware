from rest_framework import generics, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import Category, Location, Item
from .serializers import (
    CategorySerializer,
    LocationSerializer,
    ItemSerializer,
    ItemCreateSerializer,
    ItemUpdateSerializer
)


class CategoryListCreateView(generics.ListCreateAPIView):
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['family']

    def get_queryset(self):
        family_id = self.request.query_params.get('family_id')
        if family_id:
            return Category.objects.filter(family_id=family_id)
        return Category.objects.filter(family__members__user=self.request.user).distinct()

    def perform_create(self, serializer):
        serializer.save()

    @extend_schema(
        summary='获取分类列表',
        parameters=[
            OpenApiParameter(name='family_id', type=int, description='家庭ID')
        ],
        responses={200: CategorySerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        summary='创建分类',
        request=CategorySerializer,
        responses={201: CategorySerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class LocationListCreateView(generics.ListCreateAPIView):
    serializer_class = LocationSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['family', 'parent']

    def get_queryset(self):
        family_id = self.request.query_params.get('family_id')
        if family_id:
            return Location.objects.filter(family_id=family_id)
        return Location.objects.filter(family__members__user=self.request.user).distinct()

    def perform_create(self, serializer):
        serializer.save()

    @extend_schema(
        summary='获取位置列表',
        parameters=[
            OpenApiParameter(name='family_id', type=int, description='家庭ID'),
            OpenApiParameter(name='parent', type=int, description='父位置ID')
        ],
        responses={200: LocationSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        summary='创建位置',
        request=LocationSerializer,
        responses={201: LocationSerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class ItemListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['family', 'category', 'location']
    search_fields = ['name', 'description', 'barcode']
    ordering_fields = ['name', 'quantity', 'expiry_date', 'created_at']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ItemCreateSerializer
        return ItemSerializer

    def get_queryset(self):
        family_id = self.request.query_params.get('family_id')
        queryset = Item.objects.select_related('category', 'location', 'created_by')
        
        if family_id:
            queryset = queryset.filter(family_id=family_id)
        else:
            queryset = queryset.filter(family__members__user=self.request.user)
        
        return queryset.distinct()

    def perform_create(self, serializer):
        serializer.save()

    @extend_schema(
        summary='获取物品列表',
        parameters=[
            OpenApiParameter(name='family_id', type=int, description='家庭ID'),
            OpenApiParameter(name='category', type=int, description='分类ID'),
            OpenApiParameter(name='location', type=int, description='位置ID'),
            OpenApiParameter(name='search', type=str, description='搜索关键词'),
            OpenApiParameter(name='ordering', type=str, description='排序字段')
        ],
        responses={200: ItemSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        summary='添加物品',
        request=ItemCreateSerializer,
        responses={201: ItemSerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class ItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return ItemUpdateSerializer
        return ItemSerializer

    def get_queryset(self):
        return Item.objects.select_related('category', 'location', 'created_by').filter(family__members__user=self.request.user)

    @extend_schema(
        summary='获取物品详情',
        responses={200: ItemSerializer}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        summary='更新物品',
        request=ItemUpdateSerializer,
        responses={200: ItemSerializer}
    )
    def put(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)

    @extend_schema(
        summary='部分更新物品',
        request=ItemUpdateSerializer,
        responses={200: ItemSerializer}
    )
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)

    @extend_schema(
        summary='删除物品',
        responses={204: None}
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)


@extend_schema(
    summary='批量删除物品',
    request={'application/json': {'item_ids': [1, 2, 3]}},
    responses={200: {'message': 'success'}}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def batch_delete_items(request):
    item_ids = request.data.get('item_ids', [])
    if not item_ids:
        return Response({'error': '请提供要删除的物品ID列表'}, status=status.HTTP_400_BAD_REQUEST)
    
    queryset = Item.objects.filter(
        id__in=item_ids,
        family__members__user=request.user
    )
    
    deleted_count = queryset.count()
    queryset.delete()
    
    return Response({
        'message': f'成功删除 {deleted_count} 个物品',
        'deleted_count': deleted_count
    }, status=status.HTTP_200_OK)
