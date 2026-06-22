# Flutter 客户端架构

> 对应目录：`HomeWareClient/`。包名 `home_stock`，产品名 HomeStock / 家庭物品管家。

---

## 一、技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter 3.x + Dart |
| 状态管理 | flutter_riverpod |
| 路由 | go_router（ShellRoute 底部 Tab + 全屏二级页） |
| 本地数据库 | Drift（SQLite via drift_sqflite） |
| 模型 | drift 表 + 部分 freezed/json |
| HTTP | `http` + 统一 `ApiService`（JWT Bearer） |
| 代码生成 | build_runner（drift_dev、freezed 等） |

---

## 二、目录结构（现行）

```
lib/
├── main.dart
├── core/
│   ├── config/app_env.dart       # API_BASE_URL
│   ├── constants/                # 颜色、间距、圆角
│   ├── router/app_router.dart    # 全部路由
│   ├── providers/                # Riverpod Provider
│   ├── services/                 # API 封装（auth、items、upload…）
│   ├── events/                   # ItemEventBus 等
│   └── utils/
├── data/database/                # Drift 定义与 DAO
└── presentation/                 # 按功能划分的页面与组件
    ├── auth/
    ├── home/
    ├── items/
    ├── alerts/
    ├── locations/
    ├── shopping/
    ├── statistics/
    ├── search/
    ├── profile/
    └── common/widgets/
```

> **注意**：早期 Phase 文档中的 `domain/`、`usecases/`、Clean Architecture **未采用**。业务逻辑分布在 `core/services`、`core/providers` 与页面 State 中。

---

## 三、导航与路由

### 底部 Tab（4 个）

| Index | 路径 | 页面 |
|-------|------|------|
| 0 | `/` | 首页 |
| 1 | `/items` | 物品列表 |
| 2 | `/alerts` | 提醒中心（Badge 未读数） |
| 3 | `/profile` | 我的 |

定义于 `presentation/common/widgets/main_scaffold.dart`。

### 添加物品入口

- **物品列表页 FAB** → `/items/add`
- **扫码** → `/items/scan`（识别后跳转添加页并带 barcode 参数）
- 非底部 Tab 中间「＋」（旧原型已废弃）

### 路由表

完整路由见 `core/router/app_router.dart`。文字版线框见 [design/information-architecture.md](../design/information-architecture.md)。

---

## 四、数据流

### 混合模式：API + 本地 Drift

```
用户操作
   ↓
Presentation（页面 / Widget）
   ↓
Provider（Riverpod）← ItemEventBus 触发刷新
   ↓
Service（ApiService 子类）────→ FastAPI /api/v1
   ↓
Drift（本地 SQLite）← ItemSyncService.syncFromServer()
```

| 场景 | 数据源 |
|------|--------|
| 登录 / 家庭 / 用户资料 | 服务端 API |
| 创建/更新物品（含图片） | 先上传图片 → API 创建 → 写入 Drift |
| 物品列表 | 同步后读 Drift（离线可读） |
| 提醒列表 | 主要读 Drift 本地规则 |
| 首页统计 / 动态 | API Provider + 部分本地聚合 |

### 关键类

- `ApiService`：JWT 存储、请求拦截、401 登出回调
- `ItemSyncService`：从服务端拉取物品写入 Drift
- `ItemEventBus`：物品增删改后通知列表/详情刷新
- `UploadService`：本地图片上传至 `/upload/images`

---

## 五、环境配置

```powershell
cd HomeWareClient
.\scripts\setup_env.ps1              # localhost
.\scripts\setup_env.ps1 -Platform android
.\scripts\run_dev.ps1
```

`config/env.local.json` 中的 `API_BASE_URL` 在启动时由 `app_env.dart` 读取。

---

## 六、与归档 Phase 文档的差异

| 归档文档描述 | 现行实现 |
|-------------|----------|
| 5 Tab + 中心录入 | 4 Tab + FAB |
| 图片仅存本地路径 | 上传服务端 + URL 存 Drift |
| riverpod code generation 为主 | 手写 Provider 为主 |
| 项目名 home_stock 独立目录 | 仓库内 HomeWareClient |

历史任务书见 [`archive/client-phase-specs/`](../archive/client-phase-specs/)。
