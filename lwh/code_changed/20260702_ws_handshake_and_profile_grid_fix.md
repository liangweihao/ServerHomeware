# WebSocket 握手失败 + Profile 宫格溢出修复

## 问题

1. **WebSocket**：客户端报 `was not upgraded to websocket`，并不断重连，产生 Unhandled Exception
2. **Profile 宫格**：`_FeaturedCell` 内 `Column` 在固定高度 88 下溢出（subtitle 存在时）

## 根因

### WebSocket

- 实测 `http://192.168.1.98:8000/api/v1/ws/notifications` 返回 **404**，说明当前运行中的后端未加载 WS 路由（需重启）
- `BaseHTTPMiddleware`（请求日志 / 响应清理）与 WebSocket 不兼容，即使路由存在也可能导致握手失败
- 客户端在握手完成前就标记 `connected`，且未 `await channel.ready`，异常落入未捕获 Zone

### Profile 宫格

- 大卡固定高 88 + padding 14，`Spacer` + 标题 + 副标题超出可用高度

## 改动

| 文件 | 改动 |
|------|------|
| `HomeWareServer/app/core/middleware.py` | 改为纯 ASGI 中间件，HTTP/WebSocket 分离处理 |
| `HomeWareServer/app/main.py` | 使用 `setup_request_log()` 注册日志中间件 |
| `HomeWareServer/app/api/v1/ws.py` | 修正 DB 会话获取；补充握手/断开日志 |
| `HomeWareClient/.../realtime_sync_service.dart` | `await channel.ready`；握手成功后再订阅；收敛异常与重连 |
| `HomeWareClient/.../profile_quick_action_grid.dart` | 大卡高度 96、spaceBetween 布局、文本 ellipsis |

## 提测

1. **重启后端**（必须）：`uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload`
2. 登录 App，日志应出现 `[RealtimeSync] INFO: 握手成功`，无 Unhandled Exception
3. 后端日志应出现 `WebSocket 握手成功 user_id=... family_id=...`
4. 设备 A 改物品，设备 B ≤5s 自动刷新
5. 打开 Profile 页，「物品」「提醒」大卡无 RenderFlex overflow 黄黑条

## 注意事项

- 若仍 404，确认部署代码含 `ws_router` 且已重启进程
- nginx 反代需配置 `Upgrade` / `Connection` 头（生产环境）
