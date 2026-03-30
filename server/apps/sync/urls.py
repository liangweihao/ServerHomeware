from django.urls import path
from .views import (
    initiate_sync,
    upload_client_data,
    get_sync_records,
    get_sync_conflicts,
    resolve_conflict
)

urlpatterns = [
    path('initiate/', initiate_sync, name='initiate-sync'),
    path('upload/', upload_client_data, name='upload-client-data'),
    path('records/', get_sync_records, name='sync-records'),
    path('conflicts/', get_sync_conflicts, name='sync-conflicts'),
    path('conflicts/resolve/', resolve_conflict, name='resolve-conflict'),
]
