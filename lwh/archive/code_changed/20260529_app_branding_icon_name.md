# HomeStock 客户端品牌名称与图标更新

## 实现方案

统一各平台显示名称为 **HomeStock**（与产品文档、App 内 UI 一致），替换原默认 `home_stock` / `Home Stock`。

新增品牌图标：蓝色 (#2196F3) 背景 + 房屋与收纳盒组合图形，呼应「家庭物品管家」定位与启动页 🏠📦 视觉语言。

使用 `flutter_launcher_icons` 从 `assets/icon/app_icon.png` 自动生成 Android / iOS / Web / Windows / macOS 各尺寸图标。

## 改动点

| 文件 | 变更 |
|------|------|
| `android/.../AndroidManifest.xml` | `android:label` → HomeStock |
| `ios/Runner/Info.plist` | CFBundleDisplayName / CFBundleName → HomeStock |
| `macos/Runner/Configs/AppInfo.xcconfig` | PRODUCT_NAME → HomeStock |
| `web/manifest.json` | name、short_name、description、主题色 #2196F3 |
| `web/index.html` | title、apple-mobile-web-app-title、description |
| `windows/runner/Runner.rc` | ProductName 等字符串 → HomeStock |
| `linux/runner/my_application.cc` | 窗口标题 → HomeStock |
| `pubspec.yaml` | description、flutter_launcher_icons 配置 |
| `assets/icon/app_icon.png` | 新增主图标源文件 |
| 各平台 launcher icon 资源 | 由 flutter_launcher_icons 自动生成覆盖 |

**未改动**：Dart 包名 `home_stock`、Bundle ID `com.homestock.*`（避免破坏现有 import 与签名配置）。

## 影响范围

- 桌面/启动器/任务栏/浏览器标签页显示名称
- 各平台应用图标外观
- 无 API、业务逻辑影响

## 提测验证

1. **Android**：卸载重装或清缓存后，桌面图标与名称应为 HomeStock，图标为蓝底房屋+盒子
2. **iOS / macOS**：主屏幕 / Launchpad 名称与图标一致
3. **Windows**：开始菜单与任务栏显示 HomeStock，exe 属性 ProductName 正确
4. **Web**：浏览器标签 title 为 HomeStock，PWA manifest 名称正确
5. **App 内**：启动页、登录页等仍显示 HomeStock（原有逻辑，无需回归）

## 注意事项

- 若已安装旧版，部分平台需重新安装才能刷新图标缓存
- 重新生成图标：在 `HomeWareClient` 目录执行 `dart run flutter_launcher_icons`
