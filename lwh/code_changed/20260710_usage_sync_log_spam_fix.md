# Usage 同步日志刷屏修复

## 问题

服务端 item_id=1 有多条 usage，本地无映射时，每条记录都打：
- `[ItemIdMap] WARN: 未找到 serverItemId=1`
- `[UsageRecordSync] WARN: 跳过无本地映射 usage serverItemId=1`

## 修复

1. **`app_database.resolveLocalItemId`**：同一 serverItemId 进程内只 WARN 一次
2. **`usage_record_sync_service`**：映射失败前先 `ensureLocalByServerId` 拉取物品；汇总 `countByServerItemId` 一条 WARN
3. **`realtime_sync_provider`**：去掉重复的 `syncFromServer`（`syncBidirectional` 已包含）

## 提测

热重载后触发同步，同 id 不应再刷屏；若物品可恢复应自动入库并同步 usage。

## 仍可能 WARN 一次的情况

- 物品在 `ItemDeletedRegistry` 已登记删除
- 服务端也无该物品
