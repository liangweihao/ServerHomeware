# 新拟态轻质感主题

## 概述

在主题设置中新增第 7 种主题 **新拟态轻质感**，采用同色系灰白背景 + 双阴影浮雕卡片，触感温润、低对比。

## 实现方案

### 色板

| Token | 值 | 说明 |
|-------|-----|------|
| background | `#E8ECF0` | 页面与卡片同色基底 |
| primary | `#3A9B8A` | 青松绿强调（选中/图标） |
| 高光阴影 | `#FFFFFF` | 左上外凸亮部 |
| 暗部阴影 | `#C5CCD6` | 右下外凸暗部 |

### 视觉逻辑

- **与渐变主题区分**：新增 `AppVisualStyle.neumorphism` 及 `usesGradientBackground` 扩展判断
- **Scaffold**：使用实色 `#E8ECF0`，非透明
- **AppBar / 底栏**：与背景同色，深色文字
- **卡片**：`AppSurface` / `AppDecorations.surface` 应用双阴影浮雕
- **持久化键**：`neumorphism`

### 修改文件

| 文件 | 改动 |
|------|------|
| `app_visual_style.dart` | 新增 `neumorphism` 枚举与扩展方法 |
| `app_color_palette.dart` | 新增 `AppColorPalettes.neumorphism` |
| `app_theme_variant.dart` | 新增主题变体 |
| `app_decorations.dart` | 新增 `neumorphicRaisedShadows` / `neumorphicInsetShadows` |
| `app_colors.dart` | 区分渐变与新拟态的背景/前景逻辑 |
| `app_theme.dart` | 新拟态专用 AppBar、底栏、分割线、输入框 |
| `theme_settings_page.dart` | 浮雕预览块 +「特效」标签 |

## 提测要点

1. 主题设置页可见「新拟态轻质感」，预览为灰底浮雕方块
2. 切换后：全页 `#E8ECF0` 灰底，统计卡片/我的页面列表呈浮雕凸起
3. AppBar、底栏与背景融为一体，文字为深色可读
4. 选中 Tab、图标强调色为青松绿 `#3A9B8A`
5. 与玻璃/渐变主题切换互不影响，重启后选择保留
6. 回归：切换回青松绿等标准主题，恢复白卡片扁平样式

## 已知限制

- 输入框仅使用同色填充，未实现内凹 `inset` 阴影（后续可增强）
- 部分列表项仍用 `AppColors.card` 纯色，未全部走 `AppSurface` 浮雕
