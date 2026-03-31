from django.urls import path
from apps.items.views import (
    CategoryListCreateView,
    LocationListCreateView,
)

urlpatterns = [
    # 直接处理根路径，因为在主路由中已经包含了 /api/categories/ 前缀
    path('', CategoryListCreateView.as_view(), name='category-list-create'),
    # 不需要 locations 路径，因为它在另一个路由中处理
]
