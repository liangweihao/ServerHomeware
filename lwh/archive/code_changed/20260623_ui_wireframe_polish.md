# UI 线框优化落地（通知中心 + 列表 + 首页）

> 日期：2026-06-23  
> 依据：`doc/design/home-and-list-redesign.md`、`PRD-home-notification-center.md`、上一轮 UI 优化评审

---

## 技术开发文档

### 实现方案

1. **Drift 代码生成**：运行 `build_runner`，确保 `AlertReadStates` 表与 schema v2 迁移代码可用
2. **通知中心对齐线框**：
   - 标题区文案改为「今天 · N 条未处理」
   - 列表项展示物品名 + 提醒类型 + 位置路径（`厨房 › 冰箱`）
   - emoji 改为 Material Icon（`alert_display_helper.iconData`）
   - 增加 `Semantics` 无障碍标签
   - 无未读时隐藏「全部已读」
   - 加载态使用 `ShimmerNotificationTile` 骨架屏
3. **Provider 增强**：`unreadNotificationsProvider` 返回 `NotificationEntry`（含位置路径）
4. **首页今日待办条**：点击跳转 `/notifications`（与 AppBar 🔔 职责一致）
5. **物品列表 ItemCard**：增加分类色小标签（`categoryName` + `categoryColorHex`）

### 改动文件

| 文件 | 说明 |
|------|------|
| `lib/core/models/notification_entry.dart` | 新建通知条目视图模型 |
| `lib/core/utils/alert_display_helper.dart` | 增加 `iconData`；修正过期文案 |
| `lib/core/providers/alert_provider.dart` | 通知列表附带位置路径 |
| `lib/presentation/notifications/notification_center_page.dart` | 线框 UI 对齐 |
| `lib/presentation/common/widgets/shimmer_loading.dart` | `ShimmerNotificationTile` |
| `lib/presentation/home/home_page.dart` | 今日待办条跳转通知中心 |
| `lib/presentation/items/widgets/item_card.dart` | 分类标签 |
| `lib/presentation/items/item_list_page.dart` | 预取分类元数据 |

### 影响范围

- Epic E1 通知中心体验增强，无 API / schema 变更
- 物品列表卡片视觉微调，无数据模型变更

---

## 提测开发文档

### 测试点

| ID | 步骤 | 预期 |
|----|------|------|
| T1 | 有未读提醒，首页点 🔔 | 进入通知中心，标题「今天 · N 条未处理」 |
| T2 | 查看通知列表行 | 显示 Material 图标、提醒文案、位置路径 |
| T3 | 无未读时打开通知中心 | 无「全部已读」按钮；空状态双 CTA |
| T4 | 加载通知中心（慢网/首次） | 骨架屏而非空白转圈 |
| T5 | 首页「今日待办」摘要条点击 | 进入 `/notifications`（非 `/alerts`） |
| T6 | 物品列表 | 物品名右侧显示分类色小标签 |
| T7 | VoiceOver / TalkBack | 通知行可读物品名+类型+位置 |

### 验证命令

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat pub run build_runner build
C:\flutter\bin\flutter.bat analyze lib/presentation/notifications lib/presentation/items/widgets/item_card.dart
```

### 注意事项

- 已读/忽略逻辑仍依赖 Epic E1 既有 `AlertReadStates` 表
- P1「按类型分组」通知列表未在本轮实现
- **2026-06-23 补充**：`AppColors.primary/info` 改为主题 getter 后，需去掉相关 `const` 装饰/样式，否则热重启编译失败
