# 主题切换：书旗暖棕 → 点评+闲鱼工具风

> 日期：2026-07-01  
> 背景：书旗向米白暖棕偏「阅读/内容」，不适合 HomeStock 工具型管家

---

## 新默认主题 `utilityClean`（清爽工具）

| Token | 值 | 借鉴 |
|-------|-----|------|
| 页面底 | `#F5F5F5` | 点评/闲鱼列表灰底 |
| 顶栏 | `#FFFFFF` | 闲鱼白顶栏 |
| 主色 | `#FF6633` | 点评列表橙（筛选/链接/Chip） |
| 强调 | `#FFDA44` | 闲鱼黄 — 首页「+」、FAB |
| 文字 | `#333 / #666 / #999` | 中性灰，非书旗暖棕 |
| 分区 | 白底 + 灰底间隔 | 点评 Feed 区块 |
| 字体 | Noto Sans SC | 工具向，非 Nunito 圆体 |

## 保留可选

- `communityWarm` — 书旗向居家暖色（设置中可选）
- `cartoon` — 卡通插画

## 自动迁移

本地若缓存 `cartoon` 或 `community_warm`，启动时一次性迁移为 `utility_clean`。

## 改动文件

- `app_color_palette.dart` / `app_theme_variant.dart` / `app_visual_style.dart`
- `app_colors.dart` / `app_theme.dart` / `theme_provider.dart`
- `app_theme_background.dart`
- `home_top_bar.dart`（灰搜索胶囊 + 闲鱼黄「+」）
- `home_item_section.dart` / 卡片阴影 Token

## 提测

| 场景 | 预期 |
|------|------|
| 冷启动 | 灰底 + 白顶栏 + 橙 Chip/链接 |
| 首页「+」 | 闲鱼黄圆钮，深色加号 |
| 搜索框 | 灰色胶囊，无暖棕描边 |
| 旧用户 | 自动切到新主题 |
