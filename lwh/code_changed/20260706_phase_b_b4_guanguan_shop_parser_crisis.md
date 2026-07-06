# Phase B4 — 管管店铺词表 + 危机优先级

**日期**：2026-07-06  
**范围**：HomeWareClient（Parser / 危机 / Banner / 提醒中心）  
**关联 PRD**：[phase-b-shop-skin-prd.md](../../doc/product/phase-b-shop-skin-prd.md) §7.3

---

## 一、技术开发文档

### 实现方案

| 任务 | 实现 |
|------|------|
| B4-1 店铺 Parser 词表 | `AssistantParser` 增断货/补货/还剩多少关键词 |
| B4-2 管管 shop 话术 | B2 已在 `SpaceSkinConfig.shop` 覆盖欢迎语与 suggestions |
| B4-3 NL 进货 | `AddItemNlParser` 前缀增 `进了/进货/补货` |
| B4-4 单测 | 新增 `assistant_parser_shop_test.dart`（9 条店铺用例） |
| B4-5 危机优先级 | `SpaceCrisisPriority` + `resolveDailyCrisis(stats, spaceType:)` |
| B4-6 Banner 文案 | `SpaceSkinConfig` 增 Chip/统计行；`TodaySummaryBanner` 接 skin |
| B4-7 提醒默认 Tab | `AlertCenterPage` shop 无 `?tab=` 时默认 `AlertTab.stock` |

### 危机选取策略

- **home**（默认）：已过期 → 临期 → 低库存
- **shop**：低库存/断货 → 临期 → 已过期

### 改动文件

- `lib/core/assistant/assistant_parser.dart`
- `lib/core/assistant/add_item_nl_parser.dart`
- `lib/core/assistant/daily_crisis_helper.dart`
- `lib/core/config/space_skin_config.dart`
- `lib/presentation/home/widgets/today_summary_banner.dart`
- `lib/presentation/alerts/alert_center_page.dart`
- `test/core/assistant/assistant_parser_shop_test.dart`（新）
- `test/core/assistant/daily_crisis_helper_test.dart`
- `test/core/assistant/add_item_nl_parser_test.dart`

### 影响范围

- 店铺空间：管管可识别店面/A架/库房查询、红牛还剩多少、快断货、今天要补什么、进了10箱可乐
- 首页危机 Banner 在 shop 下优先展示断货 SKU
- 提醒中心进入时默认落在低库存 Tab（路由带 `?tab=` 时不受影响）
- 家庭空间行为不变（危机仍过期优先）

---

## 二、提测开发文档

### 测试点

1. **管管店铺查询**
   - 「店面有什么」「A架有什么」→ 空间物品列表
   - 「红牛还剩多少」→ 商品位置+余量
   - 「什么快断货」「今天要补什么」→ 对应提醒列表

2. **NL 进货**
   - 「进了10箱可乐放店面」→ 预填名称/数量/位置，跳转确认进货

3. **危机 Banner（shop 空间，需有低库存+临期数据）**
   - 主危机应为低库存 SKU，headline 含「快断货」
   - Chip 显示「先处理断货」「断货」而非「先补货」「低库存」

4. **提醒中心**
   - shop 空间从 Tab 进入提醒中心 → 默认低库存 Tab
   - home 空间仍默认「全部」

### 验证方式

```powershell
cd HomeWareClient
flutter test test/core/assistant/assistant_parser_shop_test.dart
flutter test test/core/assistant/daily_crisis_helper_test.dart
```

手动：创建 shop 空间 → 录入临期+低库存商品 → 看首页 Banner 与提醒中心默认 Tab。

### 注意事项

- Parser 关键词为全局合并，不区分 skin；家庭用户说「断货」也会命中低库存查询（可接受）
- `space_skin_config.shop.addItemExamples` 中「2打啤酒」示例单位「打」尚未加入 qty 正则，实测请用「瓶/箱」等已有单位
- `AlertCenterPage` TabController 在 `didChangeDependencies` 初始化，首帧可能短暂 loading

---

## 三、后续

- Phase B Gate：小店北极星三问走查（问管管 / 危机 Banner / 提醒 Tab）
- B+：售价、CSV、报表等
