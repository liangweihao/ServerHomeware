from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from drf_spectacular.types import OpenApiTypes
from .models import User, Family, FamilyMember
from .serializers import (
    UserSerializer,
    UserRegisterSerializer,
    UserLoginSerializer,
    FamilySerializer,
    FamilyCreateSerializer,
    FamilyJoinSerializer,
    FamilyMemberSerializer
)


@extend_schema(
    summary='用户注册',
    request=UserRegisterSerializer,
    responses={201: UserSerializer},
    examples=[
        OpenApiExample(
            '注册示例',
            value={
                'username': 'testuser',
                'email': 'test@example.com',
                'password': 'password123',
                'password_confirm': 'password123',
                'phone': '13800138000'
            }
        )
    ]
)
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'token': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary='用户登录',
    request=UserLoginSerializer,
    responses={200: UserSerializer},
    examples=[
        OpenApiExample(
            '登录示例',
            value={
                'email': 'test@example.com',
                'password': 'password123'
            }
        )
    ]
)
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        try:
            user = User.objects.get(email=email)
            if user.check_password(password):
                refresh = RefreshToken.for_user(user)
                return Response({
                    'user': UserSerializer(user).data,
                    'token': {
                        'access': str(refresh.access_token),
                        'refresh': str(refresh),
                    }
                }, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            pass
        
        return Response({'error': '邮箱或密码错误'}, status=status.HTTP_401_UNAUTHORIZED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary='获取用户信息',
    responses={200: UserSerializer}
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    summary='更新用户信息',
    request=UserSerializer,
    responses={200: UserSerializer}
)
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    serializer = UserSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class FamilyListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return FamilyCreateSerializer
        return FamilySerializer

    def get_queryset(self):
        return Family.objects.filter(members__user=self.request.user).distinct()

    def perform_create(self, serializer):
        serializer.save()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        output_serializer = FamilySerializer(serializer.instance, context={'request': request})
        headers = self.get_success_headers(output_serializer.data)
        return Response(output_serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    @extend_schema(
        summary='获取家庭列表',
        responses={200: FamilySerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(
        summary='创建家庭',
        request=FamilyCreateSerializer,
        responses={201: FamilySerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class FamilyDetailView(generics.RetrieveAPIView):
    serializer_class = FamilySerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'id'

    def get_queryset(self):
        return Family.objects.filter(members__user=self.request.user)

    @extend_schema(
        summary='获取家庭详情',
        responses={200: FamilySerializer}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)


@extend_schema(
    summary='加入家庭',
    request=FamilyJoinSerializer,
    responses={200: FamilyMemberSerializer},
    examples=[
        OpenApiExample(
            '加入家庭示例',
            value={'invite_code': 'abc123def456'}
        )
    ]
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def join_family(request, id):
    serializer = FamilyJoinSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        member = serializer.save()
        return Response(FamilyMemberSerializer(member).data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
