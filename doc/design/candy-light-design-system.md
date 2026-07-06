# 糖果轻点（Candy Light）设计系统

> 状态：2026-07-06 定稿 — **唯一官方主题**  
> 适用：HomeWareClient 全端

---

## 一、设计定位

| 维度 | 说明 |
|------|------|
| **关键词** | 温暖、圆润、干净、轻量、家庭友好 |
| **参考气质** | 糖果色点缀 + 日系居家 App，避免点评/闲鱼「工具灰」感 |
| **反面** | 纯黑字、直角图标、emoji 底栏、多主题切换 |

---

## 二、色彩调研结论

### 2.1 背景与表面

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | `#FAF8F6` | 页面暖灰白，比 `#FFF` 更柔和 |
| `card` | `#FFFFFF` | 卡片 / Dock |
| `gray100` | `#F5F1EC` | 输入框、弱底 |
| `homeDivider` | `#F0EBE6` | 分割线 |

**调研说明**：冷灰 `#FAFAFA` 在小屏上显「工具感」；略暖 `#FAF8F6` 与珊瑚主色更协调，长时间浏览不刺眼。

### 2.2 主色

| Token | 色值 | 用途 |
|-------|------|------|
| `primary` | `#FF6B5A` | 主按钮、选中 Tab、关键强调 |
| `primaryDark` | `#E85A4A` | 按下态 |
| `primaryLight` | `#FFB4AA` | 描边、弱强调 |
| `primaryLighter` | `#FFF0ED` | 选中 Pill、Banner 底 |

**对比度**：主色上白字约 4.6:1，满足 WCAG AA（大文本/按钮）。

### 2.3 功能点缀色（宫格 / 标签）

| 名称 | 色值 | 典型场景 |
|------|------|----------|
| 珊瑚 | `#FF6B5A` | 物品 |
| 青绿 | `#2BB8A3` | 协作 |
| 天蓝 | `#4A9FE8` | 统计 / 通知 / 低库存 |
| 紫藤 | `#8B7FD4` | 盘点 |
| 蜜糖 | `#F5A623` | 购物 / FAB 辅助 |
| 玫瑰 | `#E85D8A` | 活动 / 营销 |

**规则**：图标容器 = **饱和色圆角底 + 白色图标**（`AppColors.iconWellFor`）。

### 2.4 文字

| Token | 色值 | 字号建议 |
|-------|------|----------|
| `textPrimary` | `#3D3A36` | 16–17 标题，14 正文 |
| `textSecondary` | `#6B6560` | 12–13 辅助 |
| `textHint` | `#9E9890` | 11 占位 / 未选中 Tab |

避免 `#000` 与 `#999` 纯灰，改用暖灰系。

---

## 三、字体

| 层级 | 字号 | 字重 | 用途 |
|------|------|------|------|
| displayMedium | 28 | 800 | 数据大数 |
| headlineLarge | 22 | 800 | 区块标题 |
| titleLarge | 17 | 700 | AppBar |
| bodyLarge | 16 | 500 | 列表主文案 |
| bodyMedium | 14 | 500 | 次要正文 |
| labelSmall | 11 | 600 | Tab / Chip |

**字体族**：Google Fonts **Nunito**（圆体，全 App 统一）。

---

## 四、圆角

| Token | 值 | 用途 |
|-------|-----|------|
| sm | 10 | 小图标底 |
| md | 14 | 输入框、宫格 |
| lg | 18 | 卡片 |
| xl | 24 | 按钮、Dialog |
| dock | 28 | 底栏 Dock |

---

## 五、图标规范

### 5.1 底栏 Tab（SVG）

路径：`assets/icons/*_{outline|filled}.svg`

- 线宽 2px，`round` 线帽/连接
- 未选中：outline + `textHint`
- 选中：filled + `primary`
- **禁止** 选中态使用 emoji

### 5.2 页内图标

- 使用 `CandyIcon` 替代 `Icon`（自动映射 Rounded 变体）
- 功能入口使用 `AppIcon.feature(accent: ...)`
- 录入/快捷操作用 `assets/icons/action/*.svg`（见 `CandyIconAssets`）

**已批量替换模块**：首页 `home/`、物品 `items/`、提醒 `alerts/`、认证 `auth/`

**动作 SVG 清单**：scan / add / settings / edit / camera / search / back / filter / download / upload / consume / mic

### 5.3 分类 / 空间预置图标

- DB 仍存 **emoji 字符串**（`categories.icon`、`locations.icon`），保证兼容
- 渲染统一用 `PresetIcon(storageKey:, name:, accentHex:)`
- 映射表：`PresetIconRegistry`（emoji + 中文名称 → Rounded IconData + accent）
- 选择器：`PresetIconPickerGrid` / `PresetIconPickerWrap`
- **禁止** 在 UI 层 `Text(category.icon)` 直接渲染 emoji

### 5.4 全局审计与替换清单

详见 [`lwh/ui_icon_style_audit.md`](../../lwh/ui_icon_style_audit.md) — 含模块级状态、emoji 分类、P0–P3 批次与操作模板。

---

## 六、控件

| 控件 | 规范 |
|------|------|
| 按钮 | 主色填充 / 24px 圆角 / 无硬描边 |
| 卡片 | 白底 + 轻阴影，无粗描边 |
| 输入框 | gray100 填充 + md 圆角 |
| FAB | 蜜糖黄 `#FFD166` + 深棕字 |
| 底栏 | 浮动 Dock + 主色浅 Pill |

---

## 七、代码入口

| 模块 | 路径 |
|------|------|
| 颜色 | `lib/core/constants/app_colors.dart` |
| 字体 | `lib/core/constants/app_typography.dart` |
| 圆角 | `lib/core/constants/app_radius.dart` |
| 主题 | `lib/core/theme/app_theme.dart` |
| 图标 | `lib/core/icons/candy_icons.dart`, `app_icon.dart` |
| 预览 | `/profile/theme-settings` → 视觉规范页 |

---

## 八、后续迭代

1. 批量将页内 `Icons.outlined` 替换为 `CandyIcons.rounded()`
2. 补充常用动作 SVG（扫码、添加、设置）至 `assets/icons/action/`
3. 空状态插画色调与主色对齐
4. 真机无障碍走查（Dynamic Type、对比度）
