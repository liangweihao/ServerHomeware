# P 阶段：本地/服务端 itemId 映射

## 技术开发文档

### 背景

M 阶段 usage 双向同步假定「本地 `items.id` == 服务端 `items.id`」。在以下场景会失败：

- 历史本地自增 id 与服务端 id 不一致
- 双设备同步时 usage 拉取/推送使用了错误的 `item_id`
- 编辑/详情/丢弃等 API 仍用本地主键调用服务端

### 实现方案

#### 1. Drift schema v4

`items` 表新增可空列 **`server_item_id`**：

- 本地主键与服务端 id 一致时：可为空（解析时回退 `id`）
- 不一致时：显式存储服务端 id

#### 2. 映射解析（`AppDatabase` + `ItemIdResolver`）

| 方法 | 用途 |
|------|------|
| `resolveServerItemId(localId)` | 推送 usage、调用写 API |
| `resolveLocalItemId(serverId)` | 拉取 usage 写入本地 |
| `setItemServerItemId` / `ensureItemServerItemId` | 创建/同步后绑定 |

`Item.serverApiId` 扩展（`item_api_id.dart`）：`serverItemId ?? id`

#### 3. 同步链路调整

- **`UsageRecordSyncService`**
  - `syncBidirectional()`：先 `ItemSyncService.syncFromServer()` 再拉/推 usage
  - 推送：`toServerId(localItemId)` 再 POST
  - 拉取：`toLocalId(serverItemId)`，无映射则跳过并 WARN
- **`ItemSyncService`**：插入服务端物品时写入 `serverItemId`；已存在物品回填映射
- **`add_item_page`**：入库成功后 `ItemIdResolver.bind`

#### 4. API 调用统一

以下路径改为 `item.serverApiId`：

- `edit_item_page` 更新
- `item_detail_page` 状态变更/删除
- `usage_dialog` 丢弃状态同步
- `item_detail_provider` 拉取服务端详情

### 改动文件

| 区域 | 文件 |
|------|------|
| DB v4 | `app_database.dart` + `app_database.g.dart` |
| 解析 | `item_id_resolver.dart`, `item_api_id.dart` |
| usage 同步 | `usage_record_sync_service.dart` |
| 物品同步 | `item_sync_service.dart` |
| 入库 | `add_item_page.dart`, `item_form_controller.dart` |
| API | `edit_item_page.dart`, `item_detail_page.dart`, `usage_dialog.dart`, `item_detail_provider.dart` |

### 影响范围

- 需执行 `dart run build_runner build`（schema v4）
- 旧用户升级：自动 `ALTER TABLE` 增加列，历史数据 `serverItemId` 为空时行为与改前一致
- 路由/列表仍用**本地主键**导航；仅 API 与 usage 同步走映射

---

## 提测开发文档

### 测试点

1. **主路径（id 一致）**：添加入库 → 记消耗 → 双设备家庭协作可见（与 M 相同）
2. **映射回填**：升级后打开已有物品 → 编辑保存 → 服务端更新成功
3. **usage 拉取**：设备 B 仅有服务端物品（ItemSync 后）→ 下拉家庭贡献 → 设备 A 的消耗记录出现
4. **无映射跳过**：本地无对应物品时，拉取 usage 不插入脏数据（日志 WARN）
5. **DB 迁移**：v3 → v4 升级不丢物品与 usage 记录

### 验证方式

- 双设备：A 记消耗 → B ItemSync + usage sync → 贡献/动态更新
- 日志关键字：`[ItemIdMap]`、`[UsageRecordSync] INFO: 已推送`、`serverItemId=`
- 可选：手动将某物品 `server_item_id` 设为与 `id` 不同，验证 `serverApiId` 与 usage 推送 id

### 注意事项

- 当前入库仍使用「服务端 id 作为本地主键」；映射主要为历史兼容与后续离线入库预留
- 告警中心 `alertReadStates.itemId` 仍用本地 id，与服务端提醒 id 对齐待后续迭代
- 合并 usage 去重仍按**本地 itemId** + type + 时间
