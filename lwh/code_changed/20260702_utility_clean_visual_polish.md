# utilityClean 视觉清爽化（去重色 / 暖灰底）

**日期**：2026-07-02  
**规范**：[`doc/design/ui_system.md`](../../doc/design/ui_system.md)

---

## 一、问题与根因

真机反馈：整体 UI「颜色很重、不干净」，与 `utilityClean` 目标（暖灰底 + 白卡 + 主色点缀）不符。

| 现象 | 根因 |
|------|------|
| 页面泛橙/泛黄 | `primaryLighter`、`accentHighlight` 大面积铺底 |
| 卡片脏、阴影叠边框 | `AppCard` 同时 elevation + 描边 |
| 个人中心像贴纸风 | Profile 重构引入渐变头图、宫格 tint 底 |
| M3 组件偏橙 | `ColorScheme.fromSeed` 把 surface 染成主色衍生色 |

---

## 二、改动点

### 全局 Token

| 文件 | 改动 |
|------|------|
| `app_color_palette.dart` | `utilityClean` 背景 `#FAFAF8`（暖灰白）；`primaryLighter` 改为中性 `#F5F3F0` |
| `app_colors.dart` | 新增 `iconWellBackground` / `infoBannerBackground` / `chipBackground` 等工具风 surface |
| `app_theme.dart` | 工具风使用显式中性 `ColorScheme`，避免 seed 染色 |
| `app_card.dart` | 工具风 elevation 0，仅轻描边 |

### 录入流程

| 文件 | 改动 |
|------|------|
| `add_item_method_page.dart` | 方式卡图标底改灰；去掉黄底；highlight 仅描边 |
| `add_item_wizard_view.dart` | 步骤条改描边圆点 + 灰连线；条码 Chip / 列表图标中性色 |
| `add_item_page.dart` | 扫码预填条改灰底提示样式 |
| `item_form_category_chips.dart` | 工具风 Chip 白/灰底 + 选中描边 |
| `item_form_view.dart` | 包装单位提示条改 info 灰底 |
| `app_segment_chip.dart` | 选中态去掉橙底 |

### 个人中心

| 文件 | 改动 |
|------|------|
| `profile_identity_header.dart` | 工具风纯白底、无渐变/点阵/装饰圆；头像细灰环 |
| `profile_overview_strip.dart` | 去掉渐变底；顶条 2px 实线；图标灰底 |
| `profile_quick_action_grid.dart` | 大卡/小格图标灰底，去掉 tint 渐变 |

---

## 三、设计原则（重申）

1. **暖**：页面底 `#FAFAF8`，非冷灰 `#F5F5F5` 纯平  
2. **净**：白卡 + `#EEEEEE` 描边，主色只用于选中/链接/FAB（黄）  
3. **卡通主题**：上述组件仍保留原渐变分支（`!AppColors.isUtilityStyle`）

---

## 四、提测文档

### 测试点

1. **个人中心 Tab**：头图应为白卡、无橙黄渐变；概览/宫格图标灰底  
2. **选择录入方式**：三方式卡白底灰图标；扫码卡仅橙色细边框  
3. **添加入库向导**：步骤条当前步橙描边空心圆；已完成绿色 ✓  
4. **扫码预填**：顶部提示灰底非橙底  
5. **分类 Chip**：未选白底灰边；选中浅灰底橙边  
6. **切换「卡通轻插画」**：头图/宫格渐变仍正常

### 验证

```powershell
cd HomeWareClient
flutter analyze
.\scripts\run_dev.ps1
```

热重启（非 hot reload）后目视上述页面；建议与改版前截图对比。

---

## 五、影响范围

- 客户端 UI：主题 Token、录入、个人中心
- 无 API / 后端变更
