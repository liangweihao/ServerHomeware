# 设计系统（Design Tokens）

> 代码真源：`HomeWareClient/lib/core/constants/`（`app_colors.dart`、`app_radius.dart` 等）。  
> **视觉刷新**：见 [visual-refresh.md](visual-refresh.md)（主色拟换为柔和 Teal，代码待落地）。  
> 完整 Figma 组件规格已归档至 [`archive/figma-design-system-full.md`](../archive/figma-design-system-full.md)。

---

## 一、颜色

### 现行（代码中，青松 Teal）

| Token | 色值 | 用途 |
|-------|------|------|
| primary | **`#3A9B8A`** | 主按钮、选中态、链接 |
| primaryDark | **`#2D7F71`** | 按下态 |
| primaryLight | **`#A8D5CC`** | 浅底 |
| primaryLighter | **`#E8F5F2`** | 弱强调背景 |
| info / infoLight | 同 primary 系 | 与主色统一 |

### 历史（Material 蓝，已废弃）

| Token | 旧值 |
|-------|------|
| primary | `#2196F3` |

### 语义色（不变）

| Token | 色值 | 用途 |
|-------|------|------|
| success | `#4CAF50` | 正常 / 充足 |
| warning | `#FF9800` | 偏低 / 即将过期 |
| danger | `#F44336` | 过期 / 删除 |
| background | `#FAFAFA` | 页面背景 |
| card | `#FFFFFF` | 卡片 |
| textPrimary | `#212121` | 标题 |
| textSecondary | `#616161` | 次要文字 |
| textHint | `#9E9E9E` | 占位 / 禁用 |

**分类色**（数据库 `categories.color`）独立于主色，用于 Chip / 标签，不随主色替换。

---

## 二、圆角与间距

| Token | 值 | 用途 |
|-------|-----|------|
| AppRadius.sm | 8 | 缩略图 |
| AppRadius.md | 12 | 输入框、小卡片 |
| AppRadius.lg | 16 | 列表卡片 |
| AppRadius.xl | 24 | 弹窗顶部 |

页面水平边距通常为 **16**；卡片间距 **12**。

---

## 三、通用组件

路径：`presentation/common/widgets/`

| 组件 | 用途 |
|------|------|
| `AppButton` | primary / secondary / outline / ghost / danger |
| `AppTag` | 状态标签（default / success / warning / danger / info） |
| `AppProgressBar` | 剩余量进度（auto 红橙绿） |
| `AppEmptyState` | 空列表（emoji + 标题 + 操作） |
| `QuantityStepper` | 数量步进器 |
| `CategorySelector` | 分类选择底部 sheet |
| `LocationPicker` | 位置级联选择 |
| `FilterBottomSheet` | 筛选与排序 |
| `MainScaffold` | 底部 4 Tab 壳 |
| `ShimmerLoading` | 骨架屏 |

物品相关：`items/widgets/item_card.dart`、`item_image_tile.dart`。

录入改版规格：[add-item-redesign.md](add-item-redesign.md)。

---

## 四、字体

使用 Material 3 默认字体 + `Theme.of(context).textTheme`：

- 页面标题：`titleLarge` / `headlineSmall`，w600–w700
- 列表主文字：`bodyLarge`
- 辅助信息：`bodySmall` + `textSecondary`

---

## 五、截图参考

`doc/image/` 目录含主要界面 PNG，可与 [information-architecture.md](information-architecture.md) 对照。

---

## 六、动效约定

| 场景 | 实现 |
|------|------|
| Tab 切换 | `FadeTransitionPage`（200ms） |
| 二级页 | `SlideTransitionPage` 右侧滑入（300ms） |
| 列表卡片 | `AnimatedScale` 0.98 按下反馈 |
| 下拉刷新 | `RefreshIndicator` |

---

## 七、维护

修改 Token 时同步更新：

1. `lib/core/constants/app_colors.dart`（及 `app_theme.dart`）
2. 本文件 + [visual-refresh.md](visual-refresh.md)
3. `lwh/code_changed/` 变更记录
