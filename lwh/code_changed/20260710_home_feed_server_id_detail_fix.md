# 首页 Feed 点击「物品不存在」— 服务端 id vs 本地 id

## 问题

首页「全部」从 **服务端 API** 拉列表，`HomeSectionItem.id` = 服务端 `items.id`（如 1）。  
点击 Feed 卡跳转 `/items/1`，详情页只用 **本地 Drift** `getItemById(1)` → 找不到（本地无记录或 id 不同）。

## 修复

新增 `ItemRouteResolver.resolveLocalId`：
1. 本地 id 直查
2. `serverItemId` 映射
3. 按服务端 id 拉取入库（含已删登记解除）

`itemDetailProvider` 入口统一走解析，后续用 `localId` 读 usage 等。

## 提测

Hot Restart 后从首页「全部」点「十斤羊肉」：
- 日志 `[ItemRouteResolver] INFO: 拉取入库 serverId=1 → localId=...`
- 详情页正常展示

## 说明

首页仍显示服务端有的物品；本地删过但云端仍在时，**打开详情会自动恢复**（与问管管卡片一致）。
