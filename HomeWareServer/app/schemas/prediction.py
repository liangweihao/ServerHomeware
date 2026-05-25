"""
预测相关的请求/响应模型
"""
from typing import List, Optional

from pydantic import BaseModel, Field


class ConsumptionHistoryItem(BaseModel):
    """消耗历史项"""
    
    date: str = Field(..., description="日期")
    quantity: float = Field(..., description="消耗数量")
    operator: Optional[str] = Field(None, description="操作人")


class ItemPredictionResponse(BaseModel):
    """物品预测响应模型"""
    
    avg_daily_consumption: float = Field(..., description="日均消耗量")
    predicted_empty_date: Optional[str] = Field(None, description="预计用完日期")
    days_until_empty: Optional[int] = Field(None, description="距离用完天数")
    confidence: str = Field(..., description="置信度: low/medium/high")
    should_repurchase: bool = Field(..., description="是否需要补货")
    usage_history: List[ConsumptionHistoryItem] = Field(..., description="使用历史")
