# HomeWare Client (Flutter)

家庭库存管理客户端，对接 `HomeWareServer` 后端 API。

## 环境要求

| 工具 | 版本 |
|------|------|
| Flutter | stable（Dart SDK **≥ 3.11**，见 `pubspec.yaml`） |
| 后端服务 | `http://<host>:8000`，API 前缀 `/api/v1` |

### 安装 Flutter（Windows）

1. 下载 [Flutter SDK for Windows](https://docs.flutter.dev/get-started/install/windows)
2. 解压到例如 `C:\flutter`，将 `C:\flutter\bin` 加入系统 **PATH**
3. 验证：

```powershell
flutter doctor
```

按需安装 Android Studio / Visual Studio（Windows 桌面开发）。

### Windows 桌面报错：Visual Studio toolchain

若出现 `Unable to find suitable Visual Studio toolchain`，需安装 **Visual Studio 2022** 并勾选工作负载 **「使用 C++ 的桌面开发」**（Desktop development with C++）：

- 下载：https://visualstudio.microsoft.com/downloads/（Community 免费版即可）
- 或仅安装构建工具（体积更小）：

```powershell
winget install -e --id Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

安装完成后**重新打开终端**，执行 `flutter doctor` 确认 Visual Studio 项为 √。

若编译报错 **`atlbase.h: No such file or directory`**（`flutter_local_notifications_windows` 需要 ATL），在 Build Tools 上补装 ATL 组件：

```powershell
.\scripts\install_vs_atl.ps1
```

或在 **Visual Studio Installer → 修改 → 单个组件** 中勾选：

**C++ v14.44 (17.14) ATL for v143 build tools (x86 & x64)**

（组件 ID：`Microsoft.VisualStudio.Component.VC.14.44.17.14.ATL`）

**暂时不想装 VS**：可改用已连接的真机或模拟器、或 Chrome：

```powershell
flutter run -d 5f990c82          # 你的 Android 设备 ID（flutter devices 查看）
flutter run -d chrome            # 浏览器
```

## 快速开始

### 1. 启动后端

在项目根目录（`ServerHomeware`）启动服务端，默认端口 **8000**：

```bash
./start_server.sh
```

Windows 可进入 `HomeWareServer` 目录手动启动 uvicorn。

### 2. 初始化客户端环境

在 `HomeWareClient` 目录执行：

```powershell
# 本机 / Windows 桌面调试（默认 127.0.0.1）
.\scripts\setup_env.ps1

# Android 模拟器
.\scripts\setup_env.ps1 -Platform android

# 真机（自动检测局域网 IP）
.\scripts\setup_env.ps1 -Platform device
```

脚本会生成 `config/env.local.json`、执行 `flutter pub get` 和代码生成。

### 3. 运行应用

```powershell
# 使用 env.local.json 中的 API 地址
.\scripts\run_dev.ps1

# 指定设备
.\scripts\run_dev.ps1 -Device windows
.\scripts\run_dev.ps1 -Device chrome
.\scripts\run_dev.ps1 -Device android
```

或在 VS Code / Cursor 中选择 `.vscode/launch.json` 中的启动配置。

## API 地址配置

所有 HTTP 请求通过 `lib/core/config/app_env.dart` 读取 `API_BASE_URL`：

| 场景 | 推荐地址 |
|------|----------|
| Windows / Web / iOS 模拟器 | `http://127.0.0.1:8000/api/v1` |
| Android 模拟器 | `http://10.0.2.2:8000/api/v1` |
| 真机 | `http://<电脑局域网IP>:8000/api/v1` |

手动指定（不依赖 `env.local.json`）：

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

复制 `config/env.example.json` 为 `config/env.local.json` 并按需修改。

## 代码生成

修改 Drift / Freezed 模型后执行：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

## 项目结构（简要）

```
lib/
  core/
    config/app_env.dart   # API 环境配置
    services/             # API / 认证 / 家庭等服务
    providers/            # Riverpod 状态
  data/database/          # 本地 SQLite (Drift)
  presentation/           # UI 页面
```

## 常见问题

**`flutter` 命令找不到**  
确认 Flutter 已安装且 `bin` 目录在 PATH 中，重新打开终端。

**真机无法连接 API**  
- 手机与电脑在同一 Wi-Fi  
- 使用 `setup_env.ps1 -Platform device` 生成局域网地址  
- 确认 Windows 防火墙允许 8000 端口入站  

**Android 模拟器连不上 localhost**  
必须使用 `10.0.2.2`，不要用 `127.0.0.1`。

**Gradle `Connection timed out`（下载 Gradle / 依赖失败）**  
国内网络常无法访问 `services.gradle.org`。项目已配置腾讯云 Gradle 镜像与阿里云 Maven；若仍失败：

```powershell
.\scripts\fix_android_gradle.ps1
flutter clean
flutter run -d <device-id>
```

若使用代理，在 `android/gradle.properties` 中配置 `systemProp.http.proxyHost` / `systemProp.https.proxyHost`。
