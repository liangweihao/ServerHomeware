# 设计系统（Design Tokens）

> **UI 开发规范（首选）**：[ui_system.md](ui_system.md) — 组件体系、页面模板、Code Review 检查项。  
> 代码真源：`HomeWareClient/lib/core/constants/`（`app_colors.dart`、`app_radius.dart` 等）。

---

## 一、颜色

### 现行默认（`utilityClean` — 点评橙 + 闲鱼灰白）

| Token | 色值 | 用途 |
|-------|------|------|
| primary | **`#FF6633`** | 链接、筛选、Chip 强调 |
| accentHighlight | **`#FFDA44`** | **仅** FAB、首页「+」 |
| scaffoldBackground | **`#F5F5F5`** | 页面灰底 |
| appBarBackground | **`#FFFFFF`** | 白顶栏 |
| textPrimary/Secondary/Hint | **`#333 / #666 / #999`** | 三级文字 |

### 可选主题

| 变体 | 说明 |
|------|------|
| `communityWarm` | 书旗向居家暖色 |
| `cartoon` | 卡通贴纸皮肤（组件走 `AppColors.isUtilityStyle` 回退） |

### 语义色

| Token | 色值 | 用途 |
|-------|------|------|
| success | `#4CAF50` | 正常 / 充足 |
| warning | `#FF9800` | 偏低 / 即将过期 |
| danger | `#F44336` | 过期 / 删除 |

**分类色**（数据库 `categories.color`）独立于主色，用于 Chip / 标签。

---

## 二、圆角与间距

| Token | 值 | 用途 |
|-------|-----|------|
| AppRadius.sm | 8 | Chip、图标底 |
| AppRadius.md | 12 | **标准卡片** |
| AppRadius.lg | 16 | Sheet |

页面水平边距 **16**；卡片间距 **12**。

---

## 三、通用组件

路径：`presentation/common/widgets/`

| 组件 | 用途 |
|------|------|
| **`AppCard`** | 主题感知白卡片 / 卡通 AppSurface |
| **`AppListRow`** | 设置、功能入口列表行 |
| **`AppSectionHeader`** | 区块标题 |
| **`AppReasonTag`** | 物品出现理由标签 |
| **`AppSegmentChip`** | 分段筛选（统计时间等） |
| `WarmScaffold` | 二级页标准壳 |
| `AppButton` / `AppFab` / `AppTabBar` | 按钮与导航 |
| `AppTag` / `TagChip` | 状态与低饱和标签 |
| `AppEmptyState` | 空列表 |
| `ItemCard` | 物品卡片 |

完整约定见 [ui_system.md](ui_system.md)。

---

## 四、字体

- 列表标题：15px，`w600–w700`
- 辅助信息：12px，`textSecondary`
- 使用 `Theme.of(context).textTheme`

---

## 五、动效

| 场景 | 实现 |
|------|------|
| Tab 切换 | `FadeTransitionPage`（200ms） |
| 二级页 | `SlideTransitionPage`（300ms） |
| 列表入场 | `AppListEntrance` |
| 下拉刷新 | `RefreshIndicator` |

---

## 六、维护

1. 改 Token → `app_colors.dart` + 本文件 + [ui_system.md](ui_system.md)
2. 功能 UI 改动 → `lwh/code_changed/`
