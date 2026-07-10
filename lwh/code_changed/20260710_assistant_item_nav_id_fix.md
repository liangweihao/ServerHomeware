# 问管管物品卡片跳转 id=1 找不到 — 修复

## 问题

日志：`[AssistantItemResolver] INFO: navId=1` → `[ItemDetailProvider] WARN: 物品不存在 id=1`

服务端返回 `item_id=1`（服务端主键），被误当作本地 Drift id；本地无 id=1 记录时跳转失败。

## 修复

1. **`AssistantItemSummary`** 拆分 `itemId`（本地）与 `serverItemId`（服务端）
2. **`parseFromApi`** 不再把 server id 填进 itemId
3. **`AssistantItemResolver.resolveNavId`**：
   - 校验本地 id 真实存在
   - 名称精确/模糊匹配
   - 按 serverItemId 映射
   - 本地无记录时 `ItemSyncService.ensureLocalByServerId` 拉取详情入库
4. **`ItemSyncService.ensureLocalByServerId`** 问管管专用单条同步
5. **`AssistantItemResultList`** 点击时再次 resolve + 失败 SnackBar

## 提测

1. 热重载，问管管出现「十斤羊肉」卡片
2. 点击 → 日志 `[ItemSync] INFO: 问管管拉取物品入库` 或 `[AssistantItemResolver] navId=...`
3. 正常进入物品详情页

## 注意

- 若物品在 `ItemDeletedRegistry` 已登记删除，不会恢复
- 服务端也无该物品时提示「找不到，请先在物品页同步库存」
