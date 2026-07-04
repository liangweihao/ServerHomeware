# 卡通主题子页面 UI 迁移

## 概述

将购物、统计、搜索、位置、通知、个人资料、物品、Auth、引导等子页面迁移为在 `AppVisualStyle.cartoon` 激活时使用统一卡通 UI 组件，标准/玻璃/渐变主题保持原有表现。

## 实现方案

### 复用组件

| 组件 | 用途 |
|------|------|
| `CartoonScaffold` | 标准页 Scaffold + AppBar（titleEmoji / actions / bottom / FAB） |
| `CartoonTabBar` + `CartoonTabItem` | 贴纸 Tab 栏 |
| `CartoonFloatingActionButton` | 卡通 FAB |
| `CartoonListEntrance` | 列表项错开入场 |
| `CartoonSectionCard` | 统计/详情区块卡片 |
| `CartoonChip` | 时间范围筛选 |
| `CartoonListTile` | 通知/成员列表行 |
| `CartoonAppBarIcon` | AppBar 图标按钮 |
| `AppEmptyState` + `cartoonKind` | 卡通空状态插画 |
| `AppSurface` / `wrapAuthFormSurface` | Auth 表单贴纸卡片 |
| `CartoonUi.pageTitle` | 带 emoji 标题 |

### 新增辅助

- `lib/presentation/auth/widgets/auth_cartoon_wrap.dart` — Auth 表单 `AppSurface` 包裹（仅 cartoon 生效）

## 改动文件

1. `shopping/shopping_list_page.dart` — 🛒 CartoonScaffold、Tab、FAB、ListEntrance、cartoonIndex
2. `statistics/statistics_page.dart` — 📊 CartoonScaffold、CartoonChip 时间筛选、CartoonSectionCard 各区块
3. `search/search_page.dart` — 贴纸搜索框、ListEntrance、search cartoonKind
4. `locations/location_overview_page.dart` — 🏠 CartoonScaffold、ListEntrance、family 空状态
5. `locations/location_detail_page.dart` — CartoonScaffold、FAB、ListEntrance
6. `notifications/notification_center_page.dart` — 🔔 CartoonScaffold、CartoonListTile
7. `profile/category_management_page.dart` — 🏷️ CartoonScaffold、FAB、AppSurface 分类项
8. `profile/family_management_page.dart` — CartoonScaffold、FAB、CartoonListTile
9. `profile/edit_profile_page.dart` — ✏️ CartoonScaffold、AppSurface 表单区
10. `profile/notification_settings_page.dart` — ⚙️ CartoonScaffold
11. `profile/profile_panel_page.dart` — 👤 CartoonScaffold
12. `items/usage_records_page.dart` — CartoonScaffold、ListEntrance
13. `items/scan_page.dart` — 📷 pageTitle 标题
14. `items/add_item_page.dart` / `edit_item_page.dart` — CartoonScaffold
15. `items/item_detail_page.dart` — 动态标题 CartoonScaffold、CartoonSectionCard 主区块
16. Auth 8 页 + `auth_cartoon_wrap.dart` — scaffoldBackground、wrapAuthFormSurface、pageTitle
17. `onboarding/onboarding_page.dart` — 卡通主题页码指示器描边

## 提测要点

1. 切换「卡通贴纸」主题：上述页面 AppBar 带 emoji、Tab/FAB/列表/卡片为贴纸风格
2. 切换回青松绿等标准主题：布局与交互与迁移前一致
3. 购物清单三 Tab、统计时间 Chip、搜索框贴纸、位置网格入场动画正常
4. 通知中心 ListTile、家庭成员 ListTile、Auth 表单 AppSurface 仅在 cartoon 下可见
5. 物品详情动态标题与三块 SectionCard（状态/详情/使用记录）在 cartoon 下正常
6. 扫码页相机 UI 不受影响，仅标题 emoji 变化

## 注意事项

- 浪费统计区块：非 cartoon 仍保留 `dangerLight` 底色；cartoon 使用 `CartoonSectionCard`
- 扫码页因全屏相机，未使用 CartoonScaffold，仅 `CartoonUi.pageTitle` 处理标题
