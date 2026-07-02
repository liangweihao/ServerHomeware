# 糖果轻点（vividClean）预览主题落地

**日期**：2026-07-02  
**规范**：[`20260702_vivid_clean_ui_style_spec.md`](20260702_vivid_clean_ui_style_spec.md)

---

## 一、技术开发文档

### 目标

新增可切换预览主题 `vividClean`（糖果轻点），不替换默认 `utilityClean`。

### 改动文件

| 文件 | 改动 |
|------|------|
| `app_visual_style.dart` | 新增 `vividClean` |
| `app_color_palette.dart` | `AppColorPalettes.vividClean` 锁定配色 |
| `app_theme_variant.dart` | 主题项「糖果轻点」 |
| `app_colors.dart` | `accent*` 功能色、`iconWellFor`、`tagBackgroundFor`、`reasonLowStock` |
| `app_theme.dart` | vividClean 走中性 ColorScheme + 黄 FAB |
| `profile_quick_actions_config.dart` | 宫格固定 accent 映射 |
| `profile_quick_action_grid.dart` | `iconWellFor` 饱和底白标 |
| `profile_overview_strip.dart` | 概览图标 `iconWellFor` |
| `profile_page.dart` | 概览条购物/支出 accent |
| `app_list_row.dart` | 列表行图标 `iconWellFor` |
| `app_segment_chip.dart` | 选中白底珊瑚描边 |
| `app_reason_tag.dart` | `tagBackgroundFor` |
| `item_list_reason_helper.dart` | 低库存 `reasonLowStock` |
| `item_card.dart` | 标签底 `tagBackgroundFor` |
| `theme_settings_page.dart` | 说明文案 |

### 切换路径

**我的 → 设置（宫格）→ 主题样式 → 糖果轻点**

---

## 二、提测文档

### 对比点（与「清爽工具」切换）

1. 个人中心宫格：灰底图标 → **饱和色底 + 白图标**
2. 概览三卡：顶条语义色 + 图标饱和底
3. 物品列表理由标签：略更鲜艳（14% 底）
4. 低库存标签：糖果轻点下为 **天蓝** `#4A9FE8`
5. 筛选 Chip 选中：白底 + 珊瑚描边
6. 默认仍为「清爽工具」，重启后保留上次选择

### 验证

```powershell
cd HomeWareClient
flutter analyze
.\scripts\run_dev.ps1
```

热重启 → 主题样式切换两种主题目视首页/列表/我的。

---

## 三、影响范围

- 客户端主题与点缀色组件
- 无 API / 后端变更
