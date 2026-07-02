# Phase D–H 执行完成记录

> 日期：2026-07-02

---

## 技术开发文档

### Phase D — Epic E4 录入增强

| 任务 | 实现 |
|------|------|
| D1 方式选择页 | `add_item_method_page.dart`，路由 `/items/add/method` |
| D1 首页「+」 | `home_top_bar.dart` → 方式选择页 |
| D2 扫码跳 Step3 | `scan_page.dart` 带 `step=location`；`add_item_page.dart` 支持 `initialStep` |
| D3 OCR 占位 | 方式选择页「拍照识别」→ SnackBar 敬请期待 |

### Phase E3 — 盘点任务 MVP

| 任务 | 实现 |
|------|------|
| 选空间 | `inventory_task_provider.dart` + 顶层位置列表 |
| 逐项核对 | 确认 / 修正（写回本地 Drift）/ 跳过 |
| 报告 | 完成后展示统计 |
| 入口 | Profile「盘点任务」→ `/profile/inventory` |

### Phase F — 工程债

- 删除无引用的 `cartoon_scaffold.dart`

### Phase G — 搜索联想

- `search_utils.dart` 纯函数过滤/联想
- `searchSuggestionsProvider` + 搜索页「搜索建议」横滑 Chip

### Phase H — 自动化测试

- `test/core/events/item_event_bus_test.dart`
- `test/core/utils/search_utils_test.dart`
- 修复 `test/widget_test.dart` 默认 counter 模板

### Phase I — E2 双设备验证清单

见 [`20260702_e2_websocket_verification.md`](20260702_e2_websocket_verification.md)

---

## 提测开发文档

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 首页「+」 | 进入方式选择页 |
| T2 | 扫码录入 | 识别后进向导「位置」步 |
| T3 | 拍照识别 | SnackBar 开发中 |
| T4 | Profile → 盘点任务 | 选空间 → 核对 → 报告 |
| T5 | 盘点修正数量 | 本地物品剩余量更新 |
| T6 | 搜索输入「牛」 | 显示搜索建议 Chip |
| T7 | `flutter test` | 全部通过 |

---

## 未纳入

- ItemCard / HomeItemCard 完全合并（改动面大，后续专项）
- OCR 真实识别 API
- 盘点结果同步服务端
