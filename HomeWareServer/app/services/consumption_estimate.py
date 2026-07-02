"""
用户手填消耗预测 — 创建/更新物品时写入 avg_daily_consumption / predicted_empty_date
"""
from datetime import date, timedelta
from typing import Any, Dict


def apply_user_consumption_estimate(item_data: Dict[str, Any]) -> None:
    """
    就地解析用户预测字段：
    1. 同时传入 avg + predicted_empty_date → 直接保留
    2. 仅 avg → 按 current_quantity 补 predicted_empty_date
    3. estimated_use_days → 推算 avg 与 predicted_empty_date
    """
    estimated_days = item_data.pop("estimated_use_days", None)

    avg = item_data.get("avg_daily_consumption")
    predicted = item_data.get("predicted_empty_date")

    if avg is not None and predicted is not None:
        return

    qty_raw = item_data.get("current_quantity")
    if qty_raw is None:
        qty_raw = item_data.get("purchase_quantity", 1)
    try:
        qty = float(qty_raw) if qty_raw is not None else 1.0
    except (TypeError, ValueError):
        qty = 1.0

    if avg is not None and predicted is None:
        try:
            avg_val = float(avg)
        except (TypeError, ValueError):
            return
        if avg_val > 0 and qty > 0:
            days = max(1, int(round(qty / avg_val)))
            item_data["predicted_empty_date"] = date.today() + timedelta(days=days)
        return

    if estimated_days is not None:
        try:
            days = int(estimated_days)
        except (TypeError, ValueError):
            return
        if days <= 0:
            return
        item_data["avg_daily_consumption"] = qty / days
        item_data["predicted_empty_date"] = date.today() + timedelta(days=days)
