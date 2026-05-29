"""
物品服务模块
处理物品相关业务逻辑
"""
import logging
from datetime import date, datetime, timedelta, timezone
from typing import Dict, List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, NotFoundException
from app.models.item import Item
from app.models.usage_record import UsageRecord
from app.repositories.family_repo import FamilyMemberRepository
from app.repositories.item_repo import ItemRepository
from app.repositories.usage_record_repo import UsageRecordRepository

logger = logging.getLogger(__name__)


class ItemService:
    """物品服务"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.item_repo = ItemRepository(db)
        self.family_member_repo = FamilyMemberRepository(db)
        self.usage_repo = UsageRecordRepository(db)
    
    async def _check_family_access(self, user_id: int, family_id: int):
        """检查用户是否有权访问家庭"""
        if not await self.family_member_repo.is_member(user_id, family_id):
            raise ForbiddenException("无权访问该家庭")
    
    async def create_item(self, user_id: int, family_id: int, data: dict) -> Item:
        """
        创建物品
        :param user_id: 用户ID
        :param family_id: 家庭ID
        :param data: 物品数据
        :return: 物品对象
        """
        logger.info(f"创建物品 - 用户ID: {user_id}, 家庭ID: {family_id}")
        
        await self._check_family_access(user_id, family_id)
        
        # 处理数据
        item_data = data.copy()
        
        # 关联图片 URL（Phase 6 上传接口返回的路径）
        image_urls = item_data.pop("image_urls", None)
        
        # 如果没传 current_quantity，默认等于 purchase_quantity
        if "current_quantity" not in item_data or item_data["current_quantity"] is None:
            item_data["current_quantity"] = item_data.get("purchase_quantity", 1)
        
        # 如果传了 production_date + shelf_life_days 但没传 expiry_date，自动计算
        if (item_data.get("production_date") and 
            item_data.get("shelf_life_days") and 
            not item_data.get("expiry_date")):
            prod_date = item_data["production_date"]
            if isinstance(prod_date, date):
                item_data["expiry_date"] = prod_date + timedelta(days=item_data["shelf_life_days"])
        
        # 如果传了 purchase_price + purchase_quantity，自动计算 total_price
        if item_data.get("purchase_price") and item_data.get("purchase_quantity"):
            item_data["total_price"] = item_data["purchase_price"] * item_data["purchase_quantity"]
        
        item_data["family_id"] = family_id
        item_data["created_by"] = user_id
        
        item = await self.item_repo.create(item_data)
        
        if image_urls:
            from app.models.item import ItemImage
            for sort_order, url in enumerate(image_urls):
                self.db.add(ItemImage(
                    item_id=item.id,
                    url=url,
                    sort_order=sort_order,
                ))
            await self.db.flush()
        
        # 插入一条 usage_record（type=0入库）
        await self.usage_repo.create({
            "item_id": item.id,
            "family_id": family_id,
            "type": 0,  # 入库
            "quantity": item.purchase_quantity,
            "remaining_quantity": item.current_quantity,
            "operator_id": user_id,
            "operator_name": "系统"
        })
        
        logger.info(f"物品创建成功 - 物品ID: {item.id}")
        return item
    
    async def get_item(self, user_id: int, item_id: int) -> Dict:
        """
        获取物品详情
        :param user_id: 用户ID
        :param item_id: 物品ID
        :return: 物品详情（含图片列表和最近使用记录）
        """
        item = await self.item_repo.get_by_id_with_relations(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 获取图片列表
        images = []
        for img in item.images:
            images.append({
                "id": img.id,
                "url": img.url,
                "sort_order": img.sort_order
            })
        
        # 获取最近5条使用记录
        usage_records = await self.usage_repo.get_recent_by_item(item.id, limit=5)
        records = []
        for record in usage_records:
            records.append({
                "id": record.id,
                "type": record.type,
                "quantity": float(record.quantity),
                "remaining_quantity": float(record.remaining_quantity),
                "operator_name": record.operator_name,
                "notes": record.notes,
                "created_at": record.created_at
            })
        
        # 获取分类名称和位置完整路径
        category_name = None
        location_full_path = None
        
        if item.category:
            category_name = item.category.name
        if item.location:
            location_full_path = item.location.full_path
        
        return {
            "id": item.id,
            "name": item.name,
            "brand": item.brand,
            "specification": item.specification,
            "barcode": item.barcode,
            "category_id": item.category_id,
            "category_name": category_name,
            "location_id": item.location_id,
            "location_full_path": location_full_path,
            "purchase_price": float(item.purchase_price) if item.purchase_price else None,
            "total_price": float(item.total_price) if item.total_price else None,
            "purchase_quantity": item.purchase_quantity,
            "current_quantity": float(item.current_quantity),
            "unit": item.unit,
            "safety_stock": float(item.safety_stock),
            "purchase_date": item.purchase_date,
            "purchase_channel": item.purchase_channel,
            "production_date": item.production_date,
            "expiry_date": item.expiry_date,
            "shelf_life_days": item.shelf_life_days,
            "opened_date": item.opened_date,
            "after_open_days": item.after_open_days,
            "warranty_date": item.warranty_date,
            "expiry_alert_days": item.expiry_alert_days,
            "stock_alert": item.stock_alert,
            "notes": item.notes,
            "status": item.status,
            "avg_daily_consumption": float(item.avg_daily_consumption) if item.avg_daily_consumption else None,
            "predicted_empty_date": item.predicted_empty_date,
            "created_by": item.created_by,
            "created_at": item.created_at,
            "updated_at": item.updated_at,
            "images": images,
            "usage_records": records
        }
    
    async def get_items(self, user_id: int, family_id: int, params: Dict) -> Dict:
        """
        获取物品列表（分页 + 筛选 + 排序）
        :param user_id: 用户ID
        :param family_id: 家庭ID
        :param params: 查询参数
        :return: 分页结果
        """
        await self._check_family_access(user_id, family_id)
        
        filters = {}
        
        # 状态筛选
        if "status" in params and params["status"] is not None:
            filters["status"] = params["status"]
        
        # 分类筛选
        if "category_id" in params and params["category_id"] is not None:
            filters["category_id"] = params["category_id"]
        
        # 位置筛选
        if "location_id" in params and params["location_id"] is not None:
            filters["location_id"] = params["location_id"]
        
        # 分页参数
        page = params.get("page", 1)
        page_size = params.get("page_size", 20)
        
        # 排序
        sort_by = params.get("sort_by", "created_at")
        sort_order = params.get("sort_order", "desc")
        
        # 获取基础列表
        result = await self.item_repo.get_list(
            filters=filters,
            page=page,
            page_size=page_size,
            order_by=sort_by,
            sort_order=sort_order,
            family_id=family_id
        )
        
        # 获取分类名称和位置路径映射
        category_names = await self.item_repo.get_category_names(family_id)
        location_paths = await self.item_repo.get_location_paths(family_id)
        
        # 处理返回数据
        items = []
        for item in result["items"]:
            # 计算 urgency
            urgency = self._calculate_urgency(item)
            
            items.append({
                "id": item.id,
                "name": item.name,
                "brand": item.brand,
                "category_id": item.category_id,
                "category_name": category_names.get(item.category_id),
                "location_id": item.location_id,
                "location_full_path": location_paths.get(item.location_id),
                "current_quantity": float(item.current_quantity),
                "unit": item.unit,
                "status": item.status,
                "expiry_date": item.expiry_date,
                "urgency": urgency,
                "created_at": item.created_at
            })
        
        return {
            "items": items,
            "total": result["total"],
            "page": result["page"],
            "page_size": result["page_size"],
            "pages": result["pages"]
        }
    
    def _calculate_urgency(self, item: Item) -> int:
        """计算物品紧急程度"""
        # 0=正常, 1=即将过期, 2=库存不足, 3=已过期, 4=已用完
        if item.status == 1:  # 已用完
            return 4
        if item.status == 2:  # 已过期
            return 3
        
        # 检查过期日期
        if item.expiry_date:
            days_until_expiry = (item.expiry_date - date.today()).days
            if days_until_expiry <= 0:
                return 3  # 已过期
            elif days_until_expiry <= item.expiry_alert_days:
                return 1  # 即将过期
        
        # 检查库存
        if item.stock_alert and item.current_quantity <= item.safety_stock:
            return 2  # 库存不足
        
        return 0  # 正常
    
    async def update_item(self, user_id: int, item_id: int, data: dict) -> Item:
        """
        更新物品
        :param user_id: 用户ID
        :param item_id: 物品ID
        :param data: 更新数据
        :return: 更新后的物品对象
        """
        logger.info(f"更新物品 - 用户ID: {user_id}, 物品ID: {item_id}")
        
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 过滤无效字段，只更新传入的字段
        update_data = {}
        allowed_fields = [
            "name", "brand", "specification", "barcode", "category_id", "location_id",
            "purchase_price", "total_price", "purchase_quantity", "current_quantity",
            "unit", "safety_stock", "purchase_date", "purchase_channel",
            "production_date", "expiry_date", "shelf_life_days", "opened_date",
            "after_open_days", "warranty_date", "expiry_alert_days", "stock_alert",
            "notes", "status"
        ]
        
        for key, value in data.items():
            if key in allowed_fields and value is not None:
                update_data[key] = value
        
        # 如果更新了 purchase_price 和 purchase_quantity，重新计算 total_price
        if "purchase_price" in update_data and "purchase_quantity" in update_data:
            update_data["total_price"] = update_data["purchase_price"] * update_data["purchase_quantity"]
        
        item = await self.item_repo.update(item_id, update_data)
        
        logger.info(f"物品更新成功 - 物品ID: {item_id}")
        return item
    
    async def delete_item(self, user_id: int, item_id: int):
        """
        删除物品
        :param user_id: 用户ID
        :param item_id: 物品ID
        """
        logger.info(f"删除物品 - 用户ID: {user_id}, 物品ID: {item_id}")
        
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 物理删除（因为有级联删除配置）
        await self.item_repo.hard_delete(item_id)
        
        logger.info(f"物品删除成功 - 物品ID: {item_id}")
    
    async def use_item(self, user_id: int, item_id: int, quantity: float, operator_name: Optional[str] = None) -> Dict:
        """
        记录物品使用
        :param user_id: 用户ID
        :param item_id: 物品ID
        :param quantity: 使用数量
        :param operator_name: 操作人名称
        :return: 更新后的物品信息
        """
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 更新当前数量
        new_quantity = float(item.current_quantity) - quantity
        if new_quantity < 0:
            new_quantity = 0
        
        # 检查是否需要更新状态
        status = item.status
        if new_quantity <= 0:
            status = 1  # 已用完
        
        # 更新物品
        await self.item_repo.update(item_id, {
            "current_quantity": new_quantity,
            "status": status
        })
        
        # 插入使用记录
        await self.usage_repo.create({
            "item_id": item.id,
            "family_id": item.family_id,
            "type": 1,  # 使用
            "quantity": quantity,
            "remaining_quantity": new_quantity,
            "operator_id": user_id,
            "operator_name": operator_name or "系统"
        })
        
        # 更新日均消耗量和预计用完日期
        await self._update_consumption_stats(item_id)
        
        # 返回更新后的物品信息
        return await self.get_item(user_id, item_id)
    
    async def finish_item(self, user_id: int, item_id: int) -> Dict:
        """
        标记物品用完
        :param user_id: 用户ID
        :param item_id: 物品ID
        :return: 更新后的物品信息
        """
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 更新状态
        await self.item_repo.update(item_id, {
            "current_quantity": 0,
            "status": 1  # 已用完
        })
        
        # 插入使用记录
        await self.usage_repo.create({
            "item_id": item.id,
            "family_id": item.family_id,
            "type": 1,  # 使用
            "quantity": item.current_quantity,
            "remaining_quantity": 0,
            "operator_id": user_id,
            "operator_name": "系统"
        })
        
        return await self.get_item(user_id, item_id)
    
    async def discard_item(self, user_id: int, item_id: int) -> Dict:
        """
        标记物品丢弃
        :param user_id: 用户ID
        :param item_id: 物品ID
        :return: 更新后的物品信息
        """
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        # 更新状态
        await self.item_repo.update(item_id, {
            "status": 3  # 已丢弃
        })
        
        # 插入丢弃记录
        await self.usage_repo.create({
            "item_id": item.id,
            "family_id": item.family_id,
            "type": 2,  # 丢弃
            "quantity": 0,
            "remaining_quantity": item.current_quantity,
            "operator_id": user_id,
            "operator_name": "系统"
        })
        
        return await self.get_item(user_id, item_id)
    
    async def move_item(self, user_id: int, item_id: int, to_location_id: int) -> Dict:
        """
        移动物品位置
        :param user_id: 用户ID
        :param item_id: 物品ID
        :param to_location_id: 目标位置ID
        :return: 更新后的物品信息
        """
        item = await self.item_repo.get_by_id(item_id)
        if not item:
            raise NotFoundException("物品不存在")
        
        await self._check_family_access(user_id, item.family_id)
        
        from_location_id = item.location_id
        
        # 更新位置
        await self.item_repo.update(item_id, {
            "location_id": to_location_id
        })
        
        # 插入移动记录
        await self.usage_repo.create({
            "item_id": item.id,
            "family_id": item.family_id,
            "type": 3,  # 移动
            "quantity": 0,
            "remaining_quantity": item.current_quantity,
            "operator_id": user_id,
            "operator_name": "系统",
            "from_location_id": from_location_id,
            "to_location_id": to_location_id
        })
        
        return await self.get_item(user_id, item_id)
    
    async def get_item_by_barcode(self, user_id: int, family_id: int, barcode: str) -> Optional[Dict]:
        """
        根据条码查询物品
        :param user_id: 用户ID
        :param family_id: 家庭ID
        :param barcode: 条码
        :return: 物品信息或 None
        """
        await self._check_family_access(user_id, family_id)
        
        item = await self.item_repo.get_by_barcode(barcode, family_id)
        if not item:
            return None
        
        return {
            "id": item.id,
            "name": item.name,
            "barcode": item.barcode,
            "current_quantity": float(item.current_quantity),
            "unit": item.unit,
            "status": item.status
        }
    
    async def _update_consumption_stats(self, item_id: int):
        """更新日均消耗量和预计用完日期"""
        # 获取最近30天的使用记录
        recent_records = await self.usage_repo.get_recent_by_item(item_id, limit=100)
        
        if not recent_records:
            return
        
        # 计算日均消耗量
        total_used = sum(record.quantity for record in recent_records if record.type == 1)
        days_diff = (datetime.now() - recent_records[-1].created_at).days
        
        if days_diff > 0 and total_used > 0:
            avg_daily = total_used / days_diff
            item = await self.item_repo.get_by_id(item_id)
            
            # 计算预计用完日期
            if avg_daily > 0 and item.current_quantity > 0:
                days_until_empty = item.current_quantity / avg_daily
                predicted_date = date.today() + timedelta(days=int(days_until_empty))
            else:
                predicted_date = None
            
            await self.item_repo.update(item_id, {
                "avg_daily_consumption": avg_daily,
                "predicted_empty_date": predicted_date
            })