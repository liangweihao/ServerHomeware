# 糖果轻点主题统一与圆润图标体系

> 日期：2026-07-06  
> 范围：HomeWareClient UI / 设计文档

---

## 技术开发文档

### 1. 主题唯一化

- `AppThemeVariant` 仅保留 `vividClean`（糖果轻点）
- 启动时旧主题键（清爽工具/卡通/居家暖色）自动迁移
- 移除主题切换 UI，「主题样式」改为「视觉规范」只读预览页

### 2. 设计 Token 整理

| 文件 | 改动 |
|------|------|
| `app_colors.dart` | 暖灰白底、暖灰文字、饱和 iconWell |
| `app_typography.dart` | Nunito 层级 28→11 |
| `app_radius.dart` | sm 10 / md 14 / lg 18 / xl 24 / dock 28 |
| `app_theme.dart` | 糖果专用 M3 主题、圆角输入/按钮/Dialog |
| `app_color_palette.dart` | 删除多色板，仅 vividClean |

### 3. 图标体系

- 重绘 8 个底栏 SVG（home/items/alerts/profile × outline/filled）
- 新增 `CandyIcons` — Material Rounded 映射
- 新增 `AppIcon` / `AppIcon.feature` — 饱和圆角底 + 白标
- 底栏：选中/未选中均用 SVG，去掉 emoji
- 个人中心宫格：统一 `CandyIcons` + 渐变大卡

### 4. 背景

- `AppThemeBackground`：暖灰底 + 6% 透明度圆点纹理

### 5. 设计文档

- [`doc/design/candy-light-design-system.md`](../../doc/design/candy-light-design-system.md)

---

## 提测开发文档

### 验证点

1. 冷启动 → 全 App 暖灰白底 + Nunito 字体
2. 底栏 Tab：outline/filled 切换，无 emoji
3. 个人中心宫格：饱和圆角色块 + 白图标
4. 设置 → 视觉规范：色板/字体/圆角预览
5. 旧版主题缓存设备 → 自动变为糖果轻点

### 已知后续

- 购物/搜索/统计等次级模块仍有个别 `Icons.outlined` 未替换
- 空状态 SVG 插画风格待下一轮统一

### 2026-07-06 增量（A/B/C）

**A 首页+物品+提醒**：32 个文件 `Icon` → `CandyIcon`  
**B 认证**：`create_family_page`、`password_input` 等  
**C 动作 SVG**：12 个 `assets/icons/action/*.svg` + `CandyIconAssets`  
**重点页**：录入方式选择、首页快捷弹层改用 SVG + 饱和色块

### 2026-07-06 增量（预置图标 + 全局审计）

**预置图标**：见上文「2026-07-06 增量（预置图标）」各节。

**全局审计文档**：[`lwh/ui_icon_style_audit.md`](../ui_icon_style_audit.md) — 模块级 Icon/emoji 状态、P0–P3 替换批次、死代码清理列表。

### 影响范围

- 纯客户端视觉，无 API/数据变更
- 用户本地主题偏好会被迁移为糖果轻点
- 分类/位置 icon 字段仍为 emoji 字符串，仅渲染层映射为圆润 Material 图标
