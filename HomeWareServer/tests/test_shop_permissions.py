"""店铺店员角色权限单测"""
import pytest

from app.core.exceptions import ForbiddenException
from app.core.shop_permissions import (
    assert_can_bulk_create,
    assert_can_create_item,
    assert_can_update_item,
    default_join_role,
)


def test_shop_join_default_clerk():
    assert default_join_role("shop") == "clerk"
    assert default_join_role("home") == "member"


def test_clerk_can_create_without_price():
    assert_can_create_item("clerk", "shop", {"name": "可乐"})


def test_clerk_cannot_set_price_on_create():
    with pytest.raises(ForbiddenException):
        assert_can_create_item("clerk", "shop", {"name": "可乐", "sale_price": 3.5})


def test_clerk_cannot_bulk():
    with pytest.raises(ForbiddenException):
        assert_can_bulk_create("clerk", "shop")


def test_admin_can_bulk():
    assert_can_bulk_create("admin", "shop")


def test_home_skips_permission():
    assert_can_create_item("member", "home", {"sale_price": 1})
    assert_can_bulk_create("member", "home")


def test_clerk_cannot_update_price():
    with pytest.raises(ForbiddenException):
        assert_can_update_item("clerk", "shop", {"sale_price": 4.0})


def test_clerk_can_update_name():
    assert_can_update_item("clerk", "shop", {"name": "新名称"})
