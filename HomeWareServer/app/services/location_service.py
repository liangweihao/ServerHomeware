"""
位置服务模块
处理位置相关业务逻辑
"""
import logging
from typing import Dict, List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, NotFoundException, ValidationException
from app.models.item import Item
from app.models.location import Location
from app.repositories.location_repo import LocationRepository

logger = logging.getLogger(__name__)


class LocationService:
    """位置服务"""
    
    def __init__(self, db: AsyncSession):
        self.repo = LocationRepository(db)
    
    async def get_locations_tree(self, family_id: int, parent_id: Optional[int] = None) -> List[Dict]:
        """
        获取当前家庭的位置树形结构
        :param family_id: 当前家庭ID
        :param parent_id: 父位置ID（可选，获取某层级下的子位置）
        :return: 树形结构的位置列表
        """
        locations = await self.repo.get_by_family_id(family_id)
        
        # 获取每个位置的物品数量
        location_item_counts = await self._get_location_item_counts(family_id)
        
        # 组装成树形结构
        return self._build_tree(locations, location_item_counts, parent_id)
    
    def _build_tree(self, locations: List[Location], item_counts: Dict[int, int], parent_id: Optional[int]) -> List[Dict]:
        """将位置列表组装成树形结构"""
        # 按 parent_id 分组
        location_map = {loc.id: loc for loc in locations}
        children_map = {}
        
        for loc in locations:
            pid = loc.parent_id or 0
            if pid not in children_map:
                children_map[pid] = []
            children_map[pid].append(loc)
        
        # 构建节点
        def build_node(pid: int) -> List[Dict]:
            result = []
            for loc in children_map.get(pid, []):
                node = {
                    "id": loc.id,
                    "name": loc.name,
                    "icon": loc.icon,
                    "parent_id": loc.parent_id,
                    "level": loc.level,
                    "full_path": loc.full_path,
                    "sort_order": loc.sort_order,
                    "is_active": loc.is_active,
                    "item_count": item_counts.get(loc.id, 0),
                    "created_at": loc.created_at,
                    "children": build_node(loc.id)
                }
                result.append(node)
            # 按 sort_order 排序
            result.sort(key=lambda x: x["sort_order"])
            return result
        
        if parent_id is None:
            return build_node(0)
        else:
            # 只返回指定父节点下的子节点
            return build_node(parent_id)
    
    async def _get_location_item_counts(self, family_id: int) -> Dict[int, int]:
        """获取每个位置的物品数量"""
        counts = await self.repo.get_location_item_counts(family_id)
        return {loc_id: count for loc_id, count in counts}
    
    async def get_location_detail(self, location_id: int, family_id: int) -> Dict:
        """
        获取位置详情
        :param location_id: 位置ID
        :param family_id: 当前家庭ID
        :return: 位置详情（含子位置和物品列表）
        """
        location = await self.repo.get_by_id(location_id, family_id)
        if not location:
            raise NotFoundException("位置不存在")
        
        # 获取子位置
        children = await self.repo.get_by_parent_id(location_id)
        
        # 获取该位置下的物品
        items = await self.repo.get_items_in_location(location_id, family_id)
        
        return {
            "id": location.id,
            "name": location.name,
            "icon": location.icon,
            "parent_id": location.parent_id,
            "level": location.level,
            "full_path": location.full_path,
            "sort_order": location.sort_order,
            "is_active": location.is_active,
            "created_at": location.created_at,
            "children": [{"id": c.id, "name": c.name, "icon": c.icon} for c in children],
            "items": [{
                "id": item.id,
                "name": item.name,
                "quantity": float(item.current_quantity),
                "unit": item.unit,
                "category_id": item.category_id,
                "status": item.status
            } for item in items]
        }
    
    async def create_location(self, data: Dict, family_id: int) -> Location:
        """
        创建位置
        :param data: 位置数据
        :param family_id: 当前家庭ID
        :return: 创建的位置对象
        """
        parent_id = data.get("parent_id")
        name = data.get("name")
        
        if parent_id:
            # 获取父位置信息
            parent = await self.repo.get_by_id(parent_id, family_id)
            if not parent:
                raise NotFoundException("父位置不存在")
            
            if parent.level >= 3:
                raise ValidationException("位置层级不能超过3层")
            
            level = parent.level + 1
            full_path = f"{parent.full_path}/{name}" if parent.full_path else name
        else:
            level = 1
            full_path = name
        
        # 创建位置
        location = await self.repo.create({
            "name": name,
            "icon": data.get("icon"),
            "images": data.get("images"),
            "parent_id": parent_id,
            "family_id": family_id,
            "level": level,
            "full_path": full_path,
            "sort_order": data.get("sort_order", 0),
            "is_active": True
        })
        
        logger.info(f"创建位置: {location.full_path} (ID: {location.id})")
        return location
    
    async def update_location(self, location_id: int, data: Dict, family_id: int) -> Location:
        """
        更新位置
        :param location_id: 位置ID
        :param data: 更新数据
        :param family_id: 当前家庭ID
        :return: 更新后的位置对象
        """
        location = await self.repo.get_by_id(location_id, family_id)
        if not location:
            raise NotFoundException("位置不存在")
        
        old_name = location.name
        update_data = {}
        
        if "name" in data:
            update_data["name"] = data["name"]
        if "icon" in data:
            update_data["icon"] = data["icon"]
        if "images" in data:
            update_data["images"] = data["images"]
        if "sort_order" in data:
            update_data["sort_order"] = data["sort_order"]
        
        updated = await self.repo.update(location_id, update_data)
        
        # 如果名称改变，更新 full_path 和所有子位置的 full_path
        if "name" in data and data["name"] != old_name:
            await self._update_full_path(updated, family_id)
        
        logger.info(f"更新位置: {updated.full_path} (ID: {updated.id})")
        return updated
    
    async def _update_full_path(self, location: Location, family_id: int):
        """更新位置的 full_path 及所有子位置的 full_path"""
        # 获取父位置的 full_path
        if location.parent_id:
            parent = await self.repo.get_by_id(location.parent_id)
            parent_path = parent.full_path if parent else ""
            new_path = f"{parent_path}/{location.name}" if parent_path else location.name
        else:
            new_path = location.name
        
        # 更新当前位置的 full_path
        await self.repo.update(location.id, {"full_path": new_path})
        
        # 更新所有子位置的 full_path
        children = await self.repo.get_by_parent_id(location.id)
        for child in children:
            old_child_path = child.full_path
            new_child_path = old_child_path.replace(f"{location.full_path}/", f"{new_path}/")
            await self.repo.update(child.id, {"full_path": new_child_path})
            # 递归更新孙子位置
            await self._update_full_path(child, family_id)
    
    async def delete_location(self, location_id: int, family_id: int) -> bool:
        """
        删除位置
        :param location_id: 位置ID
        :param family_id: 当前家庭ID
        :return: 是否删除成功
        """
        location = await self.repo.get_by_id(location_id, family_id)
        if not location:
            raise NotFoundException("位置不存在")
        
        # 获取所有子位置（递归）
        all_child_ids = await self._get_all_child_ids(location_id)
        all_ids = [location_id] + all_child_ids
        
        # 检查这些位置下是否有物品
        item_count = await self.repo.count_items_in_locations(all_ids)
        if item_count > 0:
            raise ValidationException(f"该位置及其子位置下有 {item_count} 个物品，无法删除")
        
        # 删除该位置及所有子位置
        for loc_id in all_ids:
            await self.repo.delete(loc_id, family_id)
        
        logger.info(f"删除位置: {location.full_path} (ID: {location.id})")
        return True
    
    async def _get_all_child_ids(self, parent_id: int) -> List[int]:
        """递归获取所有子位置ID"""
        children = await self.repo.get_by_parent_id(parent_id)
        result = []
        for child in children:
            result.append(child.id)
            result.extend(await self._get_all_child_ids(child.id))
        return result
    
    async def copy_location_template(self, family_id: int, template_locations: List[Dict]):
        """
        复制位置模板到家庭
        :param family_id: 家庭ID
        :param template_locations: 模板位置数据
        """
        for template in template_locations:
            await self._create_location_from_template(template, family_id, None)
    
    async def _create_location_from_template(self, template: Dict, family_id: int, parent_id: Optional[int]):
        """递归创建模板位置"""
        # 创建当前位置
        location = await self.create_location({
            "name": template["name"],
            "icon": template.get("icon"),
            "parent_id": parent_id,
            "sort_order": template.get("sort_order", 0)
        }, family_id)
        
        # 创建子位置
        if "children" in template:
            for child in template["children"]:
                await self._create_location_from_template(child, family_id, location.id)