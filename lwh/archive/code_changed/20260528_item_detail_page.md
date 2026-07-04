# 物品详情页实现

## 背景

`ItemDetailPage` 此前为占位页；`doc/原型图.md` §四、`doc/appPhase/Phase 2` 任务4/5 已有完整 UI 与交互规格。

## 实现方案

| 文件 | 说明 |
|------|------|
| `item_detail_provider.dart` | 聚合物品、分类、位置、最近 5 条使用记录 |
| `item_detail_page.dart` | 详情 UI + 底部三按钮 + 更多菜单 |
| `widgets/usage_dialog.dart` | 记录使用弹窗（数量、操作人、全部用完） |
| `usage_records_page.dart` | 全部使用记录时间线 |
| `app_router.dart` | 新增 `/items/:id/records` |
| `doc/原型图.md` | 补充 §4.1 交互说明 |

## 未在本期实现

- `EditItemPage` 仍为占位（任务6，需复用 `AddItemPage` 预填）
- 图片仅为本地路径 JSON 解析，无网络图

## 提测要点

1. 从物品列表进入详情，信息完整（名称、分类、位置、指标、详情列表）
2. 「使用1件」弹窗：改数量、选操作人，确认后剩余量与记录更新
3. 「已用完」「再次购买」符合 Phase 2 逻辑
4. 更多菜单：移动位置、过期、丢弃、删除（删除后返回列表）
5. 「查看全部记录」进入记录页
6. 下拉刷新数据更新
