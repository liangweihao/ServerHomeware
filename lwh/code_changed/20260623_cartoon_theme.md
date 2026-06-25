# 卡通轻插画主题

## 概述

新增第 4 套主题 **卡通轻插画**，暖米白背景 + 珊瑚主色 + 大圆角描边卡片，可在「我的 → 主题样式」切换预览。

## 视觉 Token

| Token | 值 | 说明 |
|-------|-----|------|
| 背景 | `#FFF8F0` | 暖米白 |
| 主色 | `#FF8A65` | 柔和珊瑚 |
| 卡片 | 白底 + 2.5px `#FFCCBC` 描边 | 贴纸感 |
| 圆角 | 20px | 大于默认 16px |
| 装饰 | 背景彩色圆 blob | 薄荷 / 淡黄 |

## 实现要点

### 新增

- `AppVisualStyle.cartoon`
- `AppColorPalettes.cartoon` / `AppThemeVariant.cartoon`
- `cartoon_bottom_nav.dart` — 滑动色块 + SVG 图标 + 标签
- 背景装饰气泡（`app_theme_background.dart`）

### 修改

- `app_decorations.dart` — 卡通 surface 描边 + 硬阴影
- `app_theme.dart` — 大圆角输入框 / FAB / 卡片
- `stat_card.dart` — 卡通布局：圆角图标底，无左侧色条
- `main_scaffold.dart` — 卡通主题接入专用底栏

## 提测

1. 主题设置页出现「卡通轻插画」选项
2. 切换后：暖色背景 + 气泡装饰 + 描边卡片
3. 首页统计卡片为圆角图标样式
4. 底栏：白底 + 珊瑚滑动色块 + SVG 图标
5. 与其他三主题切换互不影响、可持久化

## 后续可增强

- 空状态插画 SVG
- 全局 rounded 字体
- 更多页面卡片走 `AppSurface`
