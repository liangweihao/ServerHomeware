# API 参考索引

> 前缀：`/api/v1`。完整 Schema 以运行中服务的 **OpenAPI** 为准：`http://localhost:8000/docs`  
> 近期字段变更见 [`lwh/code_changed/20260604_api_sync_docs.md`](../../lwh/code_changed/20260604_api_sync_docs.md)。

---

## 认证 ` /auth`

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/register` | 用户注册 |
| POST | `/login` | 登录，返回 access/refresh token |
| POST | `/refresh` | 刷新 Token |
| POST | `/logout` | 登出 |

---

## 用户 ` /users`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/me` | 当前用户信息 |
| PUT | `/me` | 更新资料（含 `family_nickname`） |
| PUT | `/me/password` | 修改密码 |
| DELETE | `/me` | 注销账户 |
| GET | `/me/notification-preferences` | 通知偏好 |
| PUT | `/me/notification-preferences` | 更新通知偏好 |
| GET | `/{user_id}` | 指定用户信息 |

---

## 家庭 ` /families`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `` | 用户所属家庭列表 |
| POST | `` | 创建家庭 |
| POST | `/join` | 邀请码加入 |
| GET | `/current` | 当前家庭详情 |
| POST | `/current/refresh-invite-code` | 刷新邀请码 |
| POST | `/{family_id}/switch` | 切换当前家庭 |
| POST | `/{family_id}/leave` | 离开家庭 |
| PUT | `/{family_id}` | 更新家庭信息 |
| DELETE | `/{family_id}` | 删除家庭 |
| GET | `/{family_id}/members` | 成员列表 |
| PUT | `/{family_id}/members/{user_id}` | 更新成员角色 |
| DELETE | `/{family_id}/members/{member_id}` | 移除成员 |
| POST | `/{family_id}/transfer-ownership` | 转让所有权 |

---

## 物品 ` /items`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `` | 分页列表（含 `preview_image`） |
| POST | `` | 创建物品 |
| GET | `/{item_id}` | 详情 |
| PUT | `/{item_id}` | 更新 |
| DELETE | `/{item_id}` | 删除（含磁盘图片清理） |
| POST | `/{item_id}/use` | 记录使用 |
| POST | `/{item_id}/finish` | 标记用完 |
| POST | `/{item_id}/discard` | 标记丢弃 |
| POST | `/{item_id}/move` | 移动位置 |
| GET | `/barcode/{barcode}` | 按条码查物品 |
| GET | `/{item_id}/prediction` | 消耗预测 |

---

## 分类 ` /categories` · 位置 ` /locations`

标准树形 CRUD：`GET` 列表、`GET /{id}`、`POST`、`PUT /{id}`、`DELETE /{id}`。

---

## 使用记录 ` /usage-records`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `` | 按 `item_id` 或全家庭分页（含 `item_name`） |
| POST | `` | 创建记录 |
| DELETE | `/{record_id}` | 删除 |

---

## 购物清单 ` /shopping`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `` | 清单列表 |
| POST | `` | 添加项 |
| PUT | `/{item_id}` | 更新 |
| PUT | `/{item_id}/purchase` | 标记已购 |
| PUT | `/purchase-all` | 全部已购 |
| POST | `/{item_id}/to-item` | 一键入库 |
| DELETE | `/{item_id}` | 删除 |
| GET | `/share-text` | 分享文本 |
| GET | `/recommendations` | 推荐 |

---

## 提醒 ` /alerts`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `` | 提醒列表 |
| GET | `/summary` | 统计摘要 |
| POST | `/{alert_id}/read` | 标记已读 |
| GET | `/expiring` | 即将过期 |
| GET | `/low-stock` | 库存不足 |

---

## 统计 ` /statistics`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/overview` | 概览 |
| GET | `/expense-trend` | 消费趋势 |
| GET | `/category-breakdown` | 分类占比 |
| GET | `/waste` | 浪费统计 |
| GET | `/consumption-ranking` | 消耗排行 |

---

## 上传 ` /upload`

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/image` | 单张上传 |
| POST | `/images` | 批量上传 |
| DELETE | `/image` | 删除图片 |

---

## 同步 ` /sync`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/changes` | 增量变更拉取 |
| POST | `/push` | 批量推送变更 |

---

## 其他

| 模块 | 前缀 | 要点 |
|------|------|------|
| activities | `/activities` | 家庭动态、`/recent` |
| contributions | `/contributions` | 用户贡献度 |
| notifications | `/notifications` | 站内通知、未读数 |
| devices | `/devices` | 推送设备注册 |
| export | `/export` | CSV/JSON 导出与下载 |
| barcode | `/barcode` | 公共条码库查询 |
| health | `/health` | 健康 / 就绪检查 |
| ws | `/ws` | WebSocket 连接 |

---

## 鉴权说明

除 `/auth/*`、`/health`、`/barcode/{code}` 等公开接口外，请求头需携带：

```
Authorization: Bearer <access_token>
```

家庭维度接口依赖用户「当前家庭」上下文（切换家庭后 Token 内 family 更新）。
