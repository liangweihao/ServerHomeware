# 玻璃拟态 & 渐变活力主题扩展

## 概述

在原有 4 套纯色主题基础上，新增 **玻璃拟态** 与 **渐变活力** 两套视觉风格主题，支持渐变页面背景、半透明卡片与毛玻璃模糊效果。

## 实现方案

### 新增视觉风格层

```
AppVisualStyle (standard / glassmorphism / gradientBold)
    └── AppColorPalette (+ gradientColors, visualStyle)
            └── AppThemeExtension (ThemeData 扩展)
                    └── AppThemeBackground (全局渐变底)
                    └── AppSurface / AppDecorations (卡片质感)
```

### 新增文件

| 文件 | 说明 |
|------|------|
| `app_visual_style.dart` | 视觉风格枚举 |
| `app_theme_extension.dart` | Material ThemeExtension |
| `app_decorations.dart` | 表面装饰 + AppSurface 毛玻璃组件 |
| `app_theme_background.dart` | 全局渐变背景包裹层 |

### 主题色值

| 主题 | 渐变 | 特点 |
|------|------|------|
| 玻璃拟态 | `#667EEA` → `#764BA2` | 紫蓝渐变底 + 22% 白半透明 + BackdropFilter 模糊 |
| 渐变活力 | `#7C4DFF` → `#FF5722` | 紫橙渐变底 + 93% 白卡片 + 粉色强调 |

### 关键行为

- **全局渐变**：`MaterialApp.builder` 包裹 `AppThemeBackground`
- **透明 Scaffold**：特殊主题下 `scaffoldBackground` 为透明，露出渐变层
- **AppBar / 底栏**：透明或半透明，标题与选中项使用白色前景
- **卡片**：`AppSurface` 在玻璃主题下自动叠加 `BackdropFilter`
- **持久化键**：`glassmorphism` / `gradient_bold`

### 修改范围

- `app_color_palette.dart` / `app_theme_variant.dart` — 新增 2 个变体
- `app_colors.dart` — 新增 `scaffoldBackground`、`appBarBackground`、`visualStyle` 等
- `app_theme.dart` — 按变体构建 ThemeData + Extension
- `main.dart` — 渐变背景包裹
- 各主要页面 — `scaffoldBackground` / `appBarBackground` 替换硬编码背景
- `stat_card.dart` / `profile_page.dart` — 使用 `AppSurface`
- `theme_settings_page.dart` — 渐变预览色带 +「特效」标签

## 提测要点

1. 主题设置页可见 6 种主题，玻璃/渐变显示渐变色带预览与「特效」角标
2. 切换玻璃拟态：全页紫蓝渐变、卡片磨砂半透明、AppBar 白字、底栏半透明
3. 切换渐变活力：紫橙渐变、卡片近白高不透明、粉色 FAB/选中色
4. 切换回青松绿等标准主题：恢复纯色背景与白卡片
5. 重启 App 后玻璃/渐变选择仍保留
6. 首页统计卡片、我的页面列表在特殊主题下质感正常

## 已知限制

- 部分子页面列表项仍使用 `AppColors.card` 纯色，未全部改为 `AppSurface`（玻璃模糊仅在有 BackdropFilter 的组件上生效）
- 登录/注册等 Auth 流程页面已适配透明 Scaffold，但输入框区域为半透明白底
