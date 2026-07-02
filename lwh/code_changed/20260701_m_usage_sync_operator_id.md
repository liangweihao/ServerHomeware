# M 阶段：usage 多端同步 + operator_id 对齐

## 技术开发文档

### 背景

记消耗/入库仅写本地 Drift，`recordUsage` 与本地 insert 分离，离线记录无法补推；服务端 `operator_name` 常为空；家庭贡献排行跨设备不一致。

### 实现方案

#### 客户端

1. **Drift schema v3**：`usage_records.server_record_id` 关联服务端 id
2. **`UsageRecordSyncService` 增强**：
   - `recordAndSync()` — 写本地 + 立即 POST
   - `pushPendingRecords()` — 补推未同步记录
   - `syncBidirectional()` — 先拉后推
   - `syncFromServer()` — 按 `serverRecordId` 去重，旧记录回填 id
3. **`ItemService.createUsageRecord()`** — 支持 type/notes（入库/消耗/丢弃）
4. **统一写入点**：
   - `applyItemUsage` / `recordItemDiscard` → `recordAndSync`
   - `add_item_page` 入库 type=0 + operator
5. **`usage_operator_helper.dart`** — `resolveUsageOperatorName` 抽离
6. **触发同步**：首页动态、家庭贡献 provider、贡献详情页下拉刷新

#### 服务端

- `POST /usage_records`：`operator_name` 为空时用当前用户昵称/手机号
- `GET /usage_records` / POST 响应：增加 `operator_id`
- 创建时 `operator_id=current_user.id`（原有逻辑保留）

### 改动文件

| 区域 | 文件 |
|------|------|
| DB | `app_database.dart` schema v3 + DAO |
| 同步 | `usage_record_sync_service.dart` |
| API | `item_service.dart` |
| 操作人 | `usage_operator_helper.dart` |
| 消耗 | `usage_dialog.dart` |
| 入库 | `add_item_page.dart` |
| 贡献 | `family_contribution_provider.dart`, `family_contribution_page.dart` |
| 首页 | `home_provider.dart` |
| 服务端 | `usage_records.py` |

### 影响范围

- 记消耗、丢弃、添加入库
- 家庭贡献排行/动态
- 首页最近动态
- 需执行 `dart run build_runner build` 生成 Drift v3

---

## 提测开发文档

### 测试点

1. **记消耗**：设备 A 记 1 件 → 设备 B 打开家庭协作 → 排行/动态出现
2. **入库**：添加入库后服务端有 type=0 记录，贡献「录入 +1」
3. **离线补推**：断网记消耗 → 联网 → 打开 Profile 家庭协作 → 记录出现在服务端
4. **operator**：记消耗后 usage_records 含 operator_name（昵称）
5. **DB 迁移**：旧用户升级 app 不丢本地 usage_records

### 验证方式

双设备或一设备 + API 工具：
- POST 记消耗后 GET `/usage_records` 含 operator_id/name
- Profile → 家庭协作 → 下拉刷新

### 注意事项

- 本地 itemId 须与服务端一致（依赖 ItemSyncService）
- 合并排行仍按姓名取 max，operator_id 主要用于服务端贡献 API
