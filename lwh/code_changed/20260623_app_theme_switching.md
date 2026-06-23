# 应用主题切换功能

## 概述

新增 4 种可切换的应用主色主题（含默认青松绿 + 创意紫 / 暖橙活力 / 翡翠清新），用户可在「我的 → 主题样式」中切换，选择立即生效并持久化到本地。

## 实现方案

### 架构

```
AppThemeVariant (枚举)
    └── AppColorPalette (色板：primary / background 等)
            └── AppColors.applyPalette() (全局 Token 热更新)
                    └── AppTheme.lightThemeOf(palette) (Material Theme)
                            └── MaterialApp.theme (Riverpod 驱动重建)
```

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/core/theme/app_color_palette.dart` | 色板数据类与 4 套预设色值 |
| `lib/core/theme/app_theme_variant.dart` | 主题变体枚举、展示文案、持久化键 |
| `lib/core/providers/theme_provider.dart` | Riverpod Notifier + SharedPreferences |
| `lib/presentation/profile/theme_settings_page.dart` | 主题选择 UI |

### 修改文件

| 文件 | 改动 |
|------|------|
| `lib/core/constants/app_colors.dart` | 主色相关字段改为 getter，支持 `applyPalette` |
| `lib/core/theme/app_theme.dart` | 新增 `lightThemeOf(palette)` 动态构建 ThemeData |
| `lib/main.dart` | 启动预加载主题；`MyApp` 改为 `ConsumerWidget` 监听主题 |
| `lib/core/router/app_router.dart` | 注册 `/profile/theme-settings` 路由 |
| `lib/presentation/profile/profile_page.dart` | 新增「主题样式」入口 |
| 若干 auth/item 页面 | 移除 `const` 修饰（主色 getter 非编译期常量） |

### 色板定义

| 主题 | 主色 | 背景 |
|------|------|------|
| 青松绿（默认） | `#3A9B8A` | `#FAFAFA` |
| 创意紫 | `#7C4DFF` | `#FAFAFA` |
| 暖橙活力 | `#FF9800` | `#FFF8F5` |
| 翡翠清新 | `#10B981` | `#F5FAF8` |

语义色（success / warning / danger）与分类色保持不变，不随主题切换。

### 持久化

- 键名：`app_theme_variant`
- 值：`teal` / `creative_purple` / `warm_orange` / `emerald_fresh`
- 启动时在 `main()` 中同步加载，避免首帧颜色闪烁

## 影响范围

- 所有使用 `AppColors.primary` / `info` / `background` 的 UI 组件会随主题变化
- BottomNavigationBar、FAB、ProgressIndicator、Input 聚焦边框等 Material 主题组件同步更新
- 分类色、告警语义色不受影响

## 提测要点

### 功能验证

1. 进入「我的 → 主题样式」，确认展示 4 种主题选项及色板预览
2. 依次选择创意紫 / 暖橙活力 / 翡翠清新，确认：
   - 底部导航选中色、首页统计卡片、按钮等主色即时变化
   - 页面背景色（暖橙/翡翠）有轻微色调变化
3. 完全退出 App 后重新打开，确认主题选择被保留
4. 切换回青松绿，确认恢复默认样式

### 回归验证

1. 提醒设置、分类管理等功能页正常显示
2. 登录/注册页输入框聚焦边框颜色随主题变化
3. 告警中心红/橙语义色不受主题影响

### 注意事项

- Web manifest 仍使用默认 Teal 主色，PWA 启动画面不随 App 内主题变化
- 若后续需要「仅展示 3 种新主题、隐藏默认」，可在 `ThemeSettingsPage` 过滤 `AppThemeVariant.values`
