from django.urls import path
from apps.items.views import (
    LocationListCreateView,
)

urlpatterns = [
    # 直接处理根路径，因为在主路由中已经包含了 /api/locations/ 前缀
    path('', LocationListCreateView.as_view(), name='location-list-create'),
]
