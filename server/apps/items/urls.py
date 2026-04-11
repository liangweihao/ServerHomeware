from django.urls import path
from .views import (
    ItemListCreateView,
    ItemDetailView,
    batch_delete_items,
    ItemUsageHistoryView
)

urlpatterns = [
    path('', ItemListCreateView.as_view(), name='item-list-create'),
    path('<int:pk>/', ItemDetailView.as_view(), name='item-detail'),
    path('<int:item_id>/usage-history/', ItemUsageHistoryView.as_view(), name='item-usage-history'),
    path('batch-delete/', batch_delete_items, name='batch-delete-items'),
]
