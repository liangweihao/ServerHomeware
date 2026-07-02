# WebSocket 握手失败根因修复 — 缺少 websockets 依赖

## 根因（已确认）

服务端日志：

```
WARNING: No supported WebSocket library detected.
Please use "pip install 'uvicorn[standard]'", or install 'websockets' or 'wsproto' manually.
```

`requirements.txt` 仅安装了 `uvicorn==0.28.0`（无 `[standard]`），**未安装 `websockets`**。  
uvicorn 无法处理 WebSocket 升级，所有 WS 请求返回 404 / `was not upgraded to websocket`。

## 改动

| 文件 | 改动 |
|------|------|
| `requirements.txt` | `uvicorn==0.28.0` → `uvicorn[standard]==0.28.0` |
| `realtime_sync_service.dart` | 使用 `WebSocket.connect` 握手，异常收敛到 try/catch |
| `profile_quick_action_grid.dart` | 大卡固定高 100，消除 Column 溢出 |

## 部署步骤（必须）

```bash
cd HomeWareServer
./start.sh prod restart
# 或
./start-prod.sh restart
```

脚本会 `pip install -r requirements.txt`，自动装上 websockets。

## 验证

1. 服务端日志出现 `WebSocket /api/v1/ws/notifications`（不再是 404）
2. 客户端日志 `[RealtimeSync] INFO: 握手成功`
3. 若仍 403：说明 token 与当前环境 JWT 密钥不一致，**重新登录**即可
   - dev 密钥：`.env.dev`
   - prod 密钥：`.env.production`（与 dev 不同）

## 提测

- [ ] `./start-prod.sh restart` 后 curl WS 不再 404
- [ ] App 重新登录后 WS 连接成功
- [ ] Profile 页无 RenderFlex overflow
- [ ] 双设备物品变更自动同步
