# 吸引力优化：录入草稿 + 记消耗一键入口

> 日期：2026-07-01

---

## 一、录入草稿

### 行为

- 离开添加入库页（未保存成功）→ 自动写入本地草稿
- 再次进入 `/items/add` → 弹窗「继续录入 / 重新开始」
- 「+」弹层有草稿时显示 **继续录入** → `/items/add?resumeDraft=1`
- 保存入库成功 → 清除草稿

### 文件

| 文件 | 说明 |
|------|------|
| `item_add_draft_storage.dart` | SharedPreferences JSON 持久化 |
| `item_form_controller.dart` | `toDraftMap` / `applyDraftMap` / `hasDraftContent` |
| `add_item_page.dart` | PopScope 自动保存、恢复对话框 |
| `publish_action_sheet.dart` | 继续录入入口 |
| `app_router.dart` | `resumeDraft=1` query |

---

## 二、记消耗一键入口

### 行为

- 「+」弹层第一项 **记消耗**
- 底部弹层：搜索 + 物品列表
- **用1件**：无二次弹窗，直接记 1 件消耗
- **点行**：打开完整使用记录弹窗（可调数量）

### 文件

| 文件 | 说明 |
|------|------|
| `quick_consume_provider.dart` | 可消耗物品列表 |
| `quick_consume_sheet.dart` | 记消耗 UI |
| `usage_dialog.dart` | `recordQuickUsage` |
| `publish_action_sheet.dart` | 入口 |
| `home_top_bar.dart` | 传入 `WidgetRef` |

---

## 提测

| 场景 | 预期 |
|------|------|
| 录入一半返回 | 再进有恢复提示 |
| + 有草稿 | 显示「继续录入」 |
| 记消耗 → 用1件 | SnackBar 确认，库存减 1 |
| 记消耗 → 点行 | 完整弹窗 |
