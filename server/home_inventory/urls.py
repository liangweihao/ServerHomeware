from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', lambda request: redirect('redoc', permanent=False)),
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    path('api/', include('apps.users.urls')),
    path('api/categories/', include('apps.items.category_location_urls')),
    path('api/locations/', include('apps.items.location_urls')),
    path('api/items/', include('apps.items.urls')),
    path('api/inventory/', include('apps.inventory.urls')),
    path('api/sync/', include('apps.sync.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
