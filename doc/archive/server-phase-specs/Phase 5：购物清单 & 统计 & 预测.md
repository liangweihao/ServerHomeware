# HomeStock Server — Phase 5：购物清单 & 统计 & 预测

## 前置条件
Phase 1-4 已完成。

## 本阶段目标
完善购物清单功能、实现数据统计接口、完善消耗预测算法。

---

## 任务1：购物清单 API

**GET /api/v1/shopping**
```
查询参数：
- status: pending/purchased/all
- page, page_size
响应：分页列表，每项附带关联物品信息（如有）
```

**POST /api/v1/shopping**
```
说明：手动添加购物项
请求：{name, quantity, unit, estimated_price(可选), related_item_id(可选)}
```

**PUT /api/v1/shopping/{id}**
```
请求：{quantity, unit, estimated_price, priority}
```

**PUT /api/v1/shopping/{id}/purchase**
```
说明：标记已购买
请求：{actual_price(可选)}
逻辑：
- is_purchased=True, purchased_at=now, purchased_by=当前用户
- 如果有 related_item_id 且该物品 status=1(用完)，提示"是否入库"
```

**POST /api/v1/shopping/{id}/to-item**
```
说明：从已购物品一键创建入库（跳过手动填写）
请求：{location_id(可选), expiry_date(可选)}
逻辑：
- 根据 related_item_id 获取历史物品信息
- 复制信息创建新 Item（或恢复原物品的数量）
- 标记购物项为已完成
```

**PUT /api/v1/shopping/purchase-all**
```
说明：全部标记已购买
```

**DELETE /api/v1/shopping/{id}**

**GET /api/v1/shopping/share-text**
```
说明：生成分享文本
响应：
{
  "text": "📋 购物清单 (2024-01-25)\n- 洗衣液 3kg ×1\n- 纯牛奶 ×6\n...",
  "total_estimated": 152.6
}
```

---

## 任务2：统计 API

**GET /api/v1/statistics/overview**
```
查询参数：period=week/month/year, date(可选，默认当前)
响应：
{
  "period": "month",
  "date_range": {"start": "2024-01-01", "end": "2024-01-31"},
  
  "expense": {
    "total": 2847.5,
    "previous_total": 2542.0,
    "trend_percentage": 12.0,  // 比上期+12%
    "trend_direction": "up"
  },
  
  "inventory": {
    "total_items": 95,
    "new_items": 23,
    "consumed_items": 18,
    "warning_items": 5
  }
}
```

**GET /api/v1/statistics/expense-trend**
```
查询参数：months=6（近几个月）
响应：
{
  "data": [
    {"month": "2023-08", "amount": 2100.0},
    {"month": "2023-09", "amount": 2350.0},
    ...
  ]
}
说明：用于折线图
```

**GET /api/v1/statistics/category-breakdown**
```
查询参数：period=month, date
响应：
{
  "data": [
    {"category_id": 1, "name": "食品饮料", "color": "#FF8A65", "amount": 1280.0, "percentage": 45.0},
    {"category_id": 2, "name": "日用清洁", "color": "#4DB6AC", "amount": 710.0, "percentage": 25.0},
    ...
  ]
}
说明：用于饼图
```

**GET /api/v1/statistics/waste**
```
查询参数：period=month, date
响应：
{
  "total_count": 3,
  "total_amount": 47.5,
  "items": [
    {"name": "有机生菜", "price": 15.8, "expired_at": "2024-01-20", "reason": "过期未食用"},
    ...
  ],
  "suggestion": "建议：减少叶菜类一次购买量"
}
说明：统计过期丢弃数据
数据来源：usage_records type=2(丢弃) 在该时间段内
```

**GET /api/v1/statistics/consumption-ranking**
```
查询参数：period=month, limit=10
响应：
{
  "data": [
    {"item_name": "纯牛奶", "total_consumed": 12, "unit": "盒", "total_cost": 155.0},
    {"item_name": "抽纸", "total_consumed": 8, "unit": "包", "total_cost": 96.0},
    ...
  ]
}
数据来源：usage_records type=1(使用) 按item_id聚合
```

---

## 任务3：消耗预测服务

### prediction_service.py

**calculate_avg_daily_consumption(item_id)**
```
算法：
1. 查询该物品所有 type=1(使用) 的 usage_records，按 created_at 排序
2. 如果记录 < 2 条：
   - consumed = purchase_quantity - current_quantity
   - days = (today - item.created_at).days
   - 如果 days <= 0：返回 0
   - 返回 consumed / days
3. 如果记录 >= 2 条：
   - 加权平均法：
   - 遍历相邻记录对(i, i+1)
   - interval_days = (record[i+1].created_at - record[i].created_at).days
   - 如果 interval_days <= 0：跳过
   - rate = record[i+1].quantity / interval_days
   - weight = i + 1（序号越大=越近=权重越高）
   - avg = sum(rate × weight) / sum(weight)
   - 返回 avg
```

**predict_empty_date(item_id)**
```
avg = calculate_avg_daily_consumption(item_id)
如果 avg <= 0：返回 None
如果 current_quantity <= 0：返回 today
days_remaining = current_quantity / avg
返回 today + days_remaining
```

**batch_update_predictions()**
```
遍历所有 status=0 的物品：
计算 avg_daily_consumption
计算 predicted_empty_date
更新 items 表
此方法由 Celery Beat 每日调用一次
```

### 预测 API

**GET /api/v1/items/{id}/prediction**
```
响应：
{
  "avg_daily_consumption": 0.28,
  "predicted_empty_date": "2024-02-05",
  "days_until_empty": 10,
  "confidence": "medium",  // low(<3条记录)/medium(3-10条)/high(>10条)
  "should_repurchase": true,
  "usage_history": [
    {"date": "2024-01-25", "quantity": 1, "operator": "妈妈"},
    ...
  ]
}
```

---

## 任务4：智能购物推荐增强

**GET /api/v1/shopping/recommendations**
```
说明：获取系统推荐的购物项（实时计算，不存储）
逻辑：
遍历所有 status=0 物品：
1. 已低于安全库存 → 推荐（优先级高）
2. 预计7天内用完 → 推荐（优先级中）
3. 预计14天内用完 → 推荐（优先级低）
过滤掉已在购物清单中的

响应：
{
  "recommendations": [
    {
      "item_id": 12,
      "item_name": "洗衣液",
      "reason": "预计3天后用完",
      "priority": "high",
      "suggested_quantity": 1,
      "suggested_unit": "瓶",
      "last_price": 39.9,
      "last_channel": "京东"
    },
    ...
  ]
}
```

---

## 验收标准

1. ✅ 购物清单 CRUD 完整可用
2. ✅ 标记已购买状态正确更新
3. ✅ 一键入库从历史物品复制信息
4. ✅ 分享文本格式正确
5. ✅ 统计概览数据准确（金额、数量、趋势）
6. ✅ 消费趋势数据可用于折线图
7. ✅ 分类占比数据可用于饼图
8. ✅ 浪费统计正确关联丢弃记录
9. ✅ 消耗排行正确聚合
10. ✅ 预测算法输出合理的日均消耗和预计日期
11. ✅ 购物推荐逻辑正确，优先级分明
12. ✅ 批量更新预测任务正常执行