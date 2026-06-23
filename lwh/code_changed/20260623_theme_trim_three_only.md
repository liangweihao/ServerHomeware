# 主题精简：仅保留三种特效主题

## 概述

移除青松绿、创意紫、暖橙活力、翡翠清新四种纯色主题，仅保留玻璃拟态 / 渐变活力 / 新拟态轻质感，并将 **新拟态轻质感** 设为默认主题。

## 改动点

| 项目 | 变更 |
|------|------|
| 可选主题 | 7 种 → 3 种 |
| 默认主题 | 新拟态轻质感（`neumorphism`） |
| 移除色板 | `teal` / `creativePurple` / `warmOrange` / `emeraldFresh` |
| 旧版持久化 | 已删除主题的 storageKey 自动回退至默认 |

## 修改文件

- `app_theme_variant.dart` — 仅 3 个枚举值 + `defaultVariant`
- `app_color_palette.dart` — 删除 4 套纯色板
- `app_colors.dart` — 默认 `_active` 改为 `neumorphism`
- `theme_provider.dart` — 初始/异常回退改为 `defaultVariant`

## 提测要点

1. 全新安装：首屏即为新拟态灰底浮雕风格
2. 主题设置页仅显示 3 个选项
3. 若本地曾保存 `teal` 等旧键，启动后应回退为新拟态
4. 三种主题切换与持久化正常
