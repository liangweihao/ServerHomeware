# 全局主色换为青松 Teal — 技术文档

## 一、改动说明

按产品确认，Phase A：**先全局换色**，录入页 / 首页 / 列表改版后续跟进。

### 主色 Token

| Token | 新值 |
|-------|------|
| primary | `#3A9B8A` |
| primaryDark | `#2D7F71` |
| primaryLight | `#A8D5CC` |
| primaryLighter | `#E8F5F2` |

### 修改文件

- `HomeWareClient/lib/core/constants/app_colors.dart` — Token 真源 + `primaryHex`
- `HomeWareClient/lib/core/theme/app_theme.dart` — `ColorScheme`、ProgressIndicator
- `HomeWareClient/lib/presentation/profile/category_management_page.dart` — 默认分类色
- `HomeWareClient/web/manifest.json`、`pubspec.yaml` — Web theme_color

### 扩展性

后续换色只需改 `app_colors.dart` 的 primary* / info* 及 Web manifest；**分类色**（数据库）不随主色变。

### 设计文档

- 更新 `doc/design/visual-refresh.md`、`design-system.md`
- 新增 `doc/design/home-and-list-redesign.md`（首页/列表改版规格 v0.1）

---

## 二、提测

| 项 | 验证 |
|----|------|
| 底部 Tab 选中色 | 青松色 |
| FAB、主按钮 | 青松色 |
| 输入框聚焦边框 | 青松色 |
| 物品列表筛选 Chip 选中 | 青松底（后续 B1 可能改为浅底+深字） |
| Web 安装主题色 | manifest `#3A9B8A` |

运行 App 浏览：首页、物品、提醒、我的、添加页、登录页。

---

## 三、后续

- Phase B：首页 + 列表（见 home-and-list-redesign.md）
- Phase C：录入页折叠（见 add-item-redesign.md）
