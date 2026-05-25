"""
分类服务模块
处理分类相关业务逻辑
"""
import logging
from typing import Dict, List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, NotFoundException, ValidationException
from app.models.category import Category
from app.repositories.category_repo import CategoryRepository

logger = logging.getLogger(__name__)


class CategoryService:
    """分类服务"""
    
    def __init__(self, db: AsyncSession):
        self.repo = CategoryRepository(db)
    
    async def get_categories_tree(self, family_id: int) -> List[Dict]:
        """
        获取当前家庭的分类树形结构
        :param family_id: 当前家庭ID
        :return: 树形结构的分类列表
        """
        # 获取系统预设分类和当前家庭的自定义分类
        categories = await self.repo.get_categories_with_family(family_id)
        
        # 组装成树形结构
        return self._build_tree(categories)
    
    def _build_tree(self, categories: List[Category]) -> List[Dict]:
        """将分类列表组装成树形结构"""
        # 按 parent_id 分组
        category_map = {cat.id: cat for cat in categories}
        children_map = {}
        
        for cat in categories:
            parent_id = cat.parent_id or 0
            if parent_id not in children_map:
                children_map[parent_id] = []
            children_map[parent_id].append(cat)
        
        # 递归构建树
        def build_node(parent_id: int) -> List[Dict]:
            result = []
            for cat in children_map.get(parent_id, []):
                node = {
                    "id": cat.id,
                    "name": cat.name,
                    "icon": cat.icon,
                    "color": cat.color,
                    "parent_id": cat.parent_id,
                    "sort_order": cat.sort_order,
                    "is_system": cat.is_system,
                    "is_active": cat.is_active,
                    "created_at": cat.created_at,
                    "children": build_node(cat.id)
                }
                result.append(node)
            # 按 sort_order 排序
            result.sort(key=lambda x: x["sort_order"])
            return result
        
        return build_node(0)
    
    async def create_category(self, data: Dict, family_id: int) -> Category:
        """
        创建自定义分类
        :param data: 分类数据
        :param family_id: 当前家庭ID
        :return: 创建的分类对象
        """
        # 检查父分类是否存在
        parent_id = data.get("parent_id")
        if parent_id:
            parent = await self.repo.get_by_id(parent_id)
            if not parent:
                raise NotFoundException("父分类不存在")
        
        # 创建分类
        category = await self.repo.create({
            "name": data["name"],
            "icon": data.get("icon"),
            "color": data.get("color"),
            "parent_id": parent_id,
            "family_id": family_id,
            "is_system": False,
            "is_active": True,
            "sort_order": data.get("sort_order", 0)
        })
        
        logger.info(f"创建自定义分类: {category.name} (ID: {category.id})")
        return category
    
    async def update_category(self, category_id: int, data: Dict, family_id: int) -> Category:
        """
        更新分类（仅可修改自定义分类）
        :param category_id: 分类ID
        :param data: 更新数据
        :param family_id: 当前家庭ID
        :return: 更新后的分类对象
        """
        category = await self.repo.get_by_id(category_id, family_id)
        if not category:
            raise NotFoundException("分类不存在")
        
        if category.is_system:
            raise ForbiddenException("系统预设分类不可修改")
        
        # 检查父分类是否存在
        parent_id = data.get("parent_id")
        if parent_id:
            parent = await self.repo.get_by_id(parent_id)
            if not parent:
                raise NotFoundException("父分类不存在")
        
        # 更新分类
        update_data = {}
        if "name" in data:
            update_data["name"] = data["name"]
        if "icon" in data:
            update_data["icon"] = data["icon"]
        if "color" in data:
            update_data["color"] = data["color"]
        if "sort_order" in data:
            update_data["sort_order"] = data["sort_order"]
        if "parent_id" in data:
            update_data["parent_id"] = data["parent_id"]
        
        updated = await self.repo.update(category_id, update_data)
        if not updated:
            raise NotFoundException("分类不存在")
        
        logger.info(f"更新分类: {updated.name} (ID: {updated.id})")
        return updated
    
    async def delete_category(self, category_id: int, family_id: int) -> bool:
        """
        删除分类
        :param category_id: 分类ID
        :param family_id: 当前家庭ID
        :return: 是否删除成功
        """
        category = await self.repo.get_by_id(category_id)
        if not category:
            raise NotFoundException("分类不存在")
        
        if category.is_system:
            raise ForbiddenException("系统预设分类不可删除")
        
        # 检查该分类是否属于当前家庭（自定义分类）
        if category.family_id != family_id:
            raise ForbiddenException("无权删除此分类")
        
        # 检查该分类下是否有物品
        item_count = await self.repo.count_items_in_category(category_id)
        if item_count > 0:
            raise ValidationException(f"该分类下有 {item_count} 个物品，无法删除")
        
        # 检查是否有子分类
        child_count = await self.repo.count_child_categories(category_id)
        if child_count > 0:
            raise ValidationException(f"该分类下有 {child_count} 个子分类，无法删除")
        
        # 软删除
        success = await self.repo.delete(category_id, family_id)
        
        if success:
            logger.info(f"删除分类: {category.name} (ID: {category.id})")
        
        return success
    
    async def get_category_by_id(self, category_id: int, family_id: int) -> Category:
        """
        获取分类详情
        :param category_id: 分类ID
        :param family_id: 当前家庭ID
        :return: 分类对象
        """
        category = await self.repo.get_by_id(category_id)
        if not category:
            raise NotFoundException("分类不存在")
        
        # 系统预设分类或当前家庭的分类可访问
        if category.is_system or category.family_id == family_id:
            return category
        
        raise ForbiddenException("无权访问此分类")