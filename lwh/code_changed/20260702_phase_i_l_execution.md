# Phase I→L 顺序执行记录

**日期**：2026-07-02  
**范围**：HomeWareClient 客户端优化 Phase I ~ L

---

## 一、技术开发文档

### Phase I — E2 可观测性 + 盘点同步 + 数据导出

| 改动点 | 说明 |
|--------|------|
| `inventory_task_provider.dart` | 盘点修正后 `ItemService.updateItem` 同步服务端；完成时 `InventoryTaskStorage.append` 写历史 |
| `realtime_sync_status_provider.dart` | 新增 `RealtimeSyncStatus` 枚举与全局 Provider |
| `realtime_sync_service.dart` | 连接/断开/重连时通过 `onStatusChanged` 上报状态 |
| `realtime_sync_provider.dart` | Controller 接线状态 Provider |
| `export_data_dialog.dart` | 数据导出弹窗（已有） |
| `profile_panel_page.dart` | 「数据导出」接通 `ExportDataDialog`；展示实时同步状态条 |
| `profile_page.dart` | 导出逻辑复用 `ExportDataDialog`，删除重复代码 |

### Phase J — 搜索卡片统一 + 卡通组件清理

| 改动点 | 说明 |
|--------|------|
| `search_page.dart` | 搜索结果 `WarmSearchResultTile` → `ItemCard(layout: reasonFirst)` |
| `family_management_page.dart` | 工具风成员列表行（`AppColors.isUtilityStyle` 分支），卡通主题保留 `CartoonListTile` 回退 |

### Phase K — 消耗估算 + 盘点 v2 + 协作前台化

| 改动点 | 说明 |
|--------|------|
| `item_form_controller.dart` | 新增 `estimatedUseDays`、`computeConsumptionEstimate()`；写入本地/API |
| `add_item_wizard_view.dart` | Step4 增加「预计使用天数」步进器 |
| `inventory_task_page.dart` | 选空间页底部展示「最近盘点」历史（最多 3 条） |
| `item_detail_page.dart` | 标题区展示「最后操作人」（来自 `recentRecords`） |
| `profile_panel_page.dart` | 已有 `FamilyContributionSection` 家庭贡献区块 |

### Phase L — 测试 + Auth 工具风 + 文档

| 改动点 | 说明 |
|--------|------|
| `inventory_task_storage_test.dart` | 盘点历史 append/load |
| `item_form_consumption_test.dart` | 消耗估算计算 |
| `realtime_sync_status_test.dart` | WS 状态枚举 |
| `auth_cartoon_wrap.dart` | 已有工具风/卡通双分支，无需改动 |

---

## 二、提测开发文档

### 测试点

1. **实时同步状态**：登录后个人中心应显示「实时同步已连接」；断网/杀后端后应变为「重连中」或「未连接」
2. **盘点修正同步**：盘点中修正数量 → 另一设备刷新后数量一致（需后端已启动且 WS 正常）
3. **盘点历史**：完成盘点后返回选空间页，底部出现「最近盘点」记录
4. **数据导出**：个人中心 / Profile Panel「数据导出」→ 选择范围 → CSV 分享
5. **搜索统一卡片**：搜索物品结果与物品列表 reasonFirst 风格一致
6. **预计使用天数**：添加入库 Step4 填写天数 → 详情页「状态总览」显示预测文案
7. **最后操作人**：有使用记录的物品详情标题下显示操作人

### 验证方式

- 热重启客户端，确保后端 `uvicorn` 已重启（WS 中间件修复后）
- 双设备或 Web + 手机验证 WS 与盘点同步
- `flutter test`（需本机 PATH 配置 Flutter）

### 注意事项

- API `CreateItemRequest` 未显式声明 `avg_daily_consumption` 字段，服务端可能忽略；本地 Drift 仍会写入
- `WarmSearchResultTile` 文件保留但搜索页已不再引用
- 本环境 Flutter 未在 PATH，测试需在本地 IDE 执行

---

## 三、影响范围

- 客户端：搜索、个人中心、盘点、添加入库、物品详情、家庭成员页
- 后端：盘点修正触发 `PUT /items/{id}`；WS 状态无 API 变更
