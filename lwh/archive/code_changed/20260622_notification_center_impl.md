# Epic E1 实现：首页通知中心

> 日期：2026-06-22  
> PRD：`doc/product/prd/PRD-home-notification-center.md`

---

## 技术开发文档

### 实现方案

1. **Drift 新表** `AlertReadStates`（schema v2）：持久化已读/忽略，按 `(itemId, alertType, familyId)` 唯一
2. **统一 Badge**：`unreadAlertCountProvider` 统计四类未读提醒，首页 🔔 与底部提醒 Tab 共用
3. **新页面** `/notifications`：`NotificationCenterPage` 展示未读列表（最多 20 条）、全部已读、跳转详情与 `/alerts`
4. **提醒 Tab 改造**：`alertListProvider` + Drift 忽略/全部已读；已读条目仍在 Tab 展示
5. **共享文案**：`alert_display_helper.dart` 供 AlertCard 与通知中心复用

### 改动文件

| 文件 | 说明 |
|------|------|
| `lib/data/database/app_database.dart` | AlertReadStates 表 + 未读/已读/忽略 API |
| `lib/core/providers/alert_provider.dart` | 新建 Provider 与操作函数 |
| `lib/core/models/alert_type.dart` / `alert_tab.dart` | 类型与 Tab 枚举下沉 |
| `lib/core/utils/alert_display_helper.dart` | 提醒展示与紧急度 |
| `lib/presentation/notifications/notification_center_page.dart` | 通知中心 UI |
| `lib/presentation/home/home_page.dart` | 🔔 跳转 + Badge |
| `lib/presentation/common/widgets/main_scaffold.dart` | Tab Badge 改用未读数 |
| `lib/presentation/alerts/alert_center_page.dart` | Provider 化 + 持久化忽略/已读 |
| `lib/core/router/app_router.dart` | 路由 `/notifications` |
| `lib/core/providers/notification_provider.dart` | 移除重复 alertCountProvider |

### 影响范围

- 本地 DB schema 1→2，首次升级自动 `createTable(alertReadStates)`
- 无服务端 API 变更

---

## 提测开发文档

### 测试点

| ID | 步骤 | 预期 |
|----|------|------|
| T1 | 有未读提醒时首页点 🔔 | 进入通知中心，列表非空 |
| T2 | 对比 AppBar Badge 与提醒 Tab Badge | 数字一致 |
| T3 | 通知中心点「全部已读」 | Badge 归零，重启 App 仍为 0 |
| T4 | 全部已读后打开提醒 Tab | 仍能看到提醒卡片（已读≠已处理） |
| T5 | 提醒 Tab 点「忽略」 | 该条从 Tab 与通知中心消失，Badge 减 1 |
| T6 | 无未读时打开通知中心 | 空状态 + 添加物品/提醒设置按钮 |
| T7 | 点击通知行 | 跳转物品详情 `/items/:id` |
| T8 | 点击「查看全部提醒」 | 跳转 `/alerts` |

### 验证命令

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat pub run build_runner build
C:\flutter\bin\flutter.bat analyze lib/core/providers/alert_provider.dart lib/presentation/notifications/
```

### 注意事项

- Epic E2（WebSocket 实时同步）未包含在本实现
- P1 服务端 `/alerts/summary` 联调未做，离线纯本地可用
