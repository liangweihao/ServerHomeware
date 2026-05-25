"""
Celery 定时任务模块
实现各类定时检查任务
"""
import logging
from datetime import date, datetime, timedelta

from sqlalchemy import select, update, func
from sqlalchemy.orm import Session

from app.config import settings
from app.models.item import Item
from app.models.notification import Notification
from app.models.shopping import Shopping
from app.models.user_device import UserDevice
from app.repositories.notification_repo import NotificationRepository
from app.tasks.celery_app import celery

logger = logging.getLogger(__name__)


def get_sync_session():
    """获取同步数据库会话"""
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker

    engine = create_engine(settings.DATABASE_URL)
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
                select(Shopping)
                .filter(
                    Shopping.item_id == item_id,
                    Shopping.is_purchased == False
                )
            ).scalar_one_or_none()

            if existing:
                logger.info(f"物品 {item_name} 已在购物清单中，跳过")
                continue

            # 创建购物推荐
            shopping = Shopping(
                family_id=family_id,
                item_id=item_id,
                quantity=max(1, int(safety_stock * 2 - current_qty)) if current_qty < safety_stock else 1,
                is_auto_generated=True,
                is_purchased=False
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
