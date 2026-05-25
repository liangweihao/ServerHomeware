"""
家庭服务模块
处理家庭相关业务逻辑
"""
import logging
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ConflictException, ForbiddenException, NotFoundException
from app.models.family import Family, FamilyMember
from app.models.user import User
from app.repositories.family_repo import FamilyMemberRepository, FamilyRepository
from app.repositories.user_repo import UserRepository
from app.services.location_service import LocationService

# 位置模板（创建家庭时自动复制）
LOCATION_TEMPLATE = [
    {
        "name": "厨房",
        "icon": "🍳",
        "children": [
            {
                "name": "冰箱",
                "icon": "🧊",
                "children": [
                    {"name": "冷藏层", "icon": "❄️"},
                    {"name": "冷冻层", "icon": "🧊"},
                    {"name": "门侧", "icon": "🚪"}
                ]
            },
            {
                "name": "吊柜",
                "icon": "🚪",
                "children": [
                    {"name": "一层", "icon": "1️⃣"},
                    {"name": "二层", "icon": "2️⃣"},
                    {"name": "三层", "icon": "3️⃣"}
                ]
            },
            {"name": "调料架", "icon": "🧂"},
            {"name": "水槽下方", "icon": "🚿"},
            {"name": "台面", "icon": "🪑"}
        ]
    },
    {
        "name": "卫生间",
        "icon": "🛁",
        "children": [
            {
                "name": "洗漱台",
                "icon": "🚰",
                "children": [
                    {"name": "台面", "icon": "🪑"},
                    {"name": "镜柜", "icon": "🪞"},
                    {"name": "下方", "icon": "⬇️"}
                ]
            },
            {"name": "浴室柜", "icon": "🗄️"},
            {"name": "马桶旁", "icon": "🚽"}
        ]
    },
    {
        "name": "客厅",
        "icon": "🛋️",
        "children": [
            {"name": "电视柜", "icon": "📺"},
            {
                "name": "茶几",
                "icon": "🪑",
                "children": [
                    {"name": "上方", "icon": "⬆️"},
                    {"name": "下方", "icon": "⬇️"}
                ]
            },
            {"name": "书架", "icon": "📚"}
        ]
    },
    {
        "name": "主卧",
        "icon": "🛏️",
        "children": [
            {
                "name": "衣柜",
                "icon": "🗄️",
                "children": [
                    {"name": "上层", "icon": "⬆️"},
                    {"name": "中层", "icon": "➡️"},
                    {"name": "下层", "icon": "⬇️"},
                    {"name": "抽屉", "icon": "🗄️"}
                ]
            },
            {
                "name": "床头柜",
                "icon": "🛏️",
                "children": [
                    {"name": "台面", "icon": "🪑"},
                    {"name": "抽屉", "icon": "🗄️"}
                ]
            },
            {"name": "梳妆台", "icon": "🪞"}
        ]
    },
    {
        "name": "次卧",
        "icon": "🛏️",
        "children": [
            {"name": "衣柜", "icon": "🗄️"},
            {"name": "书桌", "icon": "🖥️"}
        ]
    },
    {
        "name": "阳台",
        "icon": "☀️",
        "children": [
            {
                "name": "储物柜",
                "icon": "🗄️",
                "children": [
                    {"name": "上层", "icon": "⬆️"},
                    {"name": "下层", "icon": "⬇️"}
                ]
            },
            {"name": "晾衣区", "icon": "👕"}
        ]
    }
]

logger = logging.getLogger(__name__)


class FamilyService:
    """家庭服务"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.family_repo = FamilyRepository(db)
        self.family_member_repo = FamilyMemberRepository(db)
        self.user_repo = UserRepository(db)
        self.location_service = LocationService(db)
    
    async def create_family(self, name: str, owner_id: int, description: Optional[str] = None) -> Family:
        """
        创建新家庭
        :param name: 家庭名称
        :param owner_id: 创建者ID
        :param description: 描述（可选）
        :return: 家庭对象
        """
        logger.info(f"创建家庭 - 名称: {name}, 创建者ID: {owner_id}")
        
        # 生成邀请码
        invite_code = self._generate_invite_code()
        while await self.family_repo.exists_by_invite_code(invite_code):
            invite_code = self._generate_invite_code()
        
        family = await self.family_repo.create({
            "name": name,
            "invite_code": invite_code,
            "owner_id": owner_id,
        })
        
        # 添加创建者为家庭成员
        await self.family_member_repo.create({
            "family_id": family.id,
            "user_id": owner_id,
            "role": "owner",
        })
        
        # 更新用户当前家庭
        await self.user_repo.update(owner_id, {"current_family_id": family.id})
        
        # 复制位置模板到新家庭
        await self.location_service.copy_location_template(family.id, LOCATION_TEMPLATE)
        
        logger.info(f"家庭创建成功 - 家庭ID: {family.id}")
        return family
    
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
        
        # 添加为家庭成员
        await self.family_member_repo.create({
            "family_id": family.id,
            "user_id": user_id,
            "role": "member",
        })
        
        # 更新用户当前家庭
        await self.user_repo.update(user_id, {"current_family_id": family.id})
        
        logger.info(f"加入家庭成功 - 用户ID: {user_id}, 家庭ID: {family.id}")
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
    
    async def update_member_role(self, family_id: int, user_id: int, role: str):
        """
        更新成员角色
        :param family_id: 家庭ID
        :param user_id: 用户ID
        :param role: 角色
        """
        logger.info(f"更新成员角色 - 家庭ID: {family_id}, 用户ID: {user_id}, 角色: {role}")
        
        member = await self.family_member_repo.get_by_user_and_family(user_id, family_id)
        if not member:
            raise NotFoundException("成员不存在")
        
        await self.family_member_repo.update(member.id, {"role": role})
        
        logger.info(f"成员角色更新成功")
    
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
        items = await item_repo.get_list(family_id=family_id)
        return items.get("total", 0)
    
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