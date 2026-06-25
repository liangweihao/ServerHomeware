# 卡通主题独占 + 列表内容级卡通化

## 技术开发文档

### 目标

1. 移除玻璃拟态 / 渐变活力 / 新拟态等多主题代码，**仅保留卡通轻插画**
2. 强化列表项**内部内容**的卡通感（标题、标签、图标、数量徽章等），解决「背景卡通、内容偏普通」的问题

### 主题层改动

| 文件 | 改动 |
|------|------|
| `app_theme_variant.dart` | 仅保留 `cartoon`，默认变体改为卡通 |
| `app_color_palette.dart` | 删除 glass / gradient / neumorphism 色板 |
| `app_visual_style.dart` | 枚举仅保留 `cartoon` |
| `app_colors.dart` | 简化 getter，固定卡通背景/卡片色 |
| `app_decorations.dart` | `AppSurface` 始终贴纸风格，移除毛玻璃分支 |
| `app_theme.dart` | 始终 Nunito + 卡通圆角输入/对话框 |
| `app_theme_background.dart` | 始终点阵 + 云朵背景 |
| `theme_provider.dart` | 旧主题键自动回退 cartoon（via fromStorage） |

### 删除文件

- `glass_floating_bottom_nav.dart`
- `theme_settings_page.dart`

### 路由 / 入口

- 移除 `/profile/theme-settings` 路由
- 个人中心移除「主题样式」菜单项
- `main_scaffold.dart` 固定使用 `CartoonBottomNav`

### 列表内容级卡通化（核心）

新增 `CartoonStickerBadge`（`cartoon_ui.dart`）— 贴纸描边 + 硬阴影小标签，供列表内复用。

| 组件 | 内容级增强 |
|------|-----------|
| `item_card.dart` | 标题 w800；📍 位置；📦 占位缩略图；数量/分类/过期/状态均用 `CartoonStickerBadge`；缩略图贴纸边框 |
| `alert_card.dart` | emoji 贴纸 icon 框；提醒类型贴纸标签；描述 w600 |
| `shopping_item_card.dart` | 圆形勾选贴纸阴影；数量/自动标签用 `CartoonStickerBadge` |
| `location_card.dart` | 数量「📦 N 件」贴纸标签 |
| `space_card.dart` | 同上数量标签 |
| `activity_item.dart` | 始终贴纸 emoji + w800 文案 |

### 分支清理

移除全库 `isCartoon` / `CartoonUi.isActive` 双路径，约 40+ 处 widget 与页面只保留卡通实现。

### 影响范围

- 已安装旧主题（glass/neumorphism 等）的用户启动后自动回退卡通
- 无法再切换主题（设置页已移除）
- 所有 Tab 页、列表、卡片视觉统一为卡通贴纸风格

## 提测开发文档

### 测试点

1. **启动**：无编译错误，首屏为卡通点阵背景 + 卡通底栏
2. **物品列表**：每项标题加粗、数量贴纸标签、分类/过期状态有描边阴影；无图时 📦 占位
3. **提醒中心**：卡片内 emoji 图标框 + 类型贴纸标签
4. **购物清单**：勾选圈、数量/自动标签卡通化
5. **首页**：统计卡倾斜 + emoji；空间卡数量标签；动态列表 emoji 行
6. **个人中心**：无「主题样式」入口；设置项 emoji 贴纸 leading
7. **搜索 / 物品列表搜索框**：贴纸外框 + 🔍 hint
8. **旧用户**：曾选 glass/neumorphism 的主题应自动变为卡通

### 验证方式

```powershell
cd HomeWareClient
flutter analyze
flutter run
```

### 注意事项

- Kotlin 插件迁移提示与本次改动无关
- 若需恢复多主题，需从 git 历史恢复已删文件与 enum 值
