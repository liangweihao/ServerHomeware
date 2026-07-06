"""
店铺空间店员角色权限 — 仅 space_type=shop 生效，home 空间跳过
"""
from typing import Iterable, Optional, Set

from app.core.exceptions import ForbiddenException
from app.core.space_type import SPACE_TYPE_SHOP

# 角色层级（数值越大权限越高）
ROLE_LEVEL = {
    "owner": 40,
    "admin": 30,
    "clerk": 20,
    "member": 10,
}

SHOP_ASSIGNABLE_ROLES = frozenset({"admin", "clerk", "member"})
HOME_ASSIGNABLE_ROLES = frozenset({"admin", "member"})

# 店员不可自行设置的价格相关字段
PRICE_FIELDS: Set[str] = {
    "purchase_price",
    "sale_price",
    "supplier",
    "total_price",
}


def normalize_space_type(space_type: Optional[str]) -> str:
    return (space_type or "home").strip().lower()


def is_shop_space(space_type: Optional[str]) -> bool:
    return normalize_space_type(space_type) == SPACE_TYPE_SHOP


def role_level(role: Optional[str]) -> int:
    return ROLE_LEVEL.get((role or "member").lower(), 0)


def assert_role_at_least(role: Optional[str], min_role: str, action: str) -> None:
    """shop 空间角色校验；home 由调用方跳过"""
    if role_level(role) < role_level(min_role):
        raise ForbiddenException(f"需要更高权限：{action}")


def assert_can_create_item(role: Optional[str], space_type: Optional[str], data: dict) -> None:
    if not is_shop_space(space_type):
        return
    assert_role_at_least(role, "clerk", "进货")
    if _has_price_fields(data):
        assert_role_at_least(role, "admin", "设置进价/售价")


def assert_can_bulk_create(role: Optional[str], space_type: Optional[str]) -> None:
    if not is_shop_space(space_type):
        return
    assert_role_at_least(role, "admin", "CSV 批量进货")


def assert_can_update_item(
    role: Optional[str],
    space_type: Optional[str],
    update_data: dict,
) -> None:
    if not is_shop_space(space_type):
        return
    if _has_price_fields(update_data):
        assert_role_at_least(role, "admin", "修改进价/售价/供应商")
    else:
        assert_role_at_least(role, "clerk", "更新物品")


def assert_can_delete_item(role: Optional[str], space_type: Optional[str]) -> None:
    if not is_shop_space(space_type):
        return
    assert_role_at_least(role, "admin", "删除物品")


def assert_can_use_item(role: Optional[str], space_type: Optional[str]) -> None:
    if not is_shop_space(space_type):
        return
    assert_role_at_least(role, "clerk", "卖出/消耗")


def assert_can_manage_members(role: Optional[str], space_type: Optional[str]) -> None:
    if not is_shop_space(space_type):
        return
    assert_role_at_least(role, "admin", "管理成员")


def assert_can_change_member_role(operator_role: Optional[str]) -> None:
    """改角色仅 owner"""
    if operator_role != "owner":
        raise ForbiddenException("仅老板可修改成员角色")


def validate_assignable_role(role: str, space_type: Optional[str]) -> None:
    allowed = (
        SHOP_ASSIGNABLE_ROLES
        if is_shop_space(space_type)
        else HOME_ASSIGNABLE_ROLES
    )
    if role not in allowed:
        raise ForbiddenException(f"该空间不支持角色：{role}")


def default_join_role(space_type: Optional[str]) -> str:
    return "clerk" if is_shop_space(space_type) else "member"


def _has_price_fields(data: dict) -> bool:
    for key in data:
        if key in PRICE_FIELDS and data[key] is not None:
            return True
    return False
