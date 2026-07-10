# 今日任务显示已删物品修复

## 问题

用户已删除的物品仍出现在「管管今日面板 → 今日任务」。

## 根因

1. **删除未等待服务端**：`ItemService().deleteItem()` 未 `await`，服务端可能未删
2. **同步恢复已删物品**：首页/列表触发 `ItemSyncService.syncFromServer()`，从服务端重新插入本地已删物品
3. **今日任务**来自 `status==0` 的本地物品，被 sync 恢复后再次出现

## 方案

| 改动 | 说明 |
|---|---|
| `item_deleted_registry.dart` | **新增** SharedPreferences 登记已删 serverItemId |
| `item_detail_page.dart` | await 服务端删除 + 登记 + `invalidate(guanguanPanelProvider)` |
| `item_sync_service.dart` | 跳过已登记 ID；清理服务端已删的本地副本 |

## 提测

| 步骤 | 预期 |
|---|---|
| 删除临期/低库存物品 | 今日任务立即消失 |
| 返回首页再进 | 不再出现 |
| 下拉刷新触发 sync | 不再恢复 |

### 日志

```
[ItemDetailPage] INFO: 服务端删除成功 id=...
[ItemDeletedRegistry] INFO: 登记已删 serverId=...
[ItemSync] INFO: 清理已删物品残留 id=...
```
