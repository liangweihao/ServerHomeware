# UI 风格与 Icon 全局审计

> 日期：2026-07-06  
> 目的：梳理 HomeWareClient 全站 UI 风格真源、图标分层与待替换清单，便于批量统一。  
> 设计真源：[`doc/design/candy-light-design-system.md`](../doc/design/candy-light-design-system.md)

---

## 一、当前状态概览

| 维度 | 目标（糖果轻点） | 现状 |
|------|------------------|------|
| 主题 | 唯一 `vividClean` | ✅ 已唯一化，旧主题自动迁移 |
| 颜色/字体/圆角 | `AppColors` / `AppTypography` / `AppRadius` | ✅ Token 已定稿 |
| 底栏 Tab | 圆润 SVG outline/filled | ✅ 8 个 SVG，无 emoji |
| 页内 Material 图标 | `CandyIcon`（自动 Rounded） | 🟡 约 37 文件已用，**44 文件仍用裸 `Icon(`** |
| 功能入口色块 | `AppIcon.feature` | ✅ 个人中心宫格、部分空态 |
| 动作主入口 | `CandyIconAssets` SVG | ✅ 录入方式、发布弹层（12 个 action SVG） |
| 分类/空间预置 | `PresetIcon` + Registry | ✅ 展示/选择器已换；**DB 仍存 emoji** |
| 区块标题 emoji | 纯文字或小型图标 | ❌ 统计/购物等仍带 emoji 参数 |
| 遗留双分支 | 删除 `isUtilityStyle` 卡通路径 | ❌ **23 文件**仍有分支，卡通分支永不执行 |

**扫描命令参考**（后续增量可复跑）：

```powershell
# 裸 Icon( 文件列表
rg "\bIcon\(" HomeWareClient/lib --glob "*.dart" -l

# CandyIcon 覆盖
rg "CandyIcon\(" HomeWareClient/lib --glob "*.dart" -l

# emoji 文本渲染
rg "TextStyle\(fontSize: (1[6-9]|2[0-9]|3[0-9])" HomeWareClient/lib --glob "*.dart"

# 双分支遗留
rg "isUtilityStyle" HomeWareClient/lib --glob "*.dart" -l
```

---

## 二、设计 Token 速查（替换时必对齐）

### 2.1 颜色

| Token | 值 | 用途 |
|-------|-----|------|
| `background` | `#FAF8F6` | 页面底 |
| `primary` | `#FF6B5A` | 主按钮、选中 |
| `accentCoral/Teal/Sky/Violet/Amber/Rose` | 见 `app_colors.dart` | 宫格、预置 icon 底 |
| `categoryFood/Daily/Medicine/...` | 见 `app_colors.dart` | 分类预置 accent |
| `textPrimary/Secondary/Hint` | 暖灰系 | 文案 |

### 2.2 圆角

`sm=10` / `md=14` / `lg=18` / `xl=24` / `dock=28`

### 2.3 图标尺寸建议

| 场景 | wellSize | iconSize |
|------|----------|----------|
| 列表 leading | 36–40 | 18–20 |
| 宫格/卡片 | 44–48 | 22–24 |
| Chip 内嵌 | 22–28 | 12–14 |
| 详情占位 | 72 | 36 |
| AppBar 操作 | — | 20–22 |

---

## 三、图标分层决策树

```
需要图标？
├─ 底栏 Tab（home/items/alerts/profile）
│   └─ assets/icons/*_{outline|filled}.svg  → cartoon_bottom_nav
├─ 录入/扫描/添加等「主操作 CTA」
│   └─ CandyIconAssets.action/*.svg + AppIcon.feature
├─ 分类 / 空间「预置 icon」（DB 存 emoji）
│   └─ PresetIcon(storageKey, name, accentHex)
│       └─ PresetIconRegistry.resolve()
├─ 个人中心 / 设置「功能宫格」
│   └─ AppIcon.feature(icon: CandyIcons.xxx, accent: ...)
├─ 页内常规操作（返回、删除、chevron、搜索…）
│   └─ CandyIcon(Icons.xxx)  ← 禁止裸 Icon(
└─ 提醒 / 列表「理由标签」
    └─ 应用 iconData + TagChip（去掉 emoji 前缀）← 待统一
```

### 3.1 核心组件路径

| 组件 | 路径 | 职责 |
|------|------|------|
| `CandyIcon` | `lib/core/icons/candy_icon.dart` | 替代 `Icon`，自动 Rounded |
| `CandyIcons` | `lib/core/icons/candy_icons.dart` | 语义常量 + outlined→rounded 映射 |
| `AppIcon` / `.feature` | `lib/core/icons/app_icon.dart` | 饱和圆角底 + 白标 |
| `CandyIconAssets` | `lib/core/icons/candy_icon_assets.dart` | 12 个动作 SVG 路径 |
| `PresetIcon` | `lib/core/icons/preset_icon.dart` | 分类/空间预置渲染 |
| `PresetIconRegistry` | `lib/core/icons/preset_icon_registry.dart` | emoji/名称→IconData+accent |
| `PresetIconPicker*` | `lib/core/icons/preset_icon_picker.dart` | 添加/编辑对话框选择器 |

### 3.2 已有 SVG 资产

```
assets/icons/
  home_{outline,filled}.svg
  items_{outline,filled}.svg
  alerts_{outline,filled}.svg
  profile_{outline,filled}.svg
  action/{scan,add,settings,edit,camera,search,back,filter,download,upload,consume,mic}.svg
```

---

## 四、模块替换清单

图例：**✅ 已完成** · **🟡 部分** · **❌ 待做**

### 4.1 首页 `presentation/home/`

| 文件 | 图标方式 | 状态 | 建议 |
|------|----------|------|------|
| `cartoon_bottom_nav.dart` | SVG | ✅ | — |
| `space_card.dart` | PresetIcon | ✅ | 可删 `_buildCartoonCard` 死代码 |
| `home_space_section.dart` | PresetIcon + CandyIcon | ✅ | `Icons.home_outlined` → `CandyIcons.home` |
| `stat_card.dart` | CandyIcon + 卡通 emoji 分支 | 🟡 | 删卡通分支；`_buildUtilityCard` 已 OK |
| `publish_action_sheet.dart` | SVG + AppIcon | ✅ | — |
| `guanguan_*` | CandyIcon | 🟡 | 部分仍传 `*_outlined` 给 CandyIcon（可换 CandyIcons 常量） |
| `home_item_section.dart` | isUtilityStyle 分支 | ❌ | 删卡通分支 |
| `cartoon_greeting_banner.dart` | 卡通专用 | ❌ | 确认是否仍挂载；未用则归档 |

### 4.2 物品 `presentation/items/`

| 文件 | 图标方式 | 状态 | 建议 |
|------|----------|------|------|
| `item_list_page.dart` | CandyIcon | 🟡 | 空态 icon 仍用 outlined 字面量 |
| `item_detail_page.dart` | CandyIcon + PresetIcon 占位 | 🟡 | `_detailRow` 仍 `Text(emoji)` |
| `item_card.dart` | CandyIcon + AppReasonTag emoji | 🟡 | 标签改纯 TagChip |
| `item_list_section_header.dart` | PresetIcon | ✅ | — |
| `item_form_category_chips.dart` | PresetIcon | ✅ | — |
| `item_placeholder_cover.dart` | PresetIcon | ✅ | — |
| `add_item_method_page.dart` | SVG + CandyIcon | ✅ | — |
| `add_item_wizard_view.dart` 等 | CandyIcon(*_outlined) | 🟡 | 统一改用 `CandyIcons.*` 常量 |

### 4.3 提醒 `presentation/alerts/`

| 文件 | 图标方式 | 状态 | 建议 |
|------|----------|------|------|
| `alert_card.dart` | CandyIcon + emoji 死分支 | 🟡 | 删 `_buildIcon` 卡通分支；`AppReasonTag` 去 emoji |
| `alert_center_page.dart` | CandyIcon | 🟡 | — |

**数据源** `core/utils/alert_display_helper.dart`：已有 `iconData`，但 `icon` 字段仍为 emoji（🔴🟡📦🛒），供 Tag 使用 → **改为仅 iconData**。

### 4.4 认证 /  onboarding `presentation/auth/`、`onboarding/`

| 文件 | 图标方式 | 状态 | 建议 |
|------|----------|------|------|
| `login/register/...` | CandyIcon + `authPageTitle(emoji:)` | 🟡 | 标题去 emoji 或改小图标 |
| `welcome_page.dart` | 大 emoji 特性卡片 | ❌ | 改 `AppIcon.feature` 三宫格 |
| `create_family_page.dart` | 空间类型 `Text(emoji 32)` | ❌ | 改 PresetIcon（🏠/🏪） |
| `room_select_step.dart` | Icon + emoji 房间 | ❌ | PresetIcon 网格 |
| `first_item_step.dart` | 裸 Icon | ❌ | CandyIcon |

### 4.5 位置 `presentation/locations/`

| 文件 | 状态 | 备注 |
|------|------|------|
| `location_card.dart` | ✅ PresetIcon | 删卡通分支；删除按钮改 CandyIcon |
| `add_location_dialog.dart` | ✅ PresetIconPicker | 照片按钮仍裸 Icon |
| `location_picker.dart` | ✅ | — |
| `location_detail_page.dart` | ❌ | edit/add/delete 裸 Icon |
| `location_overview_page.dart` | ✅ | 经 LocationCard 间接 |

### 4.6 个人中心 `presentation/profile/`

| 文件 | 状态 | 建议 |
|------|------|------|
| `profile_quick_action_grid.dart` | ✅ AppIcon.feature | — |
| `profile_quick_actions_config.dart` | ✅ CandyIcons | — |
| `category_management_page.dart` | ✅ PresetIcon | — |
| `profile_page.dart` / `profile_panel_page.dart` | ❌ | 大量裸 Icon |
| `family_management_page.dart` | 🟡 | leadingEmoji 首字母 → 头像圈 |
| `switch_family_bottom_sheet.dart` | ❌ | 空间 emoji `TextStyle 20` |
| `member_contribution_*` | ❌ | `Icons.emoji_events_outlined` 等 |
| `notification_settings_page.dart` | ❌ | 裸 Icon |
| `edit_profile_page.dart` | ❌ | 裸 Icon |

### 4.7 购物 / 搜索 / 统计 / 其他

| 模块 | 文件 | 状态 | 典型问题 |
|------|------|------|----------|
| 购物 | `shopping_list_page.dart` | ❌ | Tab emoji（📝✅📜）；裸 Icon |
| 购物 | `shopping_item_card.dart` | 🟡 | isUtilityStyle 双分支 |
| 搜索 | `search_page.dart` | ❌ | 裸 Icon search/clear |
| 搜索 | `item_*_link_banner.dart` | ❌ | `*_outlined` 裸 Icon |
| 统计 | `statistics_page.dart` | 🟡 | PresetIcon 分类 ✅；SectionHeader 仍 emoji |
| 盘点 | `inventory_task_page.dart` | 🟡 | PresetIcon ✅；chevron 裸 Icon |
| 通知 | `notification_center_page.dart` | 🟡 | iconData 已有，部分裸 Icon |
| 助手 | `assistant_chat_page.dart` | ❌ | send/edit 裸 Icon |
| 通用 | `app_list_row.dart` | 🟡 | leadingEmoji → AppIcon 或首字母 Avatar |
| 通用 | `app_section_header.dart` | ❌ | emoji 拼接标题 |
| 通用 | `app_tab_bar.dart` | ❌ | 转发 CartoonTabBar + emoji |
| 通用 | `app_empty_state.dart` | 🟡 | 工具/卡通双分支 |
| 通用 | `app_reason_tag.dart` | ❌ | 卡通分支 Text(emoji) |
| 通用 | `quantity_stepper.dart` | ❌ | 裸 Icon |
| 通用 | `add_method_sheet.dart` | ❌ | 裸 Icon |

---

## 五、Emoji 使用分类（全站）

| 类别 | 存储/来源 | 渲染方式 | 目标组件 | 状态 |
|------|-----------|----------|----------|------|
| A. 分类 icon | Drift `categories.icon` | ~~Text~~ → PresetIcon | PresetIcon | ✅ |
| B. 空间 icon | Drift `locations.icon` | ~~Text~~ → PresetIcon | PresetIcon | ✅ |
| C. 提醒类型 | `alert_display_helper.icon` | Text / Tag 前缀 | CandyIcon + TagChip | ❌ |
| D. 列表理由 | `item_list_reason_helper.emoji` | AppReasonTag | TagChip 纯文字 | ❌ |
| E. 区块标题 | 硬编码参数 | AppSectionHeader / CartoonSectionTitle | 纯文字 | ❌ |
| F. Auth 标题 | `authPageTitle(emoji:)` | 字符串拼接 | 纯文字或小 AppIcon | ❌ |
| G. Tab 标签 | `AppTabItem.emoji` | CartoonTabBar Text | 纯文字或 SVG | ❌ |
| H. 首页统计 | `CartoonPalette.emojiFor` | stat_card 卡通分支 | 已死代码 | 删 |
| I. 欢迎页特性 | welcome_page 硬编码 | 大 emoji | AppIcon.feature ×3 | ❌ |
| J. 创建家庭 | SpaceSkinConfig.spaceEmoji | Text 32 | PresetIcon | ❌ |
| K. 切换家庭 | switch_family_bottom_sheet | Text emoji | PresetIcon | ❌ |
| L. 成员首字母 | leadingEmoji | Text 单字 | CircleAvatar | 保留（非 emoji） |

**DB 层**：A/B 类 **不改 schema**，继续存 emoji 字符串；仅渲染层映射（`PresetIconRegistry`）。

---

## 六、遗留代码清理（与图标统一同步）

以下文件含 `AppColors.isUtilityStyle` 分支 — **恒为 true**，卡通分支为死代码，建议整段删除并简化 widget：

```
item_form_category_chips.dart    category_management_page.dart
location_card.dart               space_card.dart
add_item_wizard_view.dart        alert_card.dart
item_card.dart                     stat_card.dart
app_list_row.dart                  app_segment_chip.dart
app_reason_tag.dart                app_card.dart
profile_overview_strip.dart        profile_identity_header.dart
family_management_page.dart        auth_cartoon_wrap.dart
edit_profile_page.dart             app_section_header.dart
notification_center_page.dart      app_list_entrance.dart
app_tab_bar.dart                   app_fab.dart
app_empty_state.dart               home_item_section.dart
shopping_item_card.dart
```

**卡通专用组件**（`presentation/common/widgets/cartoon_*.dart` + `core/theme/cartoon_palette.dart`）：确认无引用后移入 `archive/` 或删除。

---

## 七、推荐替换批次

### P0 — 用户高频可见（1–2 天）

1. `create_family_page` / `welcome_page` — 空间类型、特性介绍
2. `switch_family_bottom_sheet` — 家庭/空间列表 icon
3. `shopping_list_page` — Tab emoji
4. `alert_display_helper` + `app_reason_tag` + `alert_card` — 提醒去 emoji
5. `item_card` + `item_list_reason_helper` — 列表理由 Tag

### P1 — 次级页面裸 Icon → CandyIcon（1 天）

批量替换以下目录中的 `Icon(` → `CandyIcon(`，并优先使用 `CandyIcons.*` 常量：

- `profile/`（除已完成的宫格）
- `search/`
- `shopping/widgets/`
- `locations/location_detail_page.dart`
- `assistant/`
- `common/widgets/{quantity_stepper,add_method_sheet,app_search_bar}.dart`

### P2 — 结构清理（0.5 天）

1. 删除全部 `isUtilityStyle` 双分支与 `_buildCartoon*` 方法
2. `AppSectionHeader` / `AppTabBar` 去 emoji 参数
3. `auth_cartoon_wrap.dart` 简化为纯文字标题

### P3 — 可选增强

1. 扩展 `PresetIconRegistry`（ onboarding 房间、SpaceSkin emoji）
2. 新增 `AlertIcon` widget（封装 alert_display_helper.iconData）
3. 扩展 action SVG（share、delete、chevron 等高频操作）
4. lint 规则：禁止 `Icon(` 直接出现在 `presentation/`（允许 `core/icons/`）

---

## 八、替换操作模板

### 8.1 裸 Icon → CandyIcon

```dart
// Before
const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint)

// After
const CandyIcon(CandyIcons.chevronRight, size: 18, color: AppColors.textHint)
```

### 8.2 emoji 预置 → PresetIcon

```dart
// Before
Text(location.icon ?? '📦', style: TextStyle(fontSize: 24))

// After
PresetIcon(
  storageKey: location.icon,
  name: location.name,
  wellSize: 48,
  iconSize: 24,
)
```

### 8.3 提醒 Tag 去 emoji

```dart
// Before
AppReasonTag.plain(label: info.title, color: info.color, emoji: info.icon)

// After
AppReasonTag.plain(label: info.title, color: info.color) // TagChip only
// 左侧已有 CandyIcon(info.iconData)
```

### 8.4 区块标题去 emoji

```dart
// Before
AppSectionHeader(title: '分类占比', emoji: '📊')

// After
AppSectionHeader(title: '分类占比')
// 或需要图标时：Row([AppIcon.feature(icon: CandyIcons.barChart, accent: ...), Text(...)])
```

---

## 九、与设计文档关系

| 文档 | 内容 |
|------|------|
| [`doc/design/candy-light-design-system.md`](../doc/design/candy-light-design-system.md) | Token、控件、图标规范（定稿） |
| 本文 | **可执行的文件级清单与批次** |
| [`lwh/code_changed/20260706_candy_light_theme_icons_unify.md`](code_changed/20260706_candy_light_theme_icons_unify.md) | 已落地变更记录 |

**维护约定**：每完成一批替换，更新本文对应模块状态，并在 `lwh/code_changed/` 追加记录。

---

## 十、统计摘要（2026-07-06 扫描）

| 指标 | 数量 |
|------|------|
| 使用裸 `Icon(` 的文件 | **44** |
| 已使用 `CandyIcon(` 的文件 | **37** |
| 已使用 `PresetIcon(` 的文件 | **14** |
| 含 `isUtilityStyle` 死分支 | **23** |
| 卡通专用 widget 文件 | **~15** |
| SVG 资产（底栏+动作） | **20** |
| PresetIconRegistry emoji 映射 | **~70** |
