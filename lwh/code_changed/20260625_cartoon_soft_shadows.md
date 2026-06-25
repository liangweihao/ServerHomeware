# 卡通主题柔和阴影改造

## 背景

用户反馈「背景/卡片阴影不自然」，经排查确认是代码设计问题，而非设备渲染差异。

## 根因分析

1. **硬偏移阴影**：原 `stickerShadows()` 使用 `blurRadius: 0` + `Offset(4, 4)`，产生「色块复制」效果，不像真实投影。
2. **主题色染色**：阴影颜色取边框/主题色 55% 透明度，卡片越多颜色越「脏」。
3. **嵌套叠影**：外层 `AppSurface` + 内层 `CartoonInnerPanel` + 缩略图框 + Badge 多层各自带阴影，视觉发糊、发脏。

## 实现方案

### 1. 阴影分级 `CartoonShadowLevel`

| 层级 | 用途 | 参数概要 |
|------|------|----------|
| `none` | 内层面板、Chip、缩略图框 | 无阴影 |
| `subtle` | 小按钮、标签 | blur 4, offset (0,2) |
| `card` | 标准列表卡片 | 双层暖色中性影 blur 12+3 |
| `floating` | 底栏、FAB | blur 20+6, offset (0,8) |

投影基色：`#5D4037` 暖棕，低透明度，不再用主题色染色。

### 2. 核心文件改动

- `cartoon_decorations.dart` — 新增 `shadows()` / `CartoonShadowLevel`，`stickerShadows()` 兼容映射
- `app_decorations.dart` — `AppSurface` 用 `shadowLevel` 替代 `shadowColor`
- `cartoon_ui.dart` — `CartoonInnerPanel` 无阴影；Badge compact 无阴影
- `cartoon_bottom_nav.dart` — 外层 `floating`，Tab 指示块无内层硬阴影
- `cartoon_fab.dart` — `floating` 级阴影
- 列表卡片内层元素 — 去掉 `blurRadius: 0` 硬阴影

### 3. 编码事故修复（连带）

PowerShell 批量删阴影时破坏 UTF-8，导致部分 widget 无法被 analyzer 解析（表现为 `uri_does_not_exist`）。已重写：

- `cartoon_chip.dart`
- `cartoon_tab_bar.dart`
- `cartoon_section_title.dart`
- `shopping_item_card.dart`
- `item_list_page.dart` / `search_page.dart` 截断字符串

## 影响范围

- 全局卡通卡片、底栏、FAB 阴影视觉
- 列表/首页卡片嵌套层次更干净
- 无 API / 路由 / 业务逻辑变更

## 提测验证

1. **首页**：统计卡片、空间卡片、活动项 — 阴影应柔和、无彩色硬边
2. **物品列表**：ItemCard 外层有轻阴影，内层白底 panel 无阴影
3. **底栏 / FAB**：浮动层阴影略强但仍自然（有 blur）
4. **购物清单 / 提醒中心**：Tab 栏与卡片阴影一致
5. **对比**：不应再出现「卡片旁边一块同色色块」的感觉

### 2026-06-25 补充：ItemCard emoji 乱码修复

- **问题**：物品卡片标签前显示 `??` / `???`，应为 emoji 前缀
- **原因**：批量改阴影时 PowerShell 破坏 UTF-8，emoji 变成 `?`
- **修复**：`item_card.dart` 恢复 🏷️分类 / 🏪品牌 / 📍位置 / 📦数量 及过期状态 emoji


- **问题**：首页统计 Grid `childAspectRatio: 1.38` 单元格偏矮，StatCard Column 溢出约 1.6px
- **修复**：StatCard 内层 `LayoutBuilder` + `FittedBox(scaleDown)`；略收紧 padding/emoji 尺寸；Grid 比例改为 `1.28`
