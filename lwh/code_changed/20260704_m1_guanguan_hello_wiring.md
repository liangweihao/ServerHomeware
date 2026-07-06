# M1 管管 hello 动效接入

**日期**：2026-07-04  
**状态**：已交付  
**关联**：M1 里程碑、`GuanguanHelloAnimation`

---

## 一、实现方案

| 组件 | 路径 | 职责 |
|------|------|------|
| 每日偏好 | `core/services/guanguan_hello_prefs.dart` | 每日首次进入问管管才播放 |
| 序列帧动画 | `presentation/common/widgets/guanguan_hello_animation.dart` | 4 帧 0→1→2→2→3；缺资源时挥手图标 fallback |
| 静态头像 | `presentation/common/widgets/guanguan_mascot_avatar.dart` | idle / icon 两模式 |
| 会话顶栏 | `presentation/assistant/widgets/assistant_mascot_header.dart` | hello 播完缩至 compact idle |
| 首页入口 | `presentation/home/widgets/home_top_bar.dart` | 问管管按钮换管管头像 icon |

### 行为

1. 用户点首页 🤖 → `/assistant`
2. 若今日未播过：顶栏 96px hello 动画 +「你好呀～」
3. 播完标记 SharedPreferences → 缩至 44px idle + 副标题
4. 同日再次进入：直接 idle，不重复播

### 资源缺失

仓库内 **尚无** `assets/illustrations/guanguan/hello/*.png`（设计稿路径已预留）。  
运行时检测 AssetBundle → 自动降级为 **挥手图标 + 缩放动画**，不阻塞功能。

---

## 二、提测

| # | 步骤 | 预期 |
|---|------|------|
| 1 | 清除 App 数据或改系统日期 | 首次进问管管有 hello 动画（或 fallback 挥手） |
| 2 | 返回首页再进问管管 | 仅小头像 idle，不再播 |
| 3 | 系统「减少动态效果」 | 直接收尾/静态，不卡死 |
| 4 | 首页顶栏问管管按钮 | 显示管管圆形 icon 头像 |
| 5 | 补 PNG 四帧后 hot restart | 自动切序列帧，无需改代码 |

### 自动化

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/services/guanguan_hello_prefs_test.dart
```

---

## 三、后续

- 设计师 PNG 四帧入库至 `assets/illustrations/guanguan/hello/`
- Gate M1-8 可标 ✅
- Phase B / 管管 P2 立项评估
