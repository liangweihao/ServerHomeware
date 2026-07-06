"""
空间类型常量 — Phase B 店铺皮肤
"""
SPACE_TYPE_HOME = "home"
SPACE_TYPE_SHOP = "shop"

VALID_SPACE_TYPES = frozenset({SPACE_TYPE_HOME, SPACE_TYPE_SHOP})
DEFAULT_SPACE_TYPE = SPACE_TYPE_HOME


def normalize_space_type(value: str | None) -> str:
    """校验并归一化 space_type，非法值回退 home"""
    if value is None:
        return DEFAULT_SPACE_TYPE
    normalized = value.strip().lower()
    if normalized not in VALID_SPACE_TYPES:
        return DEFAULT_SPACE_TYPE
    return normalized
