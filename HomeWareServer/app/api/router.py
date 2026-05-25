"""
路由注册模块
注册所有API路由
"""
from fastapi import APIRouter

from app.api.v1 import (
    activities_router,
    alerts_router,
    auth_router,
    barcode_router,
    categories_router,
    devices_router,
    export_router,
    families_router,
    health_router,
    items_router,
    locations_router,
    notifications_router,
    shopping_router,
    statistics_router,
    sync_router,
    upload_router,
    usage_records_router,
    users_router,
    ws_router,
)

api_router = APIRouter()

# 注册各模块路由
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(families_router)
api_router.include_router(items_router)
api_router.include_router(categories_router)
api_router.include_router(locations_router)
api_router.include_router(usage_records_router)
api_router.include_router(shopping_router)
api_router.include_router(alerts_router)
api_router.include_router(statistics_router)
api_router.include_router(upload_router)
api_router.include_router(activities_router)
api_router.include_router(devices_router)
api_router.include_router(sync_router)
api_router.include_router(notifications_router)
api_router.include_router(barcode_router)
api_router.include_router(export_router)
api_router.include_router(health_router)
api_router.include_router(ws_router)