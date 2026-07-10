"""
API v1 版本路由初始化文件
"""
from app.api.v1.assistant import router as assistant_router
from app.api.v1.auth import router as auth_router
from app.api.v1.users import router as users_router
from app.api.v1.families import router as families_router
from app.api.v1.contributions import router as contributions_router
from app.api.v1.items import router as items_router
from app.api.v1.categories import router as categories_router
from app.api.v1.locations import router as locations_router
from app.api.v1.usage_records import router as usage_records_router
from app.api.v1.shopping import router as shopping_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.statistics import router as statistics_router
from app.api.v1.upload import router as upload_router
from app.api.v1.activities import router as activities_router
from app.api.v1.devices import router as devices_router
from app.api.v1.sync import router as sync_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.barcode import router as barcode_router
from app.api.v1.export import router as export_router
from app.api.v1.health import router as health_router
from app.api.v1.ws import router as ws_router

__all__ = [
    "assistant_router",
    "auth_router",
    "users_router",
    "families_router",
    "contributions_router",
    "items_router",
    "categories_router",
    "locations_router",
    "usage_records_router",
    "shopping_router",
    "alerts_router",
    "statistics_router",
    "upload_router",
    "activities_router",
    "devices_router",
    "sync_router",
    "notifications_router",
    "barcode_router",
    "export_router",
    "health_router",
    "ws_router",
]
from app.api.v1.users import router as users_router
from app.api.v1.families import router as families_router
from app.api.v1.contributions import router as contributions_router
from app.api.v1.items import router as items_router
from app.api.v1.categories import router as categories_router
from app.api.v1.locations import router as locations_router
from app.api.v1.usage_records import router as usage_records_router
from app.api.v1.shopping import router as shopping_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.statistics import router as statistics_router
from app.api.v1.upload import router as upload_router
from app.api.v1.activities import router as activities_router
from app.api.v1.devices import router as devices_router
from app.api.v1.sync import router as sync_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.barcode import router as barcode_router
from app.api.v1.export import router as export_router
from app.api.v1.health import router as health_router
from app.api.v1.ws import router as ws_router

__all__ = [
    "auth_router",
    "users_router",
    "families_router",
    "contributions_router",
    "items_router",
    "categories_router",
    "locations_router",
    "usage_records_router",
    "shopping_router",
    "alerts_router",
    "statistics_router",
    "upload_router",
    "activities_router",
    "devices_router",
    "sync_router",
    "notifications_router",
    "barcode_router",
    "export_router",
    "health_router",
    "ws_router",
]