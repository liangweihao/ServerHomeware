from django.urls import path
from .views import (
    ItemListCreateView,
    ItemDetailView,
    batch_delete_items
)

urlpatterns = [
    path('', ItemListCreateView.as_view(), name='item-list-create'),
    path('<int:pk>/', ItemDetailView.as_view(), name='item-detail'),
    path('batch-delete/', batch_delete_items, name='batch-delete-items'),
]
