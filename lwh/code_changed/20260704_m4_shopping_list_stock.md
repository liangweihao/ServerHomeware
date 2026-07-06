# M4 清单带库存

**日期**：2026-07-04  
**状态**：已完成  
**里程碑**：Phase A M4 — 购物清单显示「现有 x」

---

## 一、技术开发说明

### 目标

待购清单每一项旁展示家中现有库存，帮助用户在采购前避免重复购买。

### 实现方案

1. **`ShoppingStockSnapshot`** — 库存快照模型（总量、单位、是否可能重复采购）
2. **`shopping_stock_helper.dart`** — 纯函数解析：
   - `relatedItemId` 优先（系统推荐 / 提醒加入）
   - 名称精确匹配，合并同名在用物品
   - 唯一模糊包含匹配兜底
3. **`pendingShoppingStockProvider`** — 监听 `itemEventBus`，批量解析待购项
4. **`ShoppingItemCard`** — 新增 `stockLabel` / 重复采购提示
5. **`ShoppingListPage`** — 待购 Tab 顶部「还有货」提示条；分享清单附带现有量

### 展示规则

| 条件 | 文案 | 样式 |
|------|------|------|
| 有库存 | 现有 2 瓶 | 青色 Tag |
| 无匹配 / 库存 0 | 家里暂无 | 灰色 Tag |
| 现有 ≥ 计划购买量 | + 家里还有货，采购前确认 | 橙色 Tag + 提示 |

### 改动文件

| 路径 | 变更 |
|------|------|
| `core/utils/shopping_stock_helper.dart` | 新增 |
| `core/providers/shopping_stock_provider.dart` | 新增 |
| `presentation/shopping/widgets/shopping_item_card.dart` | 库存标签 UI |
| `presentation/shopping/shopping_list_page.dart` | 接入 provider + 提示条 |
| `test/core/utils/shopping_stock_helper_test.dart` | 新增单测 |
| `doc/product/current-phase.md` | M4 / A4 标记完成 |

### 影响范围

- 仅客户端购物清单页；无 DB 迁移、无后端变更
- 库存数据来自本地 Drift，与物品列表一致
- 为管管 P1「今日面板」补货任务提供数据基础

---

## 二、提测说明

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 系统推荐项（有 relatedItemId） | 显示该物品当前剩余量 |
| T2 | 手动添加「牛奶」，库里有牛奶 | 显示「现有 x 瓶」 |
| T3 | 手动添加库中不存在的物品 | 显示「家里暂无」 |
| T4 | 现有 3 瓶、计划买 1 瓶 | 橙色提示「家里还有货」 |
| T5 | 待购 Tab 有多项重复风险 | 顶部汇总提示条 |
| T6 | 物品详情记消耗后回到清单 | 现有量自动刷新 |
| T7 | 分享清单 | 每项下方含现有量行 |
| T8 | `shopping_stock_helper_test` | 5 用例全绿 |

### 验证命令

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/utils/shopping_stock_helper_test.dart
```

---

## 三、后续

- M4 完成后可启动 **管管 P1 今日面板**（见 `doc/product/guanguan-butler-panel-prd.md`）
- 下一主里程碑：**M5 录入减负**（规则 NL 预填入库）
