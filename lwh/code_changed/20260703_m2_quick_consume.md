# M2 一键消耗（Phase A）

**日期**：2026-07-03  
**状态**：已实现  
**关联**：[`20260703_product_direction_home_first.md`](./20260703_product_direction_home_first.md) M2

---

## 一、目标

家庭用户 **3 秒内** 记一次消耗，默认减 1，无需弹窗填表。

---

## 二、改动点

| 文件 | 说明 |
|------|------|
| `quick_consume_button.dart` | 可复用「用了 1 {unit}」按钮 |
| `item_detail_page.dart` | 状态区主按钮 + 底栏「改数量」 |
| `usage_dialog.dart` | 已有 `recordQuickUsage`，未改逻辑 |

### 交互

- **状态总览区**：大按钮「用了 1 盒」→ 一键 `recordQuickUsage`
- **底栏**：「改数量」→ 原完整弹窗（步进器 / 操作人 / 全部用完）
- **提醒入口** `action=consume`：自动一键消耗（不再弹窗）
- **提醒 Banner**：保持「记 1 件」+「记录使用」

---

## 三、提测

1. 使用中物品详情 → 点「用了 1」→ 库存减 1，SnackBar 显示剩余  
2. 减至 0 → 状态变用完，按钮消失  
3. 「改数量」仍可打开完整弹窗  
4. 从临期提醒进入 → 自动记 1（若带 consume action）  
5. 同步：usage_records + 服务端 + 提醒刷新  

---

## 四、下一步（M3）

首页 / 空间 **场景入口**（厨房、卫生间 Chip + 聚合列表）。
