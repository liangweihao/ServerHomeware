"""
Phase B — 家庭 / 店铺默认位置与分类模板
"""
from app.core.space_type import SPACE_TYPE_HOME, SPACE_TYPE_SHOP

# 家庭位置模板（创建 home 空间时复制）
HOME_LOCATION_TEMPLATE = [
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
                    {"name": "门侧", "icon": "🚪"},
                ],
            },
            {
                "name": "吊柜",
                "icon": "🚪",
                "children": [
                    {"name": "一层", "icon": "1️⃣"},
                    {"name": "二层", "icon": "2️⃣"},
                    {"name": "三层", "icon": "3️⃣"},
                ],
            },
            {"name": "调料架", "icon": "🧂"},
            {"name": "水槽下方", "icon": "🚿"},
            {"name": "台面", "icon": "🪑"},
        ],
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
                    {"name": "下方", "icon": "⬇️"},
                ],
            },
            {"name": "浴室柜", "icon": "🗄️"},
            {"name": "马桶旁", "icon": "🚽"},
        ],
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
                    {"name": "下方", "icon": "⬇️"},
                ],
            },
            {"name": "书架", "icon": "📚"},
        ],
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
                    {"name": "抽屉", "icon": "🗄️"},
                ],
            },
            {
                "name": "床头柜",
                "icon": "🛏️",
                "children": [
                    {"name": "台面", "icon": "🪑"},
                    {"name": "抽屉", "icon": "🗄️"},
                ],
            },
            {"name": "梳妆台", "icon": "🪞"},
        ],
    },
    {
        "name": "次卧",
        "icon": "🛏️",
        "children": [
            {"name": "衣柜", "icon": "🗄️"},
            {"name": "书桌", "icon": "🖥️"},
        ],
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
                    {"name": "下层", "icon": "⬇️"},
                ],
            },
            {"name": "晾衣区", "icon": "👕"},
        ],
    },
]

# 店铺位置模板 — 店面/A架/B架/冷柜
SHOP_LOCATION_TEMPLATE = [
    {
        "name": "店面",
        "icon": "🏪",
        "sort_order": 1,
        "children": [
            {"name": "A架", "icon": "🅰️", "sort_order": 1},
            {"name": "B架", "icon": "🅱️", "sort_order": 2},
            {"name": "冷柜", "icon": "🧊", "sort_order": 3},
        ],
    },
    {"name": "库房", "icon": "📦", "sort_order": 2},
    {"name": "柜台", "icon": "🧾", "sort_order": 3},
]

# 店铺分类模板 — 写入 family_id（非全局 system）
SHOP_CATEGORY_TEMPLATE = [
    {"name": "烟酒百货", "icon": "🚬", "color": "#8D6E63", "sort_order": 1},
    {"name": "饮料", "icon": "🥤", "color": "#42A5F5", "sort_order": 2},
    {"name": "休闲食品", "icon": "🍿", "color": "#FFA726", "sort_order": 3},
    {"name": "日用洗护", "icon": "🧴", "color": "#4DB6AC", "sort_order": 4},
    {"name": "其他", "icon": "📦", "color": "#A1887F", "sort_order": 99},
]


def location_template_for(space_type: str) -> list:
    """按空间类型返回位置模板"""
    if space_type == SPACE_TYPE_SHOP:
        return SHOP_LOCATION_TEMPLATE
    return HOME_LOCATION_TEMPLATE


def should_seed_shop_categories(space_type: str) -> bool:
    """店铺空间需额外写入家庭级分类"""
    return space_type == SPACE_TYPE_SHOP
