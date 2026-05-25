"""
schemas模块初始化文件
导出所有Pydantic模型
"""
from app.schemas.common import ResponseSchema, PaginatedResponseSchema, PaginatedData
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    RefreshRequest,
    TokenResponse,
)
from app.schemas.user import (
    UserResponse,
    UpdateUserRequest,
    ChangePasswordRequest,
)
from app.schemas.family import (
    FamilyResponse,
    FamilyMemberResponse,
    CreateFamilyRequest,
    JoinFamilyRequest,
    UpdateFamilyRequest,
    UpdateFamilyMemberRequest,
)
from app.schemas.item import (
    ItemResponse,
    CreateItemRequest,
    UpdateItemRequest,
)
from app.schemas.category import (
    CategoryResponse,
    CreateCategoryRequest,
    UpdateCategoryRequest,
)
from app.schemas.location import (
    LocationResponse,
    CreateLocationRequest,
    UpdateLocationRequest,
)
from app.schemas.usage_record import (
    UsageRecordResponse,
    CreateUsageRecordRequest,
)
from app.schemas.shopping import (
    ShoppingItemResponse,
    CreateShoppingItemRequest,
    UpdateShoppingItemRequest,
)
from app.schemas.alert import (
    AlertResponse,
    AlertSummaryResponse,
)

__all__ = [
    "ResponseSchema",
    "PaginatedResponseSchema",
    "PaginatedData",
    "RegisterRequest",
    "LoginRequest",
    "RefreshRequest",
    "TokenResponse",
    "UserResponse",
    "UpdateUserRequest",
    "ChangePasswordRequest",
    "FamilyResponse",
    "FamilyMemberResponse",
    "CreateFamilyRequest",
    "JoinFamilyRequest",
    "UpdateFamilyRequest",
    "UpdateFamilyMemberRequest",
    "ItemResponse",
    "CreateItemRequest",
    "UpdateItemRequest",
    "CategoryResponse",
    "CreateCategoryRequest",
    "UpdateCategoryRequest",
    "LocationResponse",
    "CreateLocationRequest",
    "UpdateLocationRequest",
    "UsageRecordResponse",
    "CreateUsageRecordRequest",
    "ShoppingItemResponse",
    "CreateShoppingItemRequest",
    "UpdateShoppingItemRequest",
    "AlertResponse",
    "AlertSummaryResponse",
]