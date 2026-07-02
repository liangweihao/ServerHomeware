"""消耗预测字段单元测试（直接加载模块，避免 services 包副作用）"""
import importlib.util
from datetime import date, timedelta
from pathlib import Path

_path = (
    Path(__file__).resolve().parents[1]
    / "app"
    / "services"
    / "consumption_estimate.py"
)
_spec = importlib.util.spec_from_file_location("consumption_estimate", _path)
_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_mod)
apply_user_consumption_estimate = _mod.apply_user_consumption_estimate


def test_apply_from_estimated_use_days():
    data = {"current_quantity": 10, "estimated_use_days": 5}
    apply_user_consumption_estimate(data)
    assert data["avg_daily_consumption"] == 2.0
    assert data["predicted_empty_date"] == date.today() + timedelta(days=5)
    assert "estimated_use_days" not in data


def test_apply_from_avg_only():
    data = {"current_quantity": 8, "avg_daily_consumption": 2.0}
    apply_user_consumption_estimate(data)
    assert data["predicted_empty_date"] == date.today() + timedelta(days=4)


def test_keep_both_when_provided():
    target = date.today() + timedelta(days=10)
    data = {
        "avg_daily_consumption": 1.5,
        "predicted_empty_date": target,
    }
    apply_user_consumption_estimate(data)
    assert data["predicted_empty_date"] == target
