"""
预设数据种子脚本
用于初始化系统预设分类和位置模板
"""
import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import async_engine, Base
from app.models.category import Category
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select


# 系统预设分类数据
SYSTEM_CATEGORIES = [
    # 食品饮料
    {"name": "食品饮料", "icon": "🍎", "color": "#FF8A65", "parent_id": None, "sort_order": 1},
    {"name": "乳制品", "icon": "🥛", "color": "#FF8A65", "parent_id": 1, "sort_order": 1},
    {"name": "肉类", "icon": "🥩", "color": "#FF8A65", "parent_id": 1, "sort_order": 2},
    {"name": "蔬果", "icon": "🥦", "color": "#FF8A65", "parent_id": 1, "sort_order": 3},
    {"name": "零食", "icon": "🍪", "color": "#FF8A65", "parent_id": 1, "sort_order": 4},
    {"name": "饮品", "icon": "🧃", "color": "#FF8A65", "parent_id": 1, "sort_order": 5},
    {"name": "调味品", "icon": "🧂", "color": "#FF8A65", "parent_id": 1, "sort_order": 6},
    {"name": "粮油", "icon": "🍚", "color": "#FF8A65", "parent_id": 1, "sort_order": 7},
    {"name": "速食", "icon": "🍜", "color": "#FF8A65", "parent_id": 1, "sort_order": 8},
    
    # 日用清洁
    {"name": "日用清洁", "icon": "🧹", "color": "#4DB6AC", "parent_id": None, "sort_order": 2},
    {"name": "洗衣", "icon": "🧺", "color": "#4DB6AC", "parent_id": 10, "sort_order": 1},
    {"name": "厨房清洁", "icon": "🧼", "color": "#4DB6AC", "parent_id": 10, "sort_order": 2},
    {"name": "纸巾", "icon": "🧻", "color": "#4DB6AC", "parent_id": 10, "sort_order": 3},
    {"name": "垃圾袋", "icon": "🗑️", "color": "#4DB6AC", "parent_id": 10, "sort_order": 4},
    
    # 个护美妆
    {"name": "个护美妆", "icon": "🧴", "color": "#F06292", "parent_id": None, "sort_order": 3},
    {"name": "洗护", "icon": "🛁", "color": "#F06292", "parent_id": 15, "sort_order": 1},
    {"name": "口腔", "icon": "🦷", "color": "#F06292", "parent_id": 15, "sort_order": 2},
    {"name": "护肤", "icon": "💆", "color": "#F06292", "parent_id": 15, "sort_order": 3},
    {"name": "彩妆", "icon": "💄", "color": "#F06292", "parent_id": 15, "sort_order": 4},
    
    # 药品保健
    {"name": "药品保健", "icon": "💊", "color": "#7986CB", "parent_id": None, "sort_order": 4},
    {"name": "常用药", "icon": "🩹", "color": "#7986CB", "parent_id": 20, "sort_order": 1},
    {"name": "保健品", "icon": "🌿", "color": "#7986CB", "parent_id": 20, "sort_order": 2},
    {"name": "医疗器械", "icon": "🏥", "color": "#7986CB", "parent_id": 20, "sort_order": 3},
    
    # 家用电器
    {"name": "家用电器", "icon": "📺", "color": "#FFD54F", "parent_id": None, "sort_order": 5},
    {"name": "大家电", "icon": "🖥️", "color": "#FFD54F", "parent_id": 24, "sort_order": 1},
    {"name": "小家电", "icon": "🧊", "color": "#FFD54F", "parent_id": 24, "sort_order": 2},
    {"name": "数码", "icon": "📱", "color": "#FFD54F", "parent_id": 24, "sort_order": 3},
    
    # 衣物鞋帽
    {"name": "衣物鞋帽", "icon": "👕", "color": "#F06292", "parent_id": None, "sort_order": 6},
    
    # 其他
    {"name": "其他", "icon": "📦", "color": "#A1887F", "parent_id": None, "sort_order": 7},
]


# 位置模板（用户注册创建家庭时复制）
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


async def seed_categories(session: AsyncSession):
    """初始化系统预设分类"""
    result = await session.execute(
        select(Category).filter(Category.is_system == True)
    )
    existing = result.scalars().first()
    
    if existing:
        print("系统预设分类已存在，跳过")
        return
    
    print("正在初始化系统预设分类...")
    
    # 创建分类，按层级顺序创建（先创建父分类）
    category_map = {}
    
    # 首先创建所有父分类（parent_id为None的）
    for cat in SYSTEM_CATEGORIES:
        if cat["parent_id"] is None:
            category = Category(
                name=cat["name"],
                icon=cat["icon"],
                color=cat["color"],
                parent_id=None,
                sort_order=cat["sort_order"],
                is_system=True,
                is_active=True,
                family_id=None
            )
            session.add(category)
            await session.flush()
            category_map[cat["name"]] = category.id
    
    # 然后创建子分类
    for cat in SYSTEM_CATEGORIES:
        if cat["parent_id"] is not None:
            # 找到父分类名称
            parent_name = None
            for i, parent_cat in enumerate(SYSTEM_CATEGORIES):
                if i + 1 == cat["parent_id"]:
                    parent_name = parent_cat["name"]
                    break
            
            if parent_name and parent_name in category_map:
                parent_id = category_map[parent_name]
                category = Category(
                    name=cat["name"],
                    icon=cat["icon"],
                    color=cat["color"],
                    parent_id=parent_id,
                    sort_order=cat["sort_order"],
                    is_system=True,
                    is_active=True,
                    family_id=None
                )
                session.add(category)
                await session.flush()
                category_map[cat["name"]] = category.id
    
    await session.commit()
    print(f"成功创建 {len(category_map)} 个系统预设分类")


async def main():
    """主函数"""
    print("=" * 50)
    print("HomeStock 预设数据初始化")
    print("=" * 50)
    
    # 创建表
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async with AsyncSession(async_engine) as session:
        await seed_categories(session)
    
    print("\n初始化完成！")


if __name__ == "__main__":
    asyncio.run(main())
