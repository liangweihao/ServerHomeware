# 回退邻里 Mock 业务，对齐 HomeStock 产品

> 日期：2026-07-01  
> 依据：[`20260701_homestock_theme_interaction_reference.md`](20260701_homestock_theme_interaction_reference.md)

---

## 变更摘要

移除误引入的「邻里服务 / 家政 / 门店 / 发服务」等业务代码，保留 **主题 + 通用交互** 改造。

### 已删除

- `lib/presentation/community/**` 全部
- `lib/data/community/community_home_mock_data.dart`
- `lib/core/models/community_service.dart`
- `lib/core/constants/community_constants.dart`
- `lib/core/providers/community_scope_provider.dart`
- `lib/presentation/profile/widgets/family_activity_section.dart`
- `lib/presentation/search/widgets/item_service_link_banner.dart`
- `lib/presentation/home/widgets/home_layer_header.dart`
- `lib/presentation/common/widgets/community_scaffold.dart`
- 路由 `/services/publish`、`/services/category/:slug`、`/services/:id`

### 已保留 / 调整

| 能力 | 文件 |
|------|------|
| 暖色 Scaffold | `warm_scaffold.dart`（自 community_scaffold 更名） |
| 搜索页结构 | `search_page.dart`：历史 + 物品热词 + 物品推荐分区 |
| 搜索联动 | `item_alert_link_banner.dart` → 临期/低库存列表 |
| 「+」弹层 | `publish_action_sheet.dart`：入库 / 扫码 / 物品列表 |
| 通用组件 | `tag_chip.dart`、`filter_chip_bar.dart`、`async_list_body.dart` |
| 物品卡副信息 | `home_item_card.dart` 位置行 |
| 首页 | 恢复四分区物品单页，无「邻里」层 |
| 个人中心 | `WarmScaffold`，移除「我的发布」与邻里范围 |

### 搜索热词（物品向）

`临期`、`低库存`、`厨房`、`冰箱`、`牛奶`、`过期`

---

## 提测要点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 首页 | 仅四分区物品，无家政/托管文案 |
| T2 | 「+」 | 入库 / 扫码 / 物品列表 |
| T3 | 搜索 | 热词与推荐均为物品相关 |
| T4 | 搜「牛奶」 | 提示查看临期列表（非邻里服务） |
| T5 | 路由 | `/services/*` 不可达 |
