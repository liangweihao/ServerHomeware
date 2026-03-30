from django.urls import path
from .views import (
    CategoryListCreateView,
    LocationListCreateView,
    ItemListCreateView,
    ItemDetailView,
    batch_delete_items
)

urlpatterns = [
    path('categories/', CategoryListCreateView.as_view(), name='category-list-create'),
    path('locations/', LocationListCreateView.as_view(), name='location-list-create'),
    path('', ItemListCreateView.as_view(), name='item-list-create'),
    path('<int:id>/', ItemDetailView.as_view(), name='item-detail'),
    path('batch-delete/', batch_delete_items, name='batch-delete-items'),
]
