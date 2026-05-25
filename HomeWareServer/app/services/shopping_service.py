"""
购物清单服务模块
实现购物清单相关业务逻辑
"""
import logging
from datetime import date, datetime
from typing import Dict, List, Optional

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item
from app.models.shopping import ShoppingItem
from app.repositories.shopping_repo import ShoppingRepository

logger = logging.getLogger(__name__)


class ShoppingService:
    """购物清单服务"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.repo = ShoppingRepository(db)

    async def get_shopping_list(
        self,
        family_id: int,
        status: str = "all",
        page: int = 1,
        page_size: int = 20
    ) -> Dict:
        """
        获取购物清单（分页）
        :param family_id: 家庭ID
        :param status: 状态筛选: pending/purchased/all
        :param page: 页码
        :param page_size: 每页大小
        :return: 分页结果
        """
        return await self.repo.get_list(family_id, status, page, page_size)

    async def create_shopping_item(
        self,
        family_id: int,
        user_id: int,
        name: str,
        quantity: float = 1,
        unit: str = "件",
        estimated_price: Optional[float] = None,
        related_item_id: Optional[int] = None
    ) -> ShoppingItem:
        """
        创建购物项
        :param family_id: 家庭ID
        :param user_id: 用户ID
        :param name: 物品名称
        :param quantity: 数量
        :param unit: 单位
        :param estimated_price: 预估价格
        :param related_item_id: 关联物品ID
        :return: 创建的购物项
        """
        shopping_item = await self.repo.create({
            "name": name,
            "quantity": quantity,
            "unit": unit,
            "estimated_price": estimated_price,
            "related_item_id": related_item_id,
            "family_id": family_id,
            "created_by": user_id
        })

        logger.info(f"创建购物项: {name}")
        return shopping_item

    async def mark_as_purchased(
        self,
        item_id: int,
        user_id: int,
        actual_price: Optional[float] = None
    ) -> Dict:
        """
        标记为已购买
        :param item_id: 购物项ID
        :param user_id: 用户ID
        :param actual_price: 实际价格
        :return: 结果字典，包含是否需要提示入库
        """
        # 获取购物项
        shopping_item = await self.db.get(ShoppingItem, item_id)
        if not shopping_item:
            return {"success": False, "message": "购物项不存在", "need_inventory": False}

        # 更新购物项
        update_data = {
            "is_purchased": True,
            "purchased_by": user_id,
            "purchased_at": datetime.now()
        }
        if actual_price is not None:
            update_data["estimated_price"] = actual_price

        await self.repo.update(item_id, update_data)

        # 检查是否需要提示入库
        need_inventory = False
        if shopping_item.related_item_id:
            related_item = await self.db.get(Item, shopping_item.related_item_id)
            if related_item and related_item.status == 1:  # 用完状态
                need_inventory = True

        logger.info(f"标记购物项 {item_id} 为已购买")
        return {
            "success": True,
            "message": "标记成功",
            "need_inventory": need_inventory,
            "related_item_id": shopping_item.related_item_id
        }

    async def to_item(
        self,
        shopping_item_id: int,
        user_id: int,
        location_id: Optional[int] = None,
        expiry_date: Optional[date] = None
    ) -> Optional[Item]:
        """
        从已购物品一键创建入库
        :param shopping_item_id: 购物项ID
        :param user_id: 用户ID
        :param location_id: 位置ID（可选）
        :param expiry_date: 过期日期（可选）
        :return: 创建的物品
        """
        # 获取购物项
        shopping_item = await self.db.get(ShoppingItem, shopping_item_id)
        if not shopping_item or not shopping_item.is_purchased:
            return None

        # 如果有关联物品，复制信息
        new_item = None
        if shopping_item.related_item_id:
            related_item = await self.db.get(Item, shopping_item.related_item_id)
            if related_item:
                # 复制关联物品信息创建新物品
                new_item = Item(
                    name=related_item.name,
                    brand=related_item.brand,
                    specification=related_item.specification,
                    barcode=related_item.barcode,
                    category_id=related_item.category_id,
                    location_id=location_id or related_item.location_id,
                    family_id=related_item.family_id,
                    purchase_price=shopping_item.estimated_price or related_item.purchase_price,
                    total_price=None,
                    purchase_quantity=int(shopping_item.quantity),
                    current_quantity=shopping_item.quantity,
                    unit=shopping_item.unit or related_item.unit,
                    safety_stock=related_item.safety_stock,
                    purchase_date=date.today(),
                    expiry_date=expiry_date or related_item.expiry_date,
                    shelf_life_days=related_item.shelf_life_days,
                    expiry_alert_days=related_item.expiry_alert_days,
                    stock_alert=related_item.stock_alert,
                    notes=related_item.notes,
                    status=0,
                    created_by=user_id
                )
                self.db.add(new_item)
                await self.db.commit()
                await self.db.refresh(new_item)

                # 如果原物品状态为1（用完），更新为使用中
                if related_item.status == 1:
                    related_item.status = 0
                    related_item.current_quantity = shopping_item.quantity
                    await self.db.commit()
        else:
            # 创建新物品（无关联物品）
            new_item = Item(
                name=shopping_item.name,
                category_id=None,
                location_id=location_id,
                family_id=shopping_item.family_id,
                purchase_price=shopping_item.estimated_price,
                purchase_quantity=int(shopping_item.quantity),
                current_quantity=shopping_item.quantity,
                unit=shopping_item.unit,
                purchase_date=date.today(),
                expiry_date=expiry_date,
                status=0,
                created_by=user_id
            )
            self.db.add(new_item)
            await self.db.commit()
            await self.db.refresh(new_item)

        logger.info(f"从购物项 {shopping_item_id} 创建物品 {new_item.id}")
        return new_item

    async def mark_all_purchased(self, family_id: int, user_id: int) -> int:
        """
        全部标记已购买
        :param family_id: 家庭ID
        :param user_id: 用户ID
        :return: 更新数量
        """
        result = await self.db.execute(
            update(ShoppingItem)
            .filter(ShoppingItem.family_id == family_id, ShoppingItem.is_purchased == False)
            .values({
                "is_purchased": True,
                "purchased_by": user_id,
                "purchased_at": datetime.now()
            })
        )
        await self.db.commit()

        count = result.rowcount
        logger.info(f"批量标记 {count} 个购物项为已购买")
        return count

    async def generate_share_text(self, family_id: int) -> Dict:
        """
        生成分享文本
        :param family_id: 家庭ID
        :return: 分享文本和总价
        """
        # 获取未购买的购物项
        result = await self.db.execute(
            select(ShoppingItem)
            .filter(ShoppingItem.family_id == family_id, ShoppingItem.is_purchased == False)
        )
        items = result.scalars().all()

        if not items:
            return {"text": "📋 购物清单为空", "total_estimated": 0.0}

        today = date.today().strftime("%Y-%m-%d")
        lines = [f"📋 购物清单 ({today})"]

        total_estimated = 0.0
        for item in items:
            line = f"- {item.name} {item.unit} ×{int(item.quantity) if item.quantity == int(item.quantity) else item.quantity}"
            if item.estimated_price:
                line += f"  ¥{item.estimated_price}"
                total_estimated += float(item.estimated_price) * float(item.quantity)
            lines.append(line)

        # 添加总价
        lines.append(f"\n💰 预估总计: ¥{total_estimated:.2f}")

        return {
            "text": "\n".join(lines),
            "total_estimated": total_estimated
        }

    async def get_recommendations(self, family_id: int) -> List[Dict]:
        """
        获取智能购物推荐
        逻辑：
        1. 已低于安全库存 → 推荐（优先级高）
        2. 预计7天内用完 → 推荐（优先级中）
        3. 预计14天内用完 → 推荐（优先级低）
        过滤掉已在购物清单中的
        :param family_id: 家庭ID
        :return: 推荐列表
        """
        today = date.today()

        # 获取正在使用的物品
        result = await self.db.execute(
            select(Item)
            .filter(Item.family_id == family_id, Item.status == 0)
        )
        items = result.scalars().all()

        # 获取已在购物清单中的物品ID
        shopping_result = await self.db.execute(
            select(ShoppingItem.related_item_id)
            .filter(ShoppingItem.family_id == family_id, ShoppingItem.is_purchased == False)
        )
        shopping_item_ids = {row[0] for row in shopping_result.all() if row[0]}

        recommendations = []

        for item in items:
            # 跳过已在购物清单中的物品
            if item.id in shopping_item_ids:
                continue

            current_qty = float(item.current_quantity)
            safety_stock = float(item.safety_stock)
            priority = None
            reason = None

            # 判断优先级
            if current_qty <= safety_stock:
                priority = "high"
                reason = "库存低于安全线"
            elif item.predicted_empty_date:
                days_until_empty = (item.predicted_empty_date - today).days
                if days_until_empty <= 7:
                    priority = "high"
                    reason = f"预计{days_until_empty}天后用完"
                elif days_until_empty <= 14:
                    priority = "medium"
                    reason = f"预计{days_until_empty}天后用完"

            if priority:
                recommendations.append({
                    "item_id": item.id,
                    "item_name": item.name,
                    "reason": reason,
                    "priority": priority,
                    "suggested_quantity": max(1, int(safety_stock * 2 - current_qty)) if current_qty < safety_stock else 1,
                    "suggested_unit": item.unit or "件",
                    "last_price": float(item.purchase_price) if item.purchase_price else None,
                    "last_channel": item.purchase_channel
                })

        # 按优先级排序（high > medium > low）
        priority_order = {"high": 0, "medium": 1, "low": 2}
        recommendations.sort(key=lambda x: priority_order.get(x["priority"], 3))

        logger.info(f"生成 {len(recommendations)} 个购物推荐")
        return recommendations
