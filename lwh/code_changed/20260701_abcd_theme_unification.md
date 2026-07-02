# A+B+C+D 全站体验统一落地

> 日期：2026-07-01

---

## A — 提醒中心暖色 + 交互

- `alert_center_page.dart` → `WarmScaffold` + 标准 `TabBar`
- `AsyncListBody` 三态 + 下拉刷新
- `AlertCard` 增加 `onTap` 跳转物品详情
- 保留：全部已读、快捷操作（用掉/丢弃/加购）

## B — 批量迁移 CartoonScaffold（11 页）

已迁移至 `WarmScaffold`：

- 分类管理、编辑资料、通知设置、家庭管理
- 统计、位置概览/详情
- 编辑物品、使用记录
- 通知中心、购物清单

## C — ItemCard 工具风 + 详情去卡通

- `item_card.dart`：`AppColors.isUtilityStyle` 时白卡片 + `TagChip` + 副信息行
- `item_detail_page.dart`：分组改为白底卡片（去 `CartoonSectionCard`）

## D — 家庭协作

- `family_contribution_provider.dart`：本月入库/消耗排行（本地 usage_records）
- `family_contribution_section.dart`：排行 + 最近动态
- 个人中心面板接入「家庭协作」区块

## 其他

- `WarmScaffold`：支持 `bottom`（TabBar）、背景改为 `scaffoldBackground`

---

## 提测

| 场景 | 预期 |
|------|------|
| 提醒中心 | 暖色 Tab、空态、全部已读、点卡片进详情 |
| 位置/购物/编辑页 | 无卡通 AppBar |
| 物品列表 | 白卡片 + 状态标签 + 位置行 |
| 物品详情 | 白底分组卡片 |
| 个人中心 | 家庭协作排行与动态 |

## 未纳入

- `scan_page` 仍黑色相机 UI（合理）
- `AlertCard` 内部仍部分卡通 Badge（可后续统一 TagChip）
