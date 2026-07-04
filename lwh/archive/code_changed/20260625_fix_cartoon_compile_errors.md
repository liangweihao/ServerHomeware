# 卡通主题迁移编译错误修复

## 技术开发文档

### 问题概述

Flutter 构建失败，共 4 类编译错误：

1. `notification_settings_page.dart` — import 指令出现在顶层声明之后
2. `wrapAuthFormSurface` / `_wrapDetailSection` — 调用方使用命名参数 `child:`，但函数签名为位置参数
3. `statistics_page.dart` — `_buildWasteContent` 方法多一层闭合括号

### 改动点

| 文件 | 改动 |
|------|------|
| `notification_settings_page.dart` | 将 `cartoon_scaffold.dart`、`cartoon_ui.dart` 的 import 移至 StateProvider 声明之前 |
| `auth_cartoon_wrap.dart` | `wrapAuthFormSurface(Widget child, ...)` → `wrapAuthFormSurface({required Widget child, ...})` |
| `item_detail_page.dart` | `_wrapDetailSection(Widget child, ...)` → `_wrapDetailSection({required Widget child, ...})` |
| `statistics_page.dart` | 移除 `_buildWasteContent` 中 Column 多余的 `),` |

### 影响范围

- Auth 流程 6 页（login/register/verify/forgot/create/join）无需改动，已与命名参数签名匹配
- 物品详情页卡通区块包裹逻辑不变
- 统计页浪费统计区块结构不变

## 提测开发文档

### 测试点

1. 执行 `flutter run` 或 `flutter build`，确认无 kernel_snapshot 编译错误
2. 通知设置页正常打开，卡通主题下 Scaffold 样式正确
3. Auth 各页表单区在卡通主题下显示贴纸卡片包裹
4. 物品详情页「状态总览」「使用记录」区块在卡通主题下为贴纸卡片
5. 统计页「浪费统计」区块正常渲染，无布局异常

### 验证方式

```powershell
cd HomeWareClient
flutter analyze
flutter run
```

### 注意事项

- Kotlin 插件迁移提示为 Flutter 框架警告，与本次 Dart 编译错误无关
- 若仍有 analyze 报错，请检查 PATH 中 Flutter SDK 是否可用
