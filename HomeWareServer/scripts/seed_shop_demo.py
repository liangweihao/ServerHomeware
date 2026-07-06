"""
店主试用演示数据种子脚本

创建三类演示账号（可重复执行，已存在则跳过）：
- 13800000001 演示店主 — shop 空间老板，含 15+ 预置商品
- 13800000002 演示店员 — 已加入上述店铺，角色 clerk
- 13800000003 演示家庭 — home 空间，含 Phase A 走查用物品

用法（在 HomeWareServer 目录，venv 已激活）：
    python scripts/seed_shop_demo.py
    python scripts/seed_shop_demo.py --force-items   # 清空演示空间物品后重建

默认密码：demo123456
"""
from __future__ import annotations

import argparse
import asyncio
import logging
import os
import sys
from datetime import date, timedelta
from decimal import Decimal
from typing import Any, Dict, List, Optional

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import delete, select

from app.core.database import async_session_maker
from app.core.security import get_password_hash
from app.core.space_type import SPACE_TYPE_HOME, SPACE_TYPE_SHOP
from app.models.family import Family, FamilyMember
from app.models.item import Item
from app.models.location import Location
from app.models.usage_record import UsageRecord
from app.models.user import User
from app.repositories.category_repo import CategoryRepository
from app.repositories.family_repo import FamilyMemberRepository, FamilyRepository
from app.repositories.location_repo import LocationRepository
from app.repositories.user_repo import UserRepository
from app.services.family_service import FamilyService
from app.services.item_service import ItemService
from scripts.seed_data import seed_categories

logger = logging.getLogger(__name__)

# 演示账号常量
DEMO_PASSWORD = "demo123456"
SHOP_OWNER_PHONE = "13800000001"
SHOP_CLERK_PHONE = "13800000002"
HOME_USER_PHONE = "13800000003"

SHOP_FAMILY_NAME = "演示便利店"
HOME_FAMILY_NAME = "演示家庭"


async def _get_or_create_user(
    session,
    phone: str,
    nickname: str,
) -> User:
    """按手机号获取或创建用户"""
    user_repo = UserRepository(session)
    existing = await user_repo.get_by_phone(phone)
    if existing:
        logger.info("用户已存在，跳过创建 - phone=%s", phone)
        return existing

    user = await user_repo.create(
        {
            "phone": phone,
            "password_hash": get_password_hash(DEMO_PASSWORD),
            "nickname": nickname,
            "is_active": True,
        }
    )
    logger.info("用户创建成功 - phone=%s, id=%s", phone, user.id)
    return user


def _build_name_map(rows: List, key: str = "name") -> Dict[str, int]:
    """名称 → ID 映射（同名取首个）"""
    result: Dict[str, int] = {}
    for row in rows:
        name = getattr(row, key)
        if name not in result:
            result[name] = row.id
    return result


async def _resolve_shop_family(session, owner: User) -> Family:
    """获取或创建 shop 演示空间"""
    family_repo = FamilyRepository(session)
    user_repo = UserRepository(session)

    # 优先找 owner 名下已有 shop 空间
    stmt = (
        select(Family)
        .join(FamilyMember, FamilyMember.family_id == Family.id)
        .where(
            FamilyMember.user_id == owner.id,
            FamilyMember.role == "owner",
            Family.space_type == SPACE_TYPE_SHOP,
        )
    )
    result = await session.execute(stmt)
    family = result.scalar_one_or_none()
    if family:
        logger.info("shop 演示空间已存在 - familyId=%s", family.id)
        await user_repo.update(owner.id, {"current_family_id": family.id})
        return family

    service = FamilyService(session)
    family = await service.create_family(
        name=SHOP_FAMILY_NAME,
        owner_id=owner.id,
        description="店主试用包演示数据",
        space_type=SPACE_TYPE_SHOP,
    )
    logger.info("shop 演示空间创建成功 - familyId=%s, invite=%s", family.id, family.invite_code)
    return family


async def _resolve_home_family(session, owner: User) -> Family:
    """获取或创建 home 演示空间"""
    user_repo = UserRepository(session)

    stmt = (
        select(Family)
        .join(FamilyMember, FamilyMember.family_id == Family.id)
        .where(
            FamilyMember.user_id == owner.id,
            FamilyMember.role == "owner",
            Family.space_type == SPACE_TYPE_HOME,
        )
    )
    result = await session.execute(stmt)
    family = result.scalar_one_or_none()
    if family:
        logger.info("home 演示空间已存在 - familyId=%s", family.id)
        await user_repo.update(owner.id, {"current_family_id": family.id})
        return family

    service = FamilyService(session)
    family = await service.create_family(
        name=HOME_FAMILY_NAME,
        owner_id=owner.id,
        description="Phase A Gate 走查演示",
        space_type=SPACE_TYPE_HOME,
    )
    logger.info("home 演示空间创建成功 - familyId=%s", family.id)
    return family


async def _ensure_clerk_joined(session, clerk: User, shop_family: Family) -> None:
    """确保店员已加入 shop 且角色为 clerk"""
    member_repo = FamilyMemberRepository(session)
    existing = await member_repo.get_by_user_and_family(clerk.id, shop_family.id)
    if existing:
        if existing.role != "clerk":
            await member_repo.update(existing.id, {"role": "clerk"})
            logger.info("店员角色已修正为 clerk - userId=%s", clerk.id)
        return

    service = FamilyService(session)
    # join_family 对 shop 默认 clerk
    await service.join_family(clerk.id, shop_family.invite_code)
    logger.info("店员已加入 shop - userId=%s, familyId=%s", clerk.id, shop_family.id)


async def _clear_family_items(session, family_id: int) -> None:
    """清空空间内物品及关联 usage 记录（演示重建用）"""
    item_ids_stmt = select(Item.id).where(Item.family_id == family_id)
    item_ids = (await session.execute(item_ids_stmt)).scalars().all()
    if not item_ids:
        return

    await session.execute(delete(UsageRecord).where(UsageRecord.item_id.in_(item_ids)))
    await session.execute(delete(Item).where(Item.family_id == family_id))
    await session.commit()
    logger.warning("已清空演示空间物品 - familyId=%s, count=%s", family_id, len(item_ids))


async def _seed_shop_items(session, owner: User, family: Family) -> int:
    """写入 shop 演示商品"""
    cat_repo = CategoryRepository(session)
    loc_repo = LocationRepository(session)
    item_service = ItemService(session)

    categories = await cat_repo.get_by_family_id(family.id)
    locations = await loc_repo.get_by_family_id(family.id)
    cat_map = _build_name_map(categories)
    loc_map = _build_name_map(locations)

    # 若店铺分类未写入，尝试全局分类名匹配（兼容旧数据）
    if "饮料" not in cat_map:
        all_cats = await cat_repo.get_categories_with_family(family.id)
        cat_map = _build_name_map(all_cats)

    today = date.today()

    demo_items: List[Dict[str, Any]] = [
        {
            "name": "红牛",
            "brand": "红牛",
            "category": "饮料",
            "location": "A架",
            "unit": "罐",
            "purchase_quantity": 24,
            "current_quantity": 8,
            "safety_stock": 20,
            "purchase_price": Decimal("4.50"),
            "sale_price": Decimal("6.00"),
            "supplier": "华联批发",
        },
        {
            "name": "可乐",
            "brand": "可口可乐",
            "category": "饮料",
            "location": "店面",
            "unit": "瓶",
            "purchase_quantity": 24,
            "current_quantity": 48,
            "purchase_price": Decimal("2.00"),
            "sale_price": Decimal("3.50"),
            "supplier": "可口可乐经销商",
        },
        {
            "name": "农夫山泉",
            "category": "饮料",
            "location": "冷柜",
            "unit": "瓶",
            "current_quantity": 24,
            "sale_price": Decimal("2.00"),
            "purchase_price": Decimal("1.20"),
        },
        {
            "name": "雪碧",
            "category": "饮料",
            "location": "B架",
            "unit": "瓶",
            "current_quantity": 2,
            "safety_stock": 10,
            "sale_price": Decimal("3.00"),
            "purchase_price": Decimal("1.80"),
        },
        {
            "name": "脉动",
            "category": "饮料",
            "location": "冷柜",
            "unit": "瓶",
            "current_quantity": 1,
            "safety_stock": 6,
            "sale_price": Decimal("5.00"),
            "purchase_price": Decimal("3.50"),
        },
        {
            "name": "奥利奥",
            "category": "休闲食品",
            "location": "A架",
            "unit": "盒",
            "current_quantity": 5,
            "sale_price": Decimal("12.00"),
            "purchase_price": Decimal("8.50"),
        },
        {
            "name": "乐事薯片",
            "category": "休闲食品",
            "location": "B架",
            "unit": "袋",
            "current_quantity": 3,
            "safety_stock": 8,
            "sale_price": Decimal("7.50"),
            "purchase_price": Decimal("5.00"),
        },
        {
            "name": "康师傅红烧牛肉面",
            "category": "休闲食品",
            "location": "A架",
            "unit": "桶",
            "current_quantity": 12,
            "sale_price": Decimal("5.50"),
            "purchase_price": Decimal("3.80"),
        },
        {
            "name": "中华",
            "category": "烟酒百货",
            "location": "柜台",
            "unit": "包",
            "current_quantity": 10,
            "sale_price": Decimal("65.00"),
            "purchase_price": Decimal("58.00"),
        },
        {
            "name": "玉溪",
            "category": "烟酒百货",
            "location": "柜台",
            "unit": "包",
            "current_quantity": 5,
            "sale_price": Decimal("22.00"),
            "purchase_price": Decimal("19.00"),
        },
        {
            "name": "舒肤佳香皂",
            "category": "日用洗护",
            "location": "A架",
            "unit": "块",
            "current_quantity": 6,
            "sale_price": Decimal("6.50"),
            "purchase_price": Decimal("4.20"),
        },
        {
            "name": "蓝月亮洗衣液",
            "category": "日用洗护",
            "location": "库房",
            "unit": "瓶",
            "current_quantity": 4,
            "sale_price": Decimal("39.90"),
            "purchase_price": Decimal("28.00"),
        },
        {
            "name": "旺仔牛奶",
            "category": "饮料",
            "location": "冷柜",
            "unit": "罐",
            "current_quantity": 18,
            "sale_price": Decimal("4.00"),
            "purchase_price": Decimal("2.80"),
        },
        {
            "name": "士力架",
            "category": "休闲食品",
            "location": "B架",
            "unit": "条",
            "current_quantity": 15,
            "sale_price": Decimal("4.50"),
            "purchase_price": Decimal("3.00"),
        },
        {
            "name": "青岛啤酒",
            "category": "饮料",
            "location": "冷柜",
            "unit": "瓶",
            "current_quantity": 20,
            "sale_price": Decimal("6.00"),
            "purchase_price": Decimal("4.00"),
        },
    ]

    created = 0
    for spec in demo_items:
        cat_name = spec.pop("category")
        loc_name = spec.pop("location")
        category_id = cat_map.get(cat_name)
        location_id = loc_map.get(loc_name)

        if not category_id:
            logger.error("分类未找到，跳过 - name=%s, category=%s", spec.get("name"), cat_name)
            continue
        if not location_id:
            logger.error("位置未找到，跳过 - name=%s, location=%s", spec.get("name"), loc_name)
            continue

        payload = {
            **spec,
            "category_id": category_id,
            "location_id": location_id,
            "purchase_date": today,
            "stock_alert": True,
        }
        await item_service.create_item(owner.id, family.id, payload)
        created += 1

    logger.info("shop 演示商品写入完成 - count=%s", created)
    return created


async def _find_location_by_path(locations: List[Location], path: str) -> Optional[int]:
    """按 full_path 或末级名称查找位置 ID"""
    for loc in locations:
        if loc.full_path == path or loc.name == path.split("/")[-1]:
            if loc.full_path == path:
                return loc.id
    # 末级名兜底
    leaf = path.split("/")[-1]
    for loc in locations:
        if loc.name == leaf:
            return loc.id
    return None


async def _seed_home_items(session, owner: User, family: Family) -> int:
    """写入 home 演示商品（Phase A 走查）"""
    cat_repo = CategoryRepository(session)
    loc_repo = LocationRepository(session)
    item_service = ItemService(session)

    categories = await cat_repo.get_categories_with_family(family.id)
    locations = await loc_repo.get_by_family_id(family.id)
    cat_map = _build_name_map(categories)

    # 优先使用乳制品/食品饮料等系统分类
    milk_cat = cat_map.get("乳制品") or cat_map.get("食品饮料") or next(iter(cat_map.values()), None)
    food_cat = cat_map.get("食品饮料") or milk_cat
    clean_cat = cat_map.get("日用清洁") or food_cat
    med_cat = cat_map.get("药品保健") or food_cat

    fridge_id = await _find_location_by_path(locations, "厨房/冰箱/冷藏层")
    kitchen_id = await _find_location_by_path(locations, "厨房")
    spice_id = await _find_location_by_path(locations, "厨房/调料架")
    bath_id = await _find_location_by_path(locations, "卫生间")

    today = date.today()

    demo_items: List[Dict[str, Any]] = [
        {
            "name": "牛奶",
            "category_id": milk_cat,
            "location_id": fridge_id or kitchen_id,
            "unit": "盒",
            "current_quantity": 2,
            "purchase_quantity": 2,
            "expiry_date": today + timedelta(days=2),
            "stock_alert": True,
        },
        {
            "name": "鸡蛋",
            "category_id": food_cat,
            "location_id": fridge_id or kitchen_id,
            "unit": "个",
            "current_quantity": 6,
            "purchase_quantity": 6,
        },
        {
            "name": "酱油",
            "category_id": food_cat,
            "location_id": spice_id or kitchen_id,
            "unit": "瓶",
            "current_quantity": 1,
            "safety_stock": 2,
            "stock_alert": True,
        },
        {
            "name": "洗发水",
            "category_id": clean_cat,
            "location_id": bath_id or kitchen_id,
            "unit": "瓶",
            "current_quantity": 1,
            "purchase_quantity": 1,
        },
        {
            "name": "维生素C",
            "category_id": med_cat,
            "location_id": kitchen_id,
            "unit": "瓶",
            "current_quantity": 30,
            "expiry_date": today + timedelta(days=60),
        },
        {
            "name": "大米",
            "category_id": food_cat,
            "location_id": kitchen_id,
            "unit": "袋",
            "current_quantity": 1,
            "purchase_quantity": 1,
        },
        {
            "name": "苹果",
            "category_id": cat_map.get("蔬果") or food_cat,
            "location_id": fridge_id or kitchen_id,
            "unit": "个",
            "current_quantity": 5,
        },
    ]

    created = 0
    for spec in demo_items:
        if not spec.get("category_id"):
            logger.error("home 分类缺失，跳过 - %s", spec.get("name"))
            continue
        await item_service.create_item(owner.id, family.id, spec)
        created += 1

    logger.info("home 演示商品写入完成 - count=%s", created)
    return created


async def _count_items(session, family_id: int) -> int:
    stmt = select(Item.id).where(Item.family_id == family_id)
    return len((await session.execute(stmt)).scalars().all())


async def main(force_items: bool) -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")

    async with async_session_maker() as session:
        # 确保系统预设分类存在（home 演示物品依赖）
        await seed_categories(session)

        owner = await _get_or_create_user(session, SHOP_OWNER_PHONE, "演示店主")
        clerk = await _get_or_create_user(session, SHOP_CLERK_PHONE, "演示店员")
        home_user = await _get_or_create_user(session, HOME_USER_PHONE, "演示家庭")

        shop_family = await _resolve_shop_family(session, owner)
        await _ensure_clerk_joined(session, clerk, shop_family)
        home_family = await _resolve_home_family(session, home_user)

        shop_count = await _count_items(session, shop_family.id)
        home_count = await _count_items(session, home_family.id)

        if force_items or shop_count == 0:
            if force_items and shop_count > 0:
                await _clear_family_items(session, shop_family.id)
            await _seed_shop_items(session, owner, shop_family)
        else:
            logger.info("shop 已有 %s 件物品，跳过（加 --force-items 可重建）", shop_count)

        if force_items or home_count == 0:
            if force_items and home_count > 0:
                await _clear_family_items(session, home_family.id)
            await _seed_home_items(session, home_user, home_family)
        else:
            logger.info("home 已有 %s 件物品，跳过（加 --force-items 可重建）", home_count)

        await session.commit()

    print("\n" + "=" * 56)
    print("演示账号已就绪（密码均为 demo123456）")
    print("=" * 56)
    print(f"  店主  {SHOP_OWNER_PHONE}  →  {SHOP_FAMILY_NAME}（shop）")
    print(f"  店员  {SHOP_CLERK_PHONE}  →  同上，角色 clerk")
    print(f"  家庭  {HOME_USER_PHONE}  →  {HOME_FAMILY_NAME}（home）")
    print("\n走查文档：doc/product/phase-b-plus-trial-walkthrough.md")
    print("=" * 56)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="店主/家庭演示数据种子")
    parser.add_argument(
        "--force-items",
        action="store_true",
        help="清空并重建演示空间内的物品",
    )
    args = parser.parse_args()
    asyncio.run(main(force_items=args.force_items))
