# HomeStock Server — Phase 4：提醒 & 推送 & 定时任务

## 前置条件
Phase 1-3 已完成。用户系统、CRUD、家庭协作就绪。

## 本阶段目标
实现服务端提醒检查、推送通知、定时任务系统。

---

## 任务1：Celery 配置

### celery_app.py
- Broker: Redis
- Result Backend: Redis
- 时区：Asia/Shanghai
- 序列化：JSON

### Beat 定时调度配置
| 任务 | 频率 | 说明 |
|------|------|------|
| check_expiry | 每天早上8:00 | 检查即将过期物品 |
| update_predictions | 每天凌晨2:00 | 批量更新消耗预测 |
| auto_expire_items | 每天凌晨1:00 | 自动将已过期物品状态改为2 |
| generate_shopping_suggestions | 每天早上9:00 | 自动生成购物推荐 |
| clean_old_notifications | 每周日凌晨3:00 | 清理30天前的通知记录 |

---

## 任务2：提醒检查任务

### check_expiry 任务逻辑
```
1. 查询所有 status=0 且 expiry_date 不为空 的物品
2. 对每个物品计算 days_until_expiry = expiry_date - today
3. 如果 days_until_expiry <= expiry_alert_days：
   - 生成提醒记录
   - 向该家庭所有成员推送通知
4. 如果 days_until_expiry == 0（今天过期）：
   - 推送紧急通知
5. 去重：同一个物品当天只推送一次（用 Redis 记录已推送）
```

### auto_expire_items 任务逻辑
```
UPDATE items SET status=2, updated_at=now
WHERE status=0 AND expiry_date < today
```

### generate_shopping_suggestions 任务逻辑
```
遍历所有 status=0 的物品：
IF (current_quantity <= safety_stock) OR (predicted_empty_date <= today + 7天)
AND shopping_list 中不存在该物品的未购买记录
THEN:
INSERT shopping_list（is_auto_generated=True）
```

---

## 任务3：Notification 模型 & API

### Notification 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK | |
| user_id | Integer, FK, nullable | null=全家庭，有值=特定用户 |
| type | String(30) | expiry/stock/purchase/warranty/system |
| title | String(100) | |
| body | String(500) | |
| item_id | Integer, nullable | 关联物品 |
| priority | String(10) | high/medium/low |
| is_read | Boolean, default False | |
| action_url | String(200), nullable | 点击跳转路径如 /items/123 |
| created_at | DateTime | |

### 提醒 API

**GET /api/v1/notifications**
```
查询参数：
- page, page_size
- type: expiry/stock/purchase/warranty（可选筛选）
- is_read: true/false（可选）
响应：分页通知列表
```

**GET /api/v1/notifications/unread-count**
```
响应：{count: 5}
用于 Flutter 端角标显示
```

**PUT /api/v1/notifications/{id}/read**
```
说明：标记单条已读
```

**PUT /api/v1/notifications/read-all**
```
说明：全部标记已读
```

**DELETE /api/v1/notifications/{id}**
```
说明：删除通知
```

---

## 任务4：提醒数据聚合 API（实时查询）

除了 Notification 存储型提醒，还提供实时查询接口（App打开时用）：

**GET /api/v1/alerts/summary**
```
说明：获取当前提醒摘要（首页StatCard用）
响应：
{
  "expiring_count": 5,      // 7天内过期数量
  "expired_count": 2,       // 已过期未处理
  "low_stock_count": 3,     // 库存不足
  "shopping_count": 8,      // 待购数量
  "nearest_expiry": {...},  // 最近要过期的物品简要信息
  "nearest_empty": {...}    // 最近要用完的物品简要信息
}
```

**GET /api/v1/alerts/expiring**
```
说明：获取即将过期物品列表
查询参数：days=7（几天内）
响应：物品列表 + 距离过期天数
```

**GET /api/v1/alerts/low-stock**
```
说明：获取库存不足物品列表
响应：物品列表 + 当前量 vs 安全线
```

---

## 任务5：推送通知服务

### notification_service.py

**push_to_user(user_id, title, body, data)**
```
逻辑：
1. 查询该用户的所有 device_token
2. 通过 FCM HTTP API 发送推送
3. 记录推送结果
4. 如果 token 失效则删除该设备记录
```

**push_to_family(family_id, title, body, data)**
```
逻辑：
1. 查询家庭所有成员的 device_token
2. 批量推送
```

**push_data 格式**
```json
{
  "type": "expiry_alert",
  "item_id": 123,
  "route": "/items/123"
}
```

Flutter端收到推送后根据 data.route 跳转对应页面。

### 推送模板

```
过期提醒：
  title: "⚠️ 物品即将过期"
  body: "{物品名} 还剩{N}天过期，请及时处理"

库存提醒：
  title: "📦 库存不足"  
  body: "{物品名} 剩余不足，预计{N}天后用完"

用完提醒：
  title: "🛒 物品已用完"
  body: "{物品名} 已经用完了，要补购吗？"
```

---

## 任务6：用户提醒偏好

### NotificationPreference 模型

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| user_id | Integer, FK, unique | |
| push_enabled | Boolean, default True | 全局开关 |
| expiry_alert | Boolean, default True | |
| stock_alert | Boolean, default True | |
| purchase_alert | Boolean, default True | |
| quiet_start | Time, nullable | 免打扰开始（如22:00） |
| quiet_end | Time, nullable | 免打扰结束（如08:00） |

**GET /api/v1/users/me/notification-preferences**
**PUT /api/v1/users/me/notification-preferences**

推送前检查用户偏好：
- push_enabled=False → 不推送
- 对应类型关闭 → 不推送
- 当前时间在免打扰时段 → 延迟到免打扰结束后推送

---

## 验收标准

1. ✅ Celery Worker 和 Beat 正常启动运行
2. ✅ 每日过期检查任务按时执行
3. ✅ 过期物品自动更新状态为已过期
4. ✅ 购物推荐自动生成到购物清单
5. ✅ 通知记录正确存储
6. ✅ 通知API：列表/未读数/标记已读 正常工作
7. ✅ 提醒摘要API正确返回各类计数
8. ✅ FCM推送正确发送（至少用测试token验证接口正确）
9. ✅ 免打扰时段内不推送
10. ✅ 用户偏好设置可保存并生效