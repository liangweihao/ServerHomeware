"""
统计相关的请求/响应模型
"""
from typing import List, Optional

from pydantic import BaseModel, Field


class PeriodRange(BaseModel):
    """时间段"""
    
    start: str = Field(..., description="开始日期")
    end: str = Field(..., description="结束日期")


class ExpenseData(BaseModel):
    """消费数据"""
    
    total: float = Field(..., description="总消费")
    previous_total: float = Field(..., description="上期消费")
    trend_percentage: float = Field(..., description="环比增长率")
    trend_direction: str = Field(..., description="趋势方向: up/down/same")


class InventoryData(BaseModel):
    """库存数据"""
    
    total_items: int = Field(..., description="物品总数")
    new_items: int = Field(..., description="新增物品数")
    consumed_items: int = Field(..., description="消耗物品数")
    warning_items: int = Field(..., description="预警物品数")


class OverviewResponse(BaseModel):
    """统计概览响应"""
    
    period: str = Field(..., description="统计周期")
    date_range: PeriodRange = Field(..., description="日期范围")
    expense: ExpenseData = Field(..., description="消费数据")
    inventory: InventoryData = Field(..., description="库存数据")


class ExpenseTrendItem(BaseModel):
    """消费趋势项"""
    
    month: str = Field(..., description="月份")
    amount: float = Field(..., description="消费金额")


class CategoryBreakdownItem(BaseModel):
    """分类占比项"""
    
    category_id: int = Field(..., description="分类ID")
    name: str = Field(..., description="分类名称")
    color: str = Field(..., description="显示颜色")
    amount: float = Field(..., description="消费金额")
    percentage: float = Field(..., description="占比百分比")


class WasteItem(BaseModel):
    """浪费物品项"""
    
    name: str = Field(..., description="物品名称")
    price: float = Field(..., description="价格")
    expired_at: str = Field(..., description="过期/丢弃日期")
    reason: str = Field(..., description="浪费原因")


class WasteResponse(BaseModel):
    """浪费统计响应"""
    
    total_count: int = Field(..., description="浪费物品总数")
    total_amount: float = Field(..., description="浪费总金额")
    items: List[WasteItem] = Field(..., description="浪费物品列表")
    suggestion: str = Field(..., description="建议")


class ConsumptionRankingItem(BaseModel):
    """消耗排行项"""
    
    item_name: str = Field(..., description="物品名称")
    total_consumed: float = Field(..., description="总消耗量")
    unit: str = Field(..., description="单位")
    total_cost: float = Field(..., description="总花费")
