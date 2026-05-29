# App 名称中文化

## 改动概述

将客户端所有平台的显示名称从英文 "HomeStock" 统一改为中文 "物品管家"。

## 影响范围

| 平台 | 文件 | 改动内容 |
|------|------|----------|
| Android | `android/app/src/main/AndroidManifest.xml` | `android:label` → 物品管家 |
| iOS | `ios/Runner/Info.plist` | `CFBundleDisplayName`, `CFBundleName` → 物品管家 |
| macOS | `macos/Runner/Configs/AppInfo.xcconfig` | `PRODUCT_NAME` → 物品管家 |
| Windows | `windows/runner/Runner.rc` | `FileDescription`, `InternalName`, `OriginalFilename`, `ProductName` → 物品管家 |
| Linux | `linux/runner/my_application.cc` | GTK header bar / window title → 物品管家 |
| Web | `web/index.html` | `<title>`, `<meta apple-mobile-web-app-title>` → 物品管家 |
| Web | `web/manifest.json` | `name`, `short_name` → 物品管家 |

## 图标

保持现有图标源文件 `assets/icon/app_icon.png` 不变。`pubspec.yaml` 中的 `flutter_launcher_icons` 配置已正确指向该文件，如需重新生成各平台图标，运行：

```bash
cd HomeWareClient
dart run flutter_launcher_icons
```

## 测试点

- [ ] Android 桌面图标名称显示为"物品管家"
- [ ] iOS 主屏幕图标名称显示为"物品管家"
- [ ] macOS 应用名称显示为"物品管家"
- [ ] Windows 任务栏/窗口标题显示为"物品管家"
- [ ] Linux 窗口标题显示为"物品管家"
- [ ] Web 标签页标题显示为"物品管家"
- [ ] PWA 安装后名称为"物品管家"

## 注意事项

- 包名（`com.homestock.home_stock`）和 Bundle Identifier 保持不变
- 不涉及后端改动
