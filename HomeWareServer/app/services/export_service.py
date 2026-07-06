"""
数据导出服务模块
实现物品数据导出为CSV和JSON格式
"""
import csv
import io
import json
import logging
import os
import uuid
from datetime import datetime
from typing import Dict, List, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.category import Category
from app.models.item import Item
from app.models.location import Location
from app.models.usage_record import UsageRecord

logger = logging.getLogger(__name__)

# 导出文件过期时间（秒）
EXPORT_EXPIRE_SECONDS = 3600

# 导出目录
EXPORT_DIR = os.path.join(settings.UPLOAD_DIR, "exports")
os.makedirs(EXPORT_DIR, exist_ok=True)


class ExportService:
    """数据导出服务"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def export_items_csv(self, family_id: int, status_filter: Optional[List[int]] = None) -> str:
        """
        导出物品为CSV格式
        :param family_id: 家庭ID
        :param status_filter: 状态筛选列表
        :return: 下载URL
        """
        # 查询物品
        query = select(Item).filter(Item.family_id == family_id)
        
        if status_filter:
            query = query.filter(Item.status.in_(status_filter))
        
        result = await self.db.execute(query)
        items = result.scalars().all()

        # 获取分类和位置名称映射
        categories = await self._get_categories_map(family_id)
        locations = await self._get_locations_map(family_id)

        # 生成CSV内容
        csv_content = self._generate_csv(items, categories, locations)

        # 生成文件名
        filename = f"items_{family_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4()[:8]}.csv"
        file_path = os.path.join(EXPORT_DIR, filename)

        # 保存文件
        with open(file_path, "w", newline="", encoding="utf-8-sig") as f:
            f.write(csv_content)

        logger.info(f"CSV导出成功: {filename}")

        # 返回下载URL
        return f"/api/v1/export/download/{filename}"

    async def export_items_json(self, family_id: int) -> Dict:
        """
        导出完整家庭数据为JSON格式
        :param family_id: 家庭ID
        :return: JSON数据
        """
        # 获取物品
        items_result = await self.db.execute(
            select(Item).filter(Item.family_id == family_id)
        )
        items = items_result.scalars().all()

        # 获取分类
        categories_result = await self.db.execute(
            select(Category).filter(Category.family_id == family_id)
        )
        categories = categories_result.scalars().all()

        # 获取位置
        locations_result = await self.db.execute(
            select(Location).filter(Location.family_id == family_id)
        )
        locations = locations_result.scalars().all()

        # 获取使用记录
        records_result = await self.db.execute(
            select(UsageRecord).filter(UsageRecord.family_id == family_id)
        )
        records = records_result.scalars().all()

        # 构建导出数据
        export_data = {
            "family_id": family_id,
            "export_time": datetime.now().isoformat(),
            "items": [self._item_to_dict(item) for item in items],
            "categories": [self._category_to_dict(cat) for cat in categories],
            "locations": [self._location_to_dict(loc) for loc in locations],
            "usage_records": [self._record_to_dict(record) for record in records]
        }

        logger.info(f"JSON导出成功，家庭 {family_id}")

        return export_data

    async def get_export_file(self, filename: str) -> Optional[str]:
        """
        获取导出文件路径（验证存在且未过期）
        :param filename: 文件名
        :return: 文件路径，如果不存在或已过期返回None
        """
        # 安全检查
        if "/" in filename or "\\" in filename:
            return None

        file_path = os.path.join(EXPORT_DIR, filename)

        # 检查文件是否存在
        if not os.path.exists(file_path):
            return None

        # 检查文件是否过期
        file_mtime = os.path.getmtime(file_path)
        current_time = datetime.now().timestamp()

        if current_time - file_mtime > EXPORT_EXPIRE_SECONDS:
            # 删除过期文件
            os.remove(file_path)
            return None

        return file_path

    async def cleanup_expired_files(self):
        """清理过期的导出文件"""
        current_time = datetime.now().timestamp()

        for filename in os.listdir(EXPORT_DIR):
            file_path = os.path.join(EXPORT_DIR, filename)
            if os.path.isfile(file_path):
                file_mtime = os.path.getmtime(file_path)
                if current_time - file_mtime > EXPORT_EXPIRE_SECONDS:
                    os.remove(file_path)
                    logger.info(f"清理过期导出文件: {filename}")

    async def _get_categories_map(self, family_id: int) -> Dict[int, str]:
        """获取分类ID到名称的映射"""
        result = await self.db.execute(
            select(Category.id, Category.name).filter(Category.family_id == family_id)
        )
        return {row[0]: row[1] for row in result.all()}

    async def _get_locations_map(self, family_id: int) -> Dict[int, str]:
        """获取位置ID到完整路径的映射"""
        result = await self.db.execute(
            select(Location.id, Location.full_path).filter(Location.family_id == family_id)
        )
        return {row[0]: row[1] for row in result.all()}

    def _generate_csv(self, items: List[Item], categories: Dict[int, str], locations: Dict[int, str]) -> str:
        """生成CSV内容"""
        output = io.StringIO()
        writer = csv.writer(output)

        # 写入表头
        writer.writerow([
            "名称", "品牌", "分类", "位置", "单价", "售价", "供应商", "购买数量",
            "剩余数量", "单位", "购买日期", "过期日期", "状态"
        ])

        # 写入数据
        for item in items:
            writer.writerow([
                item.name,
                item.brand or "",
                categories.get(item.category_id, ""),
                locations.get(item.location_id, ""),
                str(item.purchase_price) if item.purchase_price else "",
                str(item.sale_price) if item.sale_price else "",
                item.supplier or "",
                item.purchase_quantity,
                str(item.current_quantity),
                item.unit,
                item.purchase_date.isoformat() if item.purchase_date else "",
                item.expiry_date.isoformat() if item.expiry_date else "",
                self._get_status_text(item.status)
            ])

        return output.getvalue()

    def _get_status_text(self, status: int) -> str:
        """获取状态文本"""
        status_map = {
            0: "使用中",
            1: "用完",
            2: "过期",
            3: "丢弃"
        }
        return status_map.get(status, "未知")

    def _item_to_dict(self, item: Item) -> Dict:
        """物品转字典"""
        return {
            "id": item.id,
            "name": item.name,
            "brand": item.brand,
            "specification": item.specification,
            "barcode": item.barcode,
            "category_id": item.category_id,
            "location_id": item.location_id,
            "purchase_price": float(item.purchase_price) if item.purchase_price else None,
            "sale_price": float(item.sale_price) if item.sale_price else None,
            "total_price": float(item.total_price) if item.total_price else None,
            "purchase_quantity": item.purchase_quantity,
            "current_quantity": float(item.current_quantity),
            "unit": item.unit,
            "safety_stock": float(item.safety_stock),
            "purchase_date": item.purchase_date.isoformat() if item.purchase_date else None,
            "purchase_channel": item.purchase_channel,
            "production_date": item.production_date.isoformat() if item.production_date else None,
            "expiry_date": item.expiry_date.isoformat() if item.expiry_date else None,
            "shelf_life_days": item.shelf_life_days,
            "opened_date": item.opened_date.isoformat() if item.opened_date else None,
            "after_open_days": item.after_open_days,
            "warranty_date": item.warranty_date.isoformat() if item.warranty_date else None,
            "expiry_alert_days": item.expiry_alert_days,
            "stock_alert": item.stock_alert,
            "notes": item.notes,
            "status": item.status,
            "created_at": item.created_at.isoformat() if item.created_at else None,
            "updated_at": item.updated_at.isoformat() if item.updated_at else None
        }

    def _category_to_dict(self, category: Category) -> Dict:
        """分类转字典"""
        return {
            "id": category.id,
            "name": category.name,
            "icon": category.icon,
            "color": category.color,
            "parent_id": category.parent_id,
            "sort_order": category.sort_order,
            "created_at": category.created_at.isoformat() if category.created_at else None
        }

    def _location_to_dict(self, location: Location) -> Dict:
        """位置转字典"""
        return {
            "id": location.id,
            "name": location.name,
            "full_path": location.full_path,
            "parent_id": location.parent_id,
            "sort_order": location.sort_order,
            "created_at": location.created_at.isoformat() if location.created_at else None
        }

    def _record_to_dict(self, record: UsageRecord) -> Dict:
        """使用记录转字典"""
        return {
            "id": record.id,
            "item_id": record.item_id,
            "type": record.type,
            "quantity": float(record.quantity),
            "remaining_quantity": float(record.remaining_quantity),
            "operator_id": record.operator_id,
            "operator_name": record.operator_name,
            "from_location_id": record.from_location_id,
            "to_location_id": record.to_location_id,
            "notes": record.notes,
            "created_at": record.created_at.isoformat() if record.created_at else None
        }
