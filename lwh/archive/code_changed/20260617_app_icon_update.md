# 应用图标更新

**日期**: 2026-06-17

## 改动概述

将应用图标从旧图标更换为 `icon_manager_launcher.jpg`（2048x2048 JPG）。

## 实现方案

1. 使用 Python Pillow 将 JPG 源图转换为 1024x1024 PNG，覆盖 `assets/icon/app_icon.png`
2. 使用 `flutter_launcher_icons` 重新生成所有平台图标
3. 手动更新 macOS AppIcon 多尺寸资源（16/32/64/128/256/512/1024）
4. 手动更新 Windows `.ico` 文件
5. **Android Adaptive Icon**: 手动生成带圆角的前景图 + 白色背景图，创建 `mipmap-anydpi-v26` 自适应图标配置

## 改动文件

| 文件 | 改动 |
|------|------|
| `assets/icon/app_icon.png` | 替换为新图标（1024x1024 PNG） |
| `windows/runner/resources/app_icon.ico` | 替换为新图标生成的 .ico |
| `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png` | 替换所有尺寸 |
| `android/app/src/main/res/mipmap-*/ic_launcher.png` | 由 flutter_launcher_icons 自动生成 |
| `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png` | 新增：带圆角的前景图（5种密度） |
| `android/app/src/main/res/mipmap-*/ic_launcher_background.png` | 新增：白色背景图（5种密度） |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | 新增：自适应图标配置 |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` | 新增：圆形自适应图标配置 |

## 影响范围

- 所有平台（Android/iOS/Windows/macOS/Web）的应用图标更新
- 不影响任何业务逻辑代码

## 验证方式

1. 在 Windows 上构建运行，检查任务栏和桌面图标
2. 在 Android 上构建运行，检查启动器图标
3. 确认图标清晰无变形，四个角无异常裁剪
