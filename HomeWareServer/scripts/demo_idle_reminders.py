#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
长时间未使用提醒 — 演示脚本

用法（在 HomeWareServer 目录）：
  python scripts/demo_idle_reminders.py           # 播种演示物品 + 跑任务 + 打印结果
  python scripts/demo_idle_reminders.py --cleanup # 清理本次播种的演示物品与 idle 通知

效果预览：
  1. 往库里插入几件「久未使用」演示物品（牛奶 / 洗衣液 / 旧耳机等）
  2. 同步执行 generate_idle_reminders（不依赖 Celery Beat）
  3. 在终端打印 notifications(type=idle)，模拟通知中心看到的文案
"""
from __future__ import annotations

import argparse
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

# 保证可从任意 cwd 导入 app
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from sqlalchemy import delete, select

from app.models.category import Category
from app.models.family import Family
from app.models.item import Item
from app.models.notification import Notification
from app.models.user import User
from app.tasks.scheduled_tasks import generate_idle_reminders, get_sync_session

# 演示物品名前缀，便于清理
_DEMO_PREFIX = "[演示-idle]"


def _now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _ensure_categories(session) -> dict[str, int]:
    """确保演示用分类存在，返回 name → id。"""
    wanted = [
        ("食品饮料", "🍎", "#FF8A65"),
        ("日用清洁", "🧹", "#4DB6AC"),
        ("数码配件", "🔌", "#42A5F5"),
        ("其他", "📦", "#A1887F"),
    ]
    existing = {
        row.name: row.id
        for row in session.execute(select(Category)).scalars().all()
    }
    for name, icon, color in wanted:
        if name in existing:
            continue
        cat = Category(
            name=name,
            icon=icon,
            color=color,
            family_id=None,
            is_system=True,
            sort_order=0,
        )
        session.add(cat)
        session.flush()
        existing[name] = cat.id
        print(f"  + 创建分类: {name} (id={cat.id})")
    session.commit()
    return existing


def _pick_family_and_user(session) -> tuple[int, int]:
    family = session.execute(select(Family).order_by(Family.id.asc())).scalars().first()
    user = session.execute(select(User).order_by(User.id.asc())).scalars().first()
    if not family or not user:
        raise SystemExit("错误: 库中没有家庭或用户，请先登录客户端创建家庭，或运行 create_test_user.py")
    return family.id, user.id


def _cleanup_demo(session, family_id: int) -> None:
    """删除演示物品及其 idle 通知。"""
    demo_items = session.execute(
        select(Item).where(
            Item.family_id == family_id,
            Item.name.like(f"{_DEMO_PREFIX}%"),
        )
    ).scalars().all()
    item_ids = [i.id for i in demo_items]
    if item_ids:
        session.execute(
            delete(Notification).where(
                Notification.item_id.in_(item_ids),
                Notification.type == Notification.TYPE_IDLE,
            )
        )
        session.execute(delete(Item).where(Item.id.in_(item_ids)))
        print(f"  已删除演示物品 {len(item_ids)} 件及关联 idle 通知")
    else:
        print("  无演示物品可清理")
    session.commit()


def _seed_demo_items(session, family_id: int, user_id: int, cats: dict[str, int]) -> list[Item]:
    """
    播种 4 件对比鲜明的演示物品。

    注意：进入候选池的门槛是「从未使用且入库>7天」或「上次使用>30天」。
    分类阈值（食材3天/清洁60天等）只在候选池内由 AI/默认规则再筛一次。
    """
    now = _now()
    specs = [
        {
            "name": f"{_DEMO_PREFIX}鲜牛奶",
            "category": "食品饮料",
            # 35 天未用 → 进候选；食材阈值 3 天 → 应提醒
            "last_used_at": now - timedelta(days=35),
            "created_at": now - timedelta(days=40),
            "expect": "进候选 → 应提醒（食材阈值 3 天）",
        },
        {
            "name": f"{_DEMO_PREFIX}洗衣液",
            "category": "日用清洁",
            # 35 天未用 → 进候选；清洁阈值 60 天 → 默认不提醒
            "last_used_at": now - timedelta(days=35),
            "created_at": now - timedelta(days=50),
            "expect": "进候选 → 默认不提醒（清洁阈值 60 天）",
        },
        {
            "name": f"{_DEMO_PREFIX}旧蓝牙耳机",
            "category": "数码配件",
            "last_used_at": now - timedelta(days=100),
            "created_at": now - timedelta(days=200),
            "expect": "进候选 → 应提醒（电子阈值 90 天）",
        },
        {
            "name": f"{_DEMO_PREFIX}神秘礼盒",
            "category": "其他",
            "last_used_at": None,
            "created_at": now - timedelta(days=40),
            "expect": "进候选 → 应提醒（从未使用且入库>7天）",
        },
    ]

    created: list[Item] = []
    for spec in specs:
        cat_id = cats.get(spec["category"]) or cats.get("其他")
        if not cat_id:
            raise SystemExit("错误: 缺少分类，无法播种")

        item = Item(
            name=spec["name"],
            category_id=cat_id,
            family_id=family_id,
            created_by=user_id,
            current_quantity=1,
            unit="件",
            status=0,
            last_used_at=spec["last_used_at"],
            notes=f"demo expect: {spec['expect']}",
        )
        session.add(item)
        session.flush()
        # 直接改 created_at（BaseMixin 可能有默认值）
        item.created_at = spec["created_at"]
        created.append(item)
        idle = (
            "从未使用"
            if spec["last_used_at"] is None
            else f"上次使用 {(now - spec['last_used_at']).days} 天前"
        )
        print(f"  + {spec['name']}")
        print(f"      分类={spec['category']} | {idle} | 预期: {spec['expect']}")

    session.commit()
    return created


def _print_idle_notifications(session, family_id: int) -> int:
    """打印当前家庭的 idle 通知，返回条数。"""
    rows = session.execute(
        select(Notification, Item.name)
        .join(Item, Item.id == Notification.item_id, isouter=True)
        .where(
            Notification.family_id == family_id,
            Notification.type == Notification.TYPE_IDLE,
        )
        .order_by(Notification.created_at.desc())
    ).all()

    print()
    print("=" * 60)
    print("  通知中心效果预览（type=idle）")
    print("=" * 60)
    if not rows:
        print("  （暂无 idle 通知）")
        print("  提示: 候选物品可能未达到筛选阈值，或 AI/默认规则判定 need_remind=false")
        return 0

    for i, (n, item_name) in enumerate(rows, 1):
        print(f"\n  [{i}] {n.title}")
        print(f"      物品: {item_name or n.item_id}")
        print(f"      文案: {n.body}")
        print(f"      优先级: {n.priority} | 已读: {n.is_read}")
        print(f"      跳转: {n.action_url}")
        print(f"      时间: {n.created_at}")

    print()
    print("-" * 60)
    print(f"  共 {len(rows)} 条 idle 提醒")
    print("  客户端：同步物品后打开「通知中心 / 提醒」，可看到长期未使用行")
    print("  有网时会拉取上述 AI/默认文案覆盖本地描述")
    print("=" * 60)
    return len(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description="演示长时间未使用提醒")
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="仅清理演示物品与关联 idle 通知",
    )
    parser.add_argument(
        "--no-seed",
        action="store_true",
        help="不播种，只对现有数据跑任务",
    )
    args = parser.parse_args()

    session = get_sync_session()
    try:
        family_id, user_id = _pick_family_and_user(session)
        print(f"家庭 id={family_id}  用户 id={user_id}")

        if args.cleanup:
            print("\n[清理演示数据]")
            _cleanup_demo(session, family_id)
            return

        if not args.no_seed:
            print("\n[1/3] 准备分类 & 播种演示物品")
            # 先清旧演示，避免重复堆积
            _cleanup_demo(session, family_id)
            cats = _ensure_categories(session)
            _seed_demo_items(session, family_id, user_id, cats)
        else:
            print("\n[1/3] 跳过播种（--no-seed）")

        print("\n[2/3] 执行 generate_idle_reminders() …")
        print("      （有 DEEPSEEK_API_KEY 则走 AI；否则走分类默认规则）")
        # 关闭本脚本 session，避免与任务内 session 抢锁（SQLite）
        session.close()
        generate_idle_reminders()

        session = get_sync_session()
        print("\n[3/3] 读取结果")
        count = _print_idle_notifications(session, family_id)
        if count == 0:
            sys.exit(2)
    finally:
        session.close()


if __name__ == "__main__":
    main()
