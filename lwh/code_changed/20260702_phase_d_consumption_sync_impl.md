# Phase D — 消耗估算后端对齐 + 同步

**日期**：2026-07-02  
**状态**：已实施

---

## 一、技术开发文档

### 问题背景

Phase K 客户端已支持「预计使用天数」，但存在三处断点：

1. `CreateItemRequest` / `UpdateItemRequest` 未声明预测字段 → 入参被丢弃  
2. `item_service.update_item` 白名单不含预测字段  
3. `item_sync_service.dart` 同步时将 `avgDailyConsumption` / `predictedEmptyDate` 写为 `Value.absent()`

### 后端改动

| 文件 | 改动 |
|------|------|
| `app/schemas/item.py` | `CreateItemRequest` / `UpdateItemRequest` 增加 `avg_daily_consumption`、`predicted_empty_date`、`estimated_use_days` |
| `app/services/consumption_estimate.py` | 新增 `apply_user_consumption_estimate()` — 手填 avg/date 或按天数推算 |
| `app/services/item_service.py` | 创建/更新前调用估算；列表 API 返回预测字段；update 白名单扩展 |
| `tests/test_consumption_estimate.py` | 单元测试 |

**优先级策略**：

- 请求同时带 `avg` + `predicted_empty_date` → 原样持久化  
- 仅带 `avg` → 按 `current_quantity` 补全日期  
- 带 `estimated_use_days` → 推算 avg 与 date  
- 后续 `prediction_service` / 定时任务仍可按使用记录重算（未改）

### 客户端改动

| 文件 | 改动 |
|------|------|
| `core/utils/item_server_mapper.dart` | JSON → Drift 预测字段映射 |
| `core/services/item_sync_service.dart` | 插入/更新时写入预测字段；已存在物品 sync 时合并 |
| `item_form_controller.dart` | `loadFromItem` 反推 `estimatedUseDays`；`applyToExistingItem` 写入预测 |
| `add_item_wizard_view.dart` | 编辑模式也可改「预计使用天数」 |
| `test/core/utils/item_server_mapper_test.dart` | 映射单测 |

---

## 二、提测开发文档

### 测试点

| ID | 场景 | 预期 |
|----|------|------|
| D-T1 | 新建物品 Step4 填预计 7 天 | POST 成功；GET 详情含 avg/date |
| D-T2 | 设备 B 触发 sync | 详情「状态总览」预测文案与 A 一致 |
| D-T3 | 编辑物品改预计天数 | PUT 后服务端字段更新 |
| D-T4 | 重启 App | 预测字段不丢失 |

### 验证命令

```powershell
# 后端
cd HomeWareServer
python -m pytest tests/test_consumption_estimate.py -q

# 客户端
cd HomeWareClient
flutter test test/core/utils/item_server_mapper_test.dart
flutter test test/presentation/items/item_form_consumption_test.dart
```

### 注意事项

- 列表 sync 依赖 GET `/items` 返回 `avg_daily_consumption` / `predicted_empty_date`（已补）  
- 编辑时若用户未改预计天数，`applyToExistingItem` 用 `Value.absent()` 保留原预测  
- 使用记录足够多时，服务端定时任务可能覆盖手填值（预期行为）

---

## 三、影响范围

- **后端**：物品创建/更新/列表 API  
- **客户端**：全量 sync、添加入库、编辑物品  
- **下一步**：Phase B OCR MVP（需 D 联调通过后启动）
