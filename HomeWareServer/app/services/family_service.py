"""
家庭服务模块
处理家庭相关业务逻辑
"""
import logging
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ConflictException, ForbiddenException, NotFoundException
from app.core.shop_permissions import (
    assert_can_change_member_role,
    default_join_role,
    validate_assignable_role,
)
from app.core.space_type import SPACE_TYPE_HOME, SPACE_TYPE_SHOP, normalize_space_type
from app.core.space_templates import (
    SHOP_CATEGORY_TEMPLATE,
    location_template_for,
    should_seed_shop_categories,
)
from app.models.family import Family, FamilyMember
from app.models.user import User
from app.repositories.category_repo import CategoryRepository
from app.repositories.family_repo import FamilyMemberRepository, FamilyRepository
from app.repositories.user_repo import UserRepository
from app.services.location_service import LocationService

logger = logging.getLogger(__name__)


class FamilyService:
    """家庭服务"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.family_repo = FamilyRepository(db)
        self.family_member_repo = FamilyMemberRepository(db)
        self.user_repo = UserRepository(db)
        self.location_service = LocationService(db)
        self.category_repo = CategoryRepository(db)
    
    async def create_family(
        self,
        name: str,
        owner_id: int,
        description: Optional[str] = None,
        space_type: Optional[str] = None,
    ) -> Family:
        """
        创建新家庭
        :param name: 家庭名称
        :param owner_id: 创建者ID
        :param description: 描述（可选）
        :param space_type: 空间类型 home|shop
        :return: 家庭对象
        """
        resolved_type = normalize_space_type(space_type)
        default_icon = "🏪" if resolved_type == SPACE_TYPE_SHOP else "🏠"
        logger.info(
            f"创建家庭 - 名称: {name}, 创建者ID: {owner_id}, space_type={resolved_type}"
        )

        # 生成邀请码
        invite_code = self._generate_invite_code()
        while await self.family_repo.exists_by_invite_code(invite_code):
            invite_code = self._generate_invite_code()

        family = await self.family_repo.create({
            "name": name,
            "invite_code": invite_code,
            "owner_id": owner_id,
            "space_type": resolved_type,
            "icon": default_icon,
        })
        
        # 添加创建者为家庭成员
        await self.family_member_repo.create({
            "family_id": family.id,
            "user_id": owner_id,
            "role": "owner",
        })
        
        # 更新用户当前家庭
        await self.user_repo.update(owner_id, {"current_family_id": family.id})
        
        # 按空间类型复制位置模板；店铺额外写入分类模板
        location_template = location_template_for(resolved_type)
        await self.location_service.copy_location_template(family.id, location_template)
        if should_seed_shop_categories(resolved_type):
            await self._copy_shop_category_template(family.id)
            logger.info(f"店铺分类模板已写入 - familyId={family.id}")
        
        logger.info(f"家庭创建成功 - 家庭ID: {family.id}")
        return family

    async def _copy_shop_category_template(self, family_id: int) -> None:
        """店铺空间：写入家庭级默认分类（不覆盖全局 system 分类）"""
        for template in SHOP_CATEGORY_TEMPLATE:
            await self.category_repo.create(
                {
                    "name": template["name"],
                    "icon": template.get("icon"),
                    "color": template.get("color"),
                    "family_id": family_id,
                    "sort_order": template.get("sort_order", 0),
                    "is_system": False,
                    "is_active": True,
                }
            )
    
    async def join_family(self, user_id: int, invite_code: str) -> Family:
        """
        加入家庭
        :param user_id: 用户ID
        :param invite_code: 邀请码
        :return: 家庭对象
        """
        logger.info(f"加入家庭 - 用户ID: {user_id}, 邀请码: {invite_code}")
        
        # 获取家庭
        family = await self.family_repo.get_by_invite_code(invite_code)
        if not family:
            raise NotFoundException("邀请码无效")
        
        # 检查是否已加入
        if await self.family_member_repo.is_member(user_id, family.id):
            raise ConflictException("已加入该家庭")
        
        # 添加为家庭成员 — shop 默认店员
        join_role = default_join_role(getattr(family, "space_type", None))
        await self.family_member_repo.create({
            "family_id": family.id,
            "user_id": user_id,
            "role": join_role,
        })
        
        # 更新用户当前家庭
        await self.user_repo.update(user_id, {"current_family_id": family.id})
        
        logger.info(
            f"加入家庭成功 - 用户ID: {user_id}, 家庭ID: {family.id}, role={join_role}"
        )
        return family
    
    async def switch_family(self, user_id: int, family_id: int) -> Family:
        """
        切换当前家庭
        :param user_id: 用户ID
        :param family_id: 家庭ID
        :return: 家庭对象
        """
        logger.info(f"切换家庭 - 用户ID: {user_id}, 家庭ID: {family_id}")
        
        # 检查是否是家庭成员
        if not await self.family_member_repo.is_member(user_id, family_id):
            raise ForbiddenException("不是该家庭成员")
        
        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")
        
        # 更新用户当前家庭
        await self.user_repo.update(user_id, {"current_family_id": family_id})
        
        logger.info(f"切换家庭成功 - 用户ID: {user_id}, 家庭ID: {family_id}")
        return family
    
    async def leave_family(self, user_id: int, family_id: int):
        """
        离开家庭
        :param user_id: 用户ID
        :param family_id: 家庭ID
        """
        logger.info(f"离开家庭 - 用户ID: {user_id}, 家庭ID: {family_id}")
        
        # 获取成员关系
        member = await self.family_member_repo.get_by_user_and_family(user_id, family_id)
        if not member:
            raise NotFoundException("不是该家庭成员")
        
        # 检查是否是家庭所有者
        family = await self.family_repo.get_by_id(family_id)
        if family and family.owner_id == user_id:
            raise ForbiddenException("家庭所有者不能离开家庭，请先转移所有权或删除家庭")
        
        # 删除成员关系
        await self.family_member_repo.delete(member.id)
        
        # 如果当前家庭是该家庭，切换到其他家庭或清空
        user = await self.user_repo.get_by_id(user_id)
        if user and user.current_family_id == family_id:
            other_families = await self.family_member_repo.get_by_user_id(user_id)
            if other_families:
                await self.user_repo.update(user_id, {"current_family_id": other_families[0].family_id})
            else:
                await self.user_repo.update(user_id, {"current_family_id": None})
        
        logger.info(f"离开家庭成功 - 用户ID: {user_id}, 家庭ID: {family_id}")
    
    async def get_user_families(self, user_id: int) -> List[Family]:
        """
        获取用户的所有家庭
        :param user_id: 用户ID
        :return: 家庭列表
        """
        members = await self.family_member_repo.get_by_user_id(user_id)
        families = []
        for member in members:
            family = await self.family_repo.get_by_id(member.family_id)
            if family:
                families.append(family)
        return families
    
    async def get_family_members(self, family_id: int) -> List[FamilyMember]:
        """
        获取家庭成员列表
        :param family_id: 家庭ID
        :return: 成员列表
        """
        return await self.family_member_repo.get_by_family_id(family_id)
    
    async def update_member_role(
        self,
        operator_id: int,
        family_id: int,
        user_id: int,
        role: str,
    ):
        """
        更新成员角色 — 仅 owner 可改；shop 支持 clerk
        """
        logger.info(
            f"更新成员角色 - 操作者: {operator_id}, 家庭ID: {family_id}, "
            f"目标用户: {user_id}, 角色: {role}"
        )

        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")

        operator = await self.family_member_repo.get_by_user_and_family(
            operator_id, family_id
        )
        if not operator:
            raise ForbiddenException("您不是该家庭成员")
        assert_can_change_member_role(operator.role)
        validate_assignable_role(role, getattr(family, "space_type", None))

        member = await self.family_member_repo.get_by_user_and_family(user_id, family_id)
        if not member:
            raise NotFoundException("成员不存在")
        if member.role == "owner":
            raise ForbiddenException("不能修改老板角色")
        if family.owner_id == user_id and role != "owner":
            raise ForbiddenException("不能变更老板的角色")

        await self.family_member_repo.update(member.id, {"role": role})
        
        logger.info("成员角色更新成功")
    
    async def update_family(self, user_id: int, family_id: int, name: Optional[str] = None):
        """
        更新家庭信息（owner/admin 可操作）
        :param user_id: 当前用户ID
        :param family_id: 家庭ID
        :param name: 家庭名称
        """
        logger.info(f"更新家庭信息 - 用户ID: {user_id}, 家庭ID: {family_id}")
        
        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")
        
        member = await self.family_member_repo.get_by_user_and_family(user_id, family_id)
        if not member:
            raise ForbiddenException("您不是该家庭成员")
        if member.role not in ["owner", "admin"]:
            raise ForbiddenException("仅家庭所有者或管理员可修改家庭设置")
        
        if name is not None:
            name = name.strip()
            if not name:
                raise ConflictException("家庭名称不能为空")
            if len(name) > 50:
                raise ConflictException("家庭名称不能超过50个字符")
            await self.family_repo.update(family_id, {"name": name})
        
        logger.info(f"家庭信息更新成功 - 家庭ID: {family_id}")
        return await self.family_repo.get_by_id(family_id)
    
    def _generate_invite_code(self) -> str:
        """生成8位邀请码"""
        import random
        import string
        return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
    
    async def get_family_by_id(self, family_id: int):
        """
        根据ID获取家庭信息
        :param family_id: 家庭ID
        :return: 家庭对象
        """
        return await self.family_repo.get_by_id(family_id)
    
    async def get_family_item_count(self, family_id: int) -> int:
        """
        获取家庭物品数量
        :param family_id: 家庭ID
        :return: 物品数量
        """
        from app.repositories.item_repo import ItemRepository

        item_repo = ItemRepository(self.db)
        return await item_repo.count_by_family_id(family_id)
    
    async def refresh_invite_code(self, family_id: int) -> str:
        """
        刷新家庭邀请码
        :param family_id: 家庭ID
        :return: 新邀请码
        """
        logger.info(f"刷新邀请码 - 家庭ID: {family_id}")
        
        # 生成新邀请码
        new_code = self._generate_invite_code()
        while await self.family_repo.exists_by_invite_code(new_code):
            new_code = self._generate_invite_code()
        
        # 更新邀请码
        await self.family_repo.update(family_id, {"invite_code": new_code})
        
        logger.info(f"邀请码刷新成功 - 新邀请码: {new_code}")
        return new_code
    
    async def get_user_families_with_details(self, user_id: int):
        """
        获取用户的所有家庭（包含角色和统计信息）
        :param user_id: 用户ID
        :return: 家庭列表（含角色、成员数、物品数）
        """
        members = await self.family_member_repo.get_by_user_id(user_id)
        families = []
        
        for member in members:
            family = await self.family_repo.get_by_id(member.family_id)
            if family:
                # 获取成员数量
                member_count = await self.family_member_repo.count_by_family_id(family.id)
                # 获取物品数量
                item_count = await self.get_family_item_count(family.id)
                
                families.append({
                    "id": family.id,
                    "name": family.name,
                    "icon": family.icon or "🏠",
                    "space_type": getattr(family, "space_type", SPACE_TYPE_HOME)
                    or SPACE_TYPE_HOME,
                    "role": member.role,
                    "member_count": member_count,
                    "item_count": item_count,
                    "created_at": family.created_at,
                })
        
        return families
    
    async def delete_family(self, user_id: int, family_id: int, confirm_name: str):
        """
        删除家庭（仅 owner 可操作）
        :param user_id: 当前用户ID
        :param family_id: 家庭ID
        :param confirm_name: 确认的家庭名称
        """
        logger.info(f"删除家庭 - 用户ID: {user_id}, 家庭ID: {family_id}")
        
        # 获取家庭信息
        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")
        
        # 检查是否是 owner
        if family.owner_id != user_id:
            raise ForbiddenException("仅家庭所有者可删除家庭")
        
        # 检查名称是否匹配
        if family.name != confirm_name:
            raise ConflictException("输入的家庭名称不匹配")
        
        # 级联软删除
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc)
        
        # 软删除家庭
        await self.family_repo.update(family_id, {"deleted_at": now})
        
        # 软删除物品
        from app.repositories.item_repo import ItemRepository
        item_repo = ItemRepository(self.db)
        await item_repo.soft_delete_by_family(family_id, now)
        
        # 软删除位置
        from app.repositories.location_repo import LocationRepository
        location_repo = LocationRepository(self.db)
        await location_repo.soft_delete_by_family(family_id, now)
        
        # 软删除分类
        from app.repositories.category_repo import CategoryRepository
        category_repo = CategoryRepository(self.db)
        await category_repo.soft_delete_by_family(family_id, now)
        
        # 软删除购物清单
        from app.repositories.shopping_repo import ShoppingItemRepository
        shopping_repo = ShoppingItemRepository(self.db)
        await shopping_repo.soft_delete_by_family(family_id, now)
        
        # 获取所有成员并处理
        members = await self.family_member_repo.get_by_family_id(family_id)
        for member in members:
            # 更新成员的 current_family_id（包括当前用户）
            other_families = await self.family_member_repo.get_by_user_id(member.user_id)
            other_families = [f for f in other_families if f.family_id != family_id]
            if other_families:
                await self.user_repo.update(member.user_id, {"current_family_id": other_families[0].family_id})
            else:
                await self.user_repo.update(member.user_id, {"current_family_id": None})
        
        # 删除所有 family_member 关联记录
        await self.family_member_repo.delete_by_family_id(family_id)
        
        logger.info(f"家庭删除成功 - 家庭ID: {family_id}")
    
    async def remove_member(self, current_user_id: int, family_id: int, member_id: int):
        """
        移除成员
        :param current_user_id: 当前操作用户ID
        :param family_id: 家庭ID
        :param member_id: 要移除的成员ID
        """
        logger.info(f"移除成员 - 当前用户ID: {current_user_id}, 家庭ID: {family_id}, 成员ID: {member_id}")
        
        # 获取要移除的成员信息
        member_to_remove = await self.family_member_repo.get_by_user_and_family(member_id, family_id)
        if not member_to_remove:
            raise NotFoundException("成员不存在")
        
        # 获取当前用户在家庭中的角色
        current_member = await self.family_member_repo.get_by_user_and_family(current_user_id, family_id)
        if not current_member:
            raise ForbiddenException("您不是该家庭成员")
        
        # 不能移除自己
        if current_user_id == member_id:
            raise ForbiddenException("不能移除自己")
        
        # 获取家庭信息
        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")
        
        # 权限检查
        current_role = current_member.role
        target_role = member_to_remove.role
        
        # owner 可以移除任何人
        if current_role == "owner":
            pass
        # admin 可移除 clerk/member，不能移除 owner
        elif current_role == "admin":
            if target_role == "owner":
                raise ForbiddenException("管理员不能移除家庭所有者")
        elif current_role == "clerk":
            raise ForbiddenException("店员不能移除其他成员")
        else:
            raise ForbiddenException("权限不足，无法移除成员")
        
        # 删除成员关系
        await self.family_member_repo.delete(member_to_remove.id)
        
        # 如果被移除者的当前家庭是这个家庭，切换到其他家庭或清空
        user = await self.user_repo.get_by_id(member_id)
        if user and user.current_family_id == family_id:
            other_families = await self.family_member_repo.get_by_user_id(member_id)
            if other_families:
                await self.user_repo.update(member_id, {"current_family_id": other_families[0].family_id})
            else:
                await self.user_repo.update(member_id, {"current_family_id": None})
        
        logger.info(f"成员移除成功 - 成员ID: {member_id}")
    
    async def transfer_ownership(self, current_user_id: int, family_id: int, new_owner_id: int):
        """
        转让家庭所有权
        :param current_user_id: 当前所有者ID
        :param family_id: 家庭ID
        :param new_owner_id: 新所有者ID
        """
        logger.info(f"转让所有权 - 当前用户ID: {current_user_id}, 家庭ID: {family_id}, 新所有者ID: {new_owner_id}")
        
        # 获取家庭信息
        family = await self.family_repo.get_by_id(family_id)
        if not family:
            raise NotFoundException("家庭不存在")
        
        # 检查当前用户是否是 owner
        if family.owner_id != current_user_id:
            raise ForbiddenException("仅家庭所有者可转让所有权")
        
        # 检查新所有者是否是家庭成员
        new_owner_member = await self.family_member_repo.get_by_user_and_family(new_owner_id, family_id)
        if not new_owner_member:
            raise NotFoundException("新所有者不是家庭成员")
        
        # 更新家庭 owner_id
        await self.family_repo.update(family_id, {"owner_id": new_owner_id})
        
        # 将新所有者角色改为 owner
        await self.family_member_repo.update(new_owner_member.id, {"role": "owner"})
        
        # 将原所有者角色改为 admin
        current_member = await self.family_member_repo.get_by_user_and_family(current_user_id, family_id)
        if current_member:
            await self.family_member_repo.update(current_member.id, {"role": "admin"})
        
        logger.info(f"所有权转让成功 - 家庭ID: {family_id}, 新所有者ID: {new_owner_id}")