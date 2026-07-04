# Phase 2–3 HomeStock 交互优化落地

> 日期：2026-07-01  
> 依据：[`20260701_homestock_theme_interaction_reference.md`](20260701_homestock_theme_interaction_reference.md)

---

## 变更摘要

在回退邻里 Mock 业务后，按规范文档推进 **Phase 2 核心路径** 与 **Phase 3 部分能力**。

### Phase 2

| 任务 | 实现 |
|------|------|
| 物品列表暖色 + 筛选 Chip | `item_list_page.dart` → `WarmScaffold` + `FilterChipBar` + `AsyncListBody` |
| 添加入库分步向导 | `add_item_wizard_view.dart`（分类→信息→位置→时效） |
| 详情底栏 CTA | `item_detail_page.dart` → 记消耗 / 编辑 / 提醒 |
| 列表三态统一 | 分页 Tab、空间/分类 Tab 使用 `AsyncListBody` |

### Phase 3

| 任务 | 实现 |
|------|------|
| 今日待办摘要条 | 首页 `TodayAlertBanner` → `/alerts` |
| 按空间横滑分区 | `home_space_section.dart`，数据来自 `spacesProvider` |
| 搜索→场景联动 | `item_location_link_banner.dart`；搜「厨房」等 → `/items?location=` |
| 「+」弹层 | 第三项跳转「要处理」Tab |

### 路由扩展

- `/items?location=厨房` — 预填位置筛选，切到「全部」Tab
- `/items?tab=space|action|category|all` — 预选 Tab

---

## 影响范围

- `HomeWareClient/lib/presentation/items/**`
- `HomeWareClient/lib/presentation/home/**`
- `HomeWareClient/lib/presentation/search/**`
- `HomeWareClient/lib/core/router/app_router.dart`
- `HomeWareClient/lib/core/constants/search_constants.dart`

---

## 提测要点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 物品列表 | 暖色 AppBar、状态 Chip、触底加载 |
| T2 | 添加入库 | 4 步向导，可上一步/下一步，最后步保存 |
| T3 | 物品详情 | 底栏：记消耗、编辑、提醒（弹层改天数/安全库存） |
| T4 | 首页 | 有过期/低库存时显示摘要条；底部「按空间」横滑 |
| T5 | 搜索「厨房」 | 显示空间联动 Banner，跳转物品列表并筛选 |
| T6 | 首页空间卡片 | 点击跳转 `/items?location=xxx` |

---

## 未纳入本次

- 录入草稿 / 扫码预填（Phase 3 后续）
- 提醒中心、位置页全站暖色（P2 优先级）
- 统计与浪费洞察
