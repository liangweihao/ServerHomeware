"""
Celery 定时任务模块
实现各类定时检查任务
"""
import json
import logging
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import select, update, func
from sqlalchemy.orm import Session

from app.config import settings
from app.models.item import Item
from app.models.notification import Notification
from app.models.shopping import ShoppingItem
from app.models.user_device import UserDevice
from app.repositories.notification_repo import NotificationRepository
from app.tasks.celery_app import celery

logger = logging.getLogger(__name__)


def get_sync_session():
    """获取同步数据库会话（Celery 任务专用，去掉 async driver）"""
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker

    url = settings.DATABASE_URL
    # Celery 同步任务不能使用 aiosqlite / asyncpg
    if url.startswith("sqlite+aiosqlite://"):
        url = url.replace("sqlite+aiosqlite://", "sqlite://", 1)
    elif url.startswith("postgresql+asyncpg://"):
        url = url.replace("postgresql+asyncpg://", "postgresql://", 1)

    engine = create_engine(url)
    SessionLocal = sessionmaker(bind=engine)
    return SessionLocal()


@celery.task
def check_expiry():
    """
    每天早上8:00执行
    检查即将过期物品并发送通知
    """
    logger.info("开始执行过期检查任务")

    session = get_sync_session()
    try:
        today = date.today()

        # 查询所有即将过期的物品
        result = session.execute(
            select(
                Item.id,
                Item.name,
                Item.family_id,
                Item.expiry_date,
                Item.expiry_alert_days
            )
            .filter(
                Item.status == 0,
                Item.expiry_date.isnot(None)
            )
        )
        items = result.all()

        notification_repo = NotificationRepository(session)

        for item in items:
            item_id, item_name, family_id, expiry_date, expiry_alert_days = item

            if not expiry_date:
                continue

            days_until_expiry = (expiry_date - today).days

            # 检查是否在提醒范围内
            if days_until_expiry > expiry_alert_days:
                continue

            # 检查今天是否已发送过该通知
            is_sent = notification_repo.check_sent_today(family_id, item_id, Notification.TYPE_EXPIRY)
            if is_sent:
                logger.info(f"物品 {item_name} 今天已发送过期通知，跳过")
                continue

            # 确定优先级和消息
            if days_until_expiry < 0:
                priority = Notification.PRIORITY_HIGH
                title = "⚠️ 物品已过期"
                body = f"{item_name} 已过期{abs(days_until_expiry)}天，请及时处理"
            elif days_until_expiry == 0:
                priority = Notification.PRIORITY_HIGH
                title = "⚠️ 物品今天过期"
                body = f"{item_name} 今天过期，请尽快处理"
            elif days_until_expiry <= 3:
                priority = Notification.PRIORITY_HIGH
                title = "⚠️ 物品即将过期"
                body = f"{item_name} 还剩{days_until_expiry}天过期，请及时处理"
            else:
                priority = Notification.PRIORITY_MEDIUM
                title = "📅 物品即将过期"
                body = f"{item_name} 还剩{days_until_expiry}天过期"

            # 创建通知
            notification = Notification(
                family_id=family_id,
                type=Notification.TYPE_EXPIRY,
                title=title,
                body=body,
                item_id=item_id,
                priority=priority,
                action_url=f"/items/{item_id}"
            )
            session.add(notification)
            session.commit()

            # 发送推送
            _send_push_to_family(
                session=session,
                family_id=family_id,
                title=title,
                body=body,
                data={
                    "type": Notification.TYPE_EXPIRY,
                    "item_id": str(item_id),
                    "route": f"/items/{item_id}"
                }
            )

            logger.info(f"已创建过期通知: {item_name}, {days_until_expiry}天后过期")

    except Exception as e:
        logger.error(f"过期检查任务失败: {e}")
        session.rollback()
    finally:
        session.close()

    logger.info("过期检查任务完成")


@celery.task
def auto_expire_items():
    """
    每天凌晨1:00执行
    自动将已过期物品状态改为2（已用完/已过期）
    """
    logger.info("开始执行自动过期任务")

    session = get_sync_session()
    try:
        today = date.today()

        # 更新已过期物品状态
        result = session.execute(
            update(Item)
            .where(
                Item.status == 0,
                Item.expiry_date.isnot(None),
                Item.expiry_date < today
            )
            .values(status=2)
        )
        session.commit()

        updated_count = result.rowcount
        logger.info(f"自动过期任务完成，更新了 {updated_count} 个物品状态")

    except Exception as e:
        logger.error(f"自动过期任务失败: {e}")
        session.rollback()
    finally:
        session.close()


@celery.task
def generate_shopping_suggestions():
    """
    每天早上9:00执行
    自动生成购物推荐到购物清单
    """
    logger.info("开始执行购物推荐生成任务")

    session = get_sync_session()
    try:
        today = date.today()
        seven_days_later = today + timedelta(days=7)

        # 查询所有库存不足或即将用完的物品
        result = session.execute(
            select(
                Item.id,
                Item.name,
                Item.family_id,
                Item.current_quantity,
                Item.safety_stock,
                Item.unit,
                Item.category_id
            )
            .filter(
                Item.status == 0,
                Item.stock_alert == True,
                Item.current_quantity <= Item.safety_stock
            )
        )
        items = result.all()

        for item in items:
            item_id, item_name, family_id, current_qty, safety_stock, unit, category_id = item

            # 检查是否已在购物清单中（未购买）
            existing = session.execute(
                select(ShoppingItem)
                .filter(
                    ShoppingItem.related_item_id == item_id,
                    ShoppingItem.is_purchased == False,
                    ShoppingItem.deleted_at.is_(None),
                )
            ).scalar_one_or_none()

            if existing:
                logger.info(f"物品 {item_name} 已在购物清单中，跳过")
                continue

            # 创建购物推荐
            shopping = ShoppingItem(
                family_id=family_id,
                name=item_name,
                related_item_id=item_id,
                quantity=max(1, int(safety_stock * 2 - current_qty)) if current_qty < safety_stock else 1,
                is_auto_generated=True,
                is_purchased=False,
            )
            session.add(shopping)
            session.commit()

            logger.info(f"已生成购物推荐: {item_name}")

        logger.info("购物推荐生成任务完成")

    except Exception as e:
        logger.error(f"购物推荐生成任务失败: {e}")
        session.rollback()
    finally:
        session.close()


@celery.task
def update_predictions():
    """
    每天凌晨2:00执行
    批量更新消耗预测
    """
    logger.info("开始执行消耗预测更新任务")

    session = get_sync_session()
    try:
        from sqlalchemy import select

        # 获取所有家庭ID
        from app.models.family import Family
        result = session.execute(select(Family.id))
        family_ids = [row[0] for row in result.all()]

        # 为每个家庭更新预测
        for family_id in family_ids:
            try:
                # 使用异步服务的同步版本逻辑
                _update_family_predictions(session, family_id)
            except Exception as e:
                logger.error(f"更新家庭 {family_id} 预测失败: {e}")

        logger.info("消耗预测更新任务完成")

    except Exception as e:
        logger.error(f"消耗预测更新任务失败: {e}")
        session.rollback()
    finally:
        session.close()


def _update_family_predictions(session, family_id: int):
    """
    更新单个家庭的物品消耗预测
    :param session: 数据库会话
    :param family_id: 家庭ID
    """
    from datetime import date, timedelta
    from sqlalchemy import select, func

    # 查询所有使用中的物品
    result = session.execute(
        select(Item)
        .filter(Item.family_id == family_id, Item.status == 0)
    )
    items = result.scalars().all()

    for item in items:
        try:
            # 计算日均消耗
            avg_daily = _calculate_avg_daily_consumption(session, item.id, item)

            # 预测用完日期
            empty_date = None
            if avg_daily > 0:
                current_qty = float(item.current_quantity)
                if current_qty > 0:
                    days_remaining = current_qty / avg_daily
                    empty_date = date.today() + timedelta(days=days_remaining)

            # 更新物品预测字段
            item.avg_daily_consumption = avg_daily
            item.predicted_empty_date = empty_date

        except Exception as e:
            logger.error(f"更新物品 {item.id} 预测失败: {e}")

    session.commit()


def _calculate_avg_daily_consumption(session, item_id: int, item) -> float:
    """
    计算物品日均消耗量（同步版本）
    :param session: 数据库会话
    :param item_id: 物品ID
    :param item: 物品对象
    :return: 日均消耗量
    """
    from sqlalchemy import select

    # 查询使用记录（type=1）
    result = session.execute(
        select(Notification)
        .filter(Notification.item_id == item_id, Notification.type == 1)
        .order_by(Notification.created_at.asc())
    )
    usage_records = result.scalars().all()

    # 查询使用记录（type=1）
    from app.models.usage_record import UsageRecord
    result = session.execute(
        select(UsageRecord)
        .filter(UsageRecord.item_id == item_id, UsageRecord.type == 1)
        .order_by(UsageRecord.created_at.asc())
    )
    usage_records = result.scalars().all()

    if len(usage_records) < 2:
        # 记录不足，使用购买量和当前量计算
        if not item.created_at:
            return 0.0

        today = date.today()
        days = (today - item.created_at.date()).days

        if days <= 0:
            return 0.0

        consumed = item.purchase_quantity - float(item.current_quantity)
        if consumed <= 0:
            return 0.0

        return consumed / days

    # 加权平均法计算
    total_rate = 0.0
    total_weight = 0.0

    for i in range(len(usage_records) - 1):
        current_record = usage_records[i]
        next_record = usage_records[i + 1]

        interval_days = (next_record.created_at - current_record.created_at).days
        if interval_days <= 0:
            continue

        # 计算消耗速率
        rate = float(next_record.quantity) / interval_days
        if rate <= 0:
            continue

        # 权重：越近的记录权重越高
        weight = i + 1
        total_rate += rate * weight
        total_weight += weight

    if total_weight <= 0:
        return 0.0

    return total_rate / total_weight


@celery.task
def clean_old_notifications():
    """
    每周日凌晨3:00执行
    清理30天前的通知记录
    """
    logger.info("开始执行旧通知清理任务")

    session = get_sync_session()
    try:
        cutoff_date = datetime.now() - timedelta(days=30)

        # 删除旧通知
        result = session.execute(
            select(Notification)
            .filter(Notification.created_at < cutoff_date)
        )
        notifications = result.scalars().all()

        count = len(notifications)
        for notification in notifications:
            session.delete(notification)

        session.commit()

        logger.info(f"旧通知清理完成，删除了 {count} 条通知记录")

    except Exception as e:
        logger.error(f"旧通知清理任务失败: {e}")
        session.rollback()
    finally:
        session.close()


def _send_push_to_family(session, family_id: int, title: str, body: str, data: dict):
    """
    向家庭所有成员发送推送
    :param session: 数据库会话
    :param family_id: 家庭ID
    :param title: 标题
    :param body: 内容
    :param data: 自定义数据
    """
    from app.models.family import FamilyMember

    try:
        # 获取家庭所有成员
        result = session.execute(
            select(FamilyMember.user_id).filter(FamilyMember.family_id == family_id)
        )
        user_ids = [row[0] for row in result.all()]

        for user_id in user_ids:
            _send_push_to_user(session, user_id, title, body, data)

    except Exception as e:
        logger.error(f"向家庭推送失败: {e}")


def _send_push_to_user(session, user_id: int, title: str, body: str, data: dict):
    """
    向用户发送推送
    :param session: 数据库会话
    :param user_id: 用户ID
    :param title: 标题
    :param body: 内容
    :param data: 自定义数据
    """
    if not settings.FCM_SERVER_KEY:
        logger.warning("FCM_SERVER_KEY 未配置，跳过推送")
        return

    try:
        # 获取用户设备
        result = session.execute(
            select(UserDevice).filter(UserDevice.user_id == user_id)
        )
        devices = result.scalars().all()

        if not devices:
            logger.info(f"用户 {user_id} 没有注册设备")
            return

        import requests

        for device in devices:
            try:
                headers = {
                    "Authorization": f"key={settings.FCM_SERVER_KEY}",
                    "Content-Type": "application/json"
                }

                payload = {
                    "notification": {
                        "title": title,
                        "body": body,
                        "sound": "default"
                    },
                    "data": data,
                    "to": device.device_token
                }

                response = requests.post(
                    "https://fcm.googleapis.com/fcm/send",
                    headers=headers,
                    json=payload,
                    timeout=10
                )

                if response.status_code == 200:
                    result_data = response.json()
                    if result_data.get("success", 0) > 0:
                        logger.info(f"推送成功: 用户 {user_id}")
                    else:
                        error = result_data.get("results", [{}])[0].get("error", "Unknown")
                        logger.warning(f"推送失败: {error}")
                        # 如果 token 失效，删除该设备记录
                        if error in ["InvalidRegistration", "NotRegistered"]:
                            session.delete(device)
                            session.commit()
                            logger.info(f"删除失效设备: {device.id}")
                else:
                    logger.error(f"FCM 请求失败: {response.status_code}")

            except Exception as e:
                logger.error(f"推送异常: {e}")

    except Exception as e:
        logger.error(f"向用户推送失败: {e}")


# ──────────────────────────────────────────────────────────────────────────────
# 长期未使用提醒（idle reminder）
# ──────────────────────────────────────────────────────────────────────────────

# 候选物品筛选阈值
_IDLE_NEVER_USED_DAYS = 7    # 入库后从未使用，超过 N 天触发候选
_IDLE_LAST_USED_DAYS = 30    # 最后一次使用距今超过 N 天触发候选
_IDLE_MAX_CANDIDATES = 30    # 每个家庭最多打包送给 AI 的物品数量


def _as_naive_utc(dt: datetime | None) -> datetime | None:
    """将 datetime 统一为 naive UTC，避免 aware/naive 相减报错。"""
    if dt is None:
        return None
    if dt.tzinfo is not None:
        return dt.astimezone(timezone.utc).replace(tzinfo=None)
    return dt


def _get_current_season() -> str:
    """根据月份返回当前季节（北半球）"""
    month = date.today().month
    if month in (3, 4, 5):
        return "春季"
    if month in (6, 7, 8):
        return "夏季"
    if month in (9, 10, 11):
        return "秋季"
    return "冬季"


def _idle_threshold_for_item(category: str, name: str) -> int:
    """
    AI 不可用时的分类默认阈值（天）。
    与 _build_idle_prompt 中的规则保持一致，避免降级时对清洁品等误报。
    """
    text = f"{category or ''}{name or ''}"
    if any(k in text for k in ("食材", "生鲜", "食品", "饮料", "水果", "蔬菜", "肉")):
        return 3
    if any(k in text for k in ("洗发水", "牙膏", "沐浴露", "护肤", "个护")):
        return 14
    if any(k in text for k in ("清洁", "卫生", "洗衣液", "消毒液")):
        return 60
    if any(k in text for k in ("电子", "数码", "电器", "设备", "手机", "电脑")):
        return 90
    if any(k in text for k in ("防晒", "暖宝宝", "羽绒服", "电热毯", "蚊帐")):
        # 季节性：默认 30 天，具体季节判断交给 AI；降级时保守提醒
        return 30
    return 30


def _default_idle_result(prompt_item: dict) -> dict:
    """按分类阈值生成默认 idle 判定结果。"""
    idle_days = int(prompt_item.get("idle_days") or 0)
    name = prompt_item.get("name") or ""
    category = prompt_item.get("category") or ""
    threshold = _idle_threshold_for_item(category, name)
    need = idle_days >= threshold
    urgency = 1 if idle_days >= 90 else 2 if idle_days >= 30 else 3
    return {
        "item_id": prompt_item["item_id"],
        "need_remind": need,
        "message": f"「{name}」已{idle_days}天没有使用记录，还在吗？" if need else "",
        "urgency": urgency if need else 3,
    }


def _call_deepseek_sync(prompt: str) -> str | None:
    """
    同步调用 DeepSeek API（供 Celery 任务使用）。
    返回模型输出的原始文本，失败返回 None。
    """
    import httpx

    api_key = getattr(settings, "DEEPSEEK_API_KEY", None)
    base_url = getattr(settings, "DEEPSEEK_BASE_URL", "https://api.deepseek.com")
    model = getattr(settings, "DEEPSEEK_MODEL", "deepseek-chat")
    timeout = getattr(settings, "DEEPSEEK_TIMEOUT_SECONDS", 30)

    if not api_key or not api_key.startswith("sk-"):
        logger.warning("DEEPSEEK_API_KEY 未配置，跳过 AI 判断")
        return None

    url = f"{base_url}/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 1024,
        "temperature": 0.3,
    }

    try:
        with httpx.Client(timeout=timeout, trust_env=False) as client:
            resp = client.post(url, headers=headers, json=payload)
            resp.raise_for_status()
            return resp.json()["choices"][0]["message"]["content"]
    except Exception as e:
        logger.error("DeepSeek 调用失败: %s", e)
        return None


def _build_idle_prompt(family_candidates: list[dict], season: str) -> str:
    """
    构建发送给 DeepSeek 的 prompt。
    family_candidates: [{"item_id": int, "name": str, "category": str,
                          "purchase_date": str, "last_used_at": str,
                          "idle_days": int}]
    """
    items_json = json.dumps(family_candidates, ensure_ascii=False)
    return f"""你是一个家庭物品管理助手。当前季节：{season}。

以下是用户家庭中长时间未使用的物品清单（JSON 格式）：
{items_json}

请分析每件物品，判断是否需要提醒用户，并给出提醒文案。

判断规则：
1. 食材/生鲜类：入库超过 3 天未使用即可提醒
2. 清洁/卫生用品：超过 60 天未使用才提醒
3. 季节性物品（防晒、暖宝宝、羽绒服等）：结合当前季节判断，当季未用才提醒
4. 电子产品/设备：超过 90 天未用才提醒
5. 日常消耗品（洗发水、牙膏等）：超过 14 天未使用才提醒
6. 其他物品：超过 30 天未使用才提醒

提醒文案要求：口语化、亲切，不超过 30 字，带物品名称。

请严格以 JSON 数组返回，不要有其他文字：
[
  {{
    "item_id": <物品ID整数>,
    "need_remind": <true 或 false>,
    "message": "<提醒文案，need_remind=false 时可为空字符串>",
    "urgency": <1=高/2=中/3=低，need_remind=false 时填 3>
  }}
]"""


def _backfill_last_used_at(session: Session) -> int:
    """
    将仍为 NULL 的 last_used_at 用历史 type=1 使用记录回填。
    返回更新行数（近似）。
    """
    from app.models.usage_record import UsageRecord

    # 子查询：每个 item 最近一次使用时间
    subq = (
        select(
            UsageRecord.item_id.label("item_id"),
            func.max(UsageRecord.created_at).label("max_used"),
        )
        .where(UsageRecord.type == 1)
        .group_by(UsageRecord.item_id)
        .subquery()
    )
    result = session.execute(
        select(Item.id, subq.c.max_used)
        .join(subq, Item.id == subq.c.item_id)
        .where(Item.last_used_at.is_(None))
    )
    rows = result.all()
    for item_id, max_used in rows:
        session.execute(
            update(Item).where(Item.id == item_id).values(last_used_at=max_used)
        )
    if rows:
        session.commit()
        logger.info("idle 回填 last_used_at: %d 条", len(rows))
    return len(rows)


@celery.task
def generate_idle_reminders():
    """
    每天凌晨 03:30 执行。
    对每个家庭检测长期未使用物品，调用 DeepSeek 判断是否需要提醒，
    结果 upsert 写入 notifications 表（type='idle'）。
    """
    logger.info("开始执行长期未使用提醒生成任务")

    session = get_sync_session()
    try:
        from app.models.category import Category
        from app.models.family import Family

        # 幂等回填：迁移已跑过但数据未填时仍可补齐
        try:
            _backfill_last_used_at(session)
        except Exception as e:
            logger.warning("last_used_at 回填跳过: %s", e)
            session.rollback()

        season = _get_current_season()
        now = datetime.now(timezone.utc)
        now_naive = _as_naive_utc(now)
        never_used_threshold = now - timedelta(days=_IDLE_NEVER_USED_DAYS)
        last_used_threshold = now - timedelta(days=_IDLE_LAST_USED_DAYS)
        # 「今日」起点用 UTC 零点，与 created_at 存储约定对齐
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        today_start_naive = _as_naive_utc(today_start)

        # 获取所有家庭 ID
        family_ids = [row[0] for row in session.execute(select(Family.id)).all()]

        for family_id in family_ids:
            try:
                # 查询候选物品：status=0 且 (last_used_at 为空且入库超 7 天) 或 (last_used_at < 30 天前)
                result = session.execute(
                    select(
                        Item.id,
                        Item.name,
                        Item.created_at,
                        Item.last_used_at,
                        Category.name.label("category_name"),
                    )
                    .join(Category, Item.category_id == Category.id, isouter=True)
                    .filter(
                        Item.family_id == family_id,
                        Item.status == 0,
                        Item.deleted_at.is_(None),
                    )
                    .filter(
                        # 从未使用 + 入库超 7 天，或上次使用超 30 天
                        (
                            (Item.last_used_at.is_(None))
                            & (Item.created_at < never_used_threshold)
                        )
                        | (Item.last_used_at < last_used_threshold)
                    )
                    .order_by(Item.last_used_at.asc().nullsfirst())
                    .limit(_IDLE_MAX_CANDIDATES)
                )
                candidates = result.all()

                if not candidates:
                    logger.info("家庭 %s 无长期未使用物品，跳过", family_id)
                    continue

                # 组装 prompt 所需数据
                prompt_items = []
                for row in candidates:
                    item_id, name, created_at, last_used_at, category_name = row
                    created_naive = _as_naive_utc(created_at)
                    last_used_naive = _as_naive_utc(last_used_at)
                    if last_used_naive and now_naive:
                        idle_days = (now_naive - last_used_naive).days
                        last_used_str = last_used_naive.strftime("%Y-%m-%d")
                    else:
                        idle_days = (
                            (now_naive - created_naive).days
                            if now_naive and created_naive
                            else 0
                        )
                        last_used_str = "从未使用"
                    prompt_items.append({
                        "item_id": item_id,
                        "name": name,
                        "category": category_name or "其他",
                        "purchase_date": created_naive.strftime("%Y-%m-%d") if created_naive else "",
                        "last_used_at": last_used_str,
                        "idle_days": idle_days,
                    })

                # 调用 DeepSeek
                prompt = _build_idle_prompt(prompt_items, season)
                raw_response = _call_deepseek_sync(prompt)

                if raw_response:
                    # 解析 JSON 结果
                    try:
                        # 提取 JSON 数组（模型可能在前后加说明文字）
                        start = raw_response.find("[")
                        end = raw_response.rfind("]") + 1
                        ai_results = json.loads(raw_response[start:end]) if start >= 0 else []
                    except (json.JSONDecodeError, ValueError) as e:
                        logger.error(
                            "解析 AI 返回失败 family=%s: %s | raw=%s",
                            family_id,
                            e,
                            raw_response[:200],
                        )
                        ai_results = [_default_idle_result(p) for p in prompt_items]
                else:
                    # AI 不可用：按分类阈值降级，避免清洁品等误报
                    ai_results = [_default_idle_result(p) for p in prompt_items]
                    logger.info(
                        "家庭 %s 使用分类默认规则，候选 %d 条，需提醒 %d 条",
                        family_id,
                        len(prompt_items),
                        sum(1 for r in ai_results if r.get("need_remind")),
                    )

                # upsert Notification（先删今日旧记录再插入）
                written = 0
                for ai_item in ai_results:
                    if not ai_item.get("need_remind"):
                        continue

                    item_id = ai_item.get("item_id")
                    message = ai_item.get("message", "")
                    urgency = ai_item.get("urgency", 3)
                    priority = (
                        Notification.PRIORITY_HIGH if urgency == 1
                        else Notification.PRIORITY_MEDIUM if urgency == 2
                        else Notification.PRIORITY_LOW
                    )

                    # 删除该物品今日已有的 idle 通知（避免重复堆积）
                    existing = session.execute(
                        select(Notification).filter(
                            Notification.family_id == family_id,
                            Notification.item_id == item_id,
                            Notification.type == Notification.TYPE_IDLE,
                            Notification.created_at >= today_start_naive,
                        )
                    ).scalars().all()
                    for old in existing:
                        session.delete(old)

                    notification = Notification(
                        family_id=family_id,
                        type=Notification.TYPE_IDLE,
                        title="久未使用提醒",
                        body=message,
                        item_id=item_id,
                        priority=priority,
                        action_url=f"/items/{item_id}",
                    )
                    session.add(notification)
                    written += 1

                session.commit()
                logger.info(
                    "家庭 %s idle 提醒生成完成，候选 %d 条，写入 %d 条",
                    family_id,
                    len(candidates),
                    written,
                )

            except Exception as e:
                logger.error("处理家庭 %s idle 提醒失败: %s", family_id, e)
                session.rollback()

    except Exception as e:
        logger.error("generate_idle_reminders 任务失败: %s", e)
        session.rollback()
    finally:
        session.close()

    logger.info("长期未使用提醒生成任务完成")
