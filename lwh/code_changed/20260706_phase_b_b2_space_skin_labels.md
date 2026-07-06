# Phase B B2 — 文案皮肤层

**日期**：2026-07-06  
**状态**：B2 已交付（待联调）  
**关联**：[phase-b-shop-skin-prd.md](../../doc/product/phase-b-shop-skin-prd.md) · [20260704_phase_b_b1_space_type.md](./20260704_phase_b_b1_space_type.md)

---

## 一、实现方案

### 核心：`SpaceSkinConfig` 扩展

`home` / `shop` 两套 copy map，含：

| 类别 | home 示例 | shop 示例 |
|------|-----------|-----------|
| 出库 | 用了 1 | 卖出 1 |
| 清单 | 购物清单 | 采购清单 |
| 库存提示 | 家里暂无 | 店里暂无 |
| 危机 | 快见底了 | 快断货了 |
| 管管欢迎/建议 | 厨房有什么 | 店面有什么 |
| 面板熟练度空间 | 厨房 | 店面 |

管管动态话术（庆祝、危机、周报、助手回复）作为 `SpaceSkinConfig` 实例方法，不再在 UI 硬编码。

### 接入页面 / 模块

| 区域 | 改动 |
|------|------|
| 物品详情 / QuickConsume | `consumeQuickLabel` |
| 购物清单 | 标题、分享、空态、M4 库存文案 |
| 提醒中心 / AlertCard | 今天用掉→今天卖出、加入采购清单 |
| 首页 | 搜索 hint、危机 Banner、管管面板/结算/周报 |
| 问管管 | `AssistantExecutor(skin)` 全链路文案 |
| 个人中心 | 快捷入口、概览条 |
| 快捷操作弹层 | 记消耗/进货 |

### 兼容

- `GuanguanCopy` 保留为 **home 默认** 委托，旧单测与未改路径无回归
- `space_type=home` 与 Phase A 文案一致

---

## 二、提测

| # | 步骤 | home 预期 | shop 预期 |
|---|------|-----------|-----------|
| 1 | 物品详情一键出库 | 「用了 1」 | 「卖出 1」 |
| 2 | 购物清单页标题 | 购物清单 | 采购清单 |
| 3 | 清单项库存 | 家里暂无 / 现有 x | 店里暂无 / 现有 x |
| 4 | 提醒卡片低库存 | 加入购物清单 | 加入采购清单 |
| 5 | 首页危机 Banner 低库存 | 快见底了 | 快断货了 |
| 6 | 问管管欢迎语 | 物品/空间 | 商品/货架 |
| 7 | 管管周报成就 | 本周零浪费 | 本周零断货 |
| 8 | 个人中心快捷项 | 添加入库 / 购物清单 | 进货 / 采购清单 |

### 自动化

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/config/space_skin_config_test.dart
C:\flutter\bin\flutter.bat test test/core/utils/shopping_stock_helper_test.dart
C:\flutter\bin\flutter.bat test test/core/assistant/guanguan_panel_builder_test.dart
C:\flutter\bin\flutter.bat test test/core/assistant/guanguan_weekly_insight_builder_test.dart
```

---

## 三、已知限制（B3/B4）

- 店铺仍 seed **家庭**位置树（B3）
- 问管管 Parser 未增「卖出/货架」 utterance（B4）
- 危机优先级仍为 home 口径：过期 > 临期 > 低库存（B4 改 shop）
- 部分次级页（添加入库向导标题、统计「消耗」）仍为通用/家庭词

---

## 四、下一步

- **B3** shop 默认分类/位置 seed
- **B4** 管管店铺词表 + 断货优先 Banner
