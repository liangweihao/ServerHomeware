# E2 WebSocket 双设备验证清单

> 前置：Phase A 已落地（`realtime_sync_service.dart` + 后端广播）

---

## 环境

| 项 | 要求 |
|----|------|
| 后端 | `http://localhost:8000` 或设备可达 API |
| 账号 | 两设备登录**同一家庭** |
| 客户端 | 热重启（非仅热重载） |

---

## 验证步骤

| # | 操作 | 预期 | 通过 |
|---|------|------|------|
| 1 | 设备 A 登录 | 日志 `[RealtimeSync] INFO: 连接` | ☐ |
| 2 | 设备 B 登录 | 同上 | ☐ |
| 3 | A 记消耗 1 件 | A 成功，首页/提醒更新 | ☐ |
| 4 | B **不操作**，等待 ≤5s | B 首页分区/Badge 自动刷新 | ☐ |
| 5 | B 下拉 Profile 家庭协作 | 可见 A 的操作动态 | ☐ |
| 6 | A 登出 | 日志 `[RealtimeSync] INFO: 已断开` | ☐ |
| 7 | A 断网记消耗 → 联网 | 离线记录补推，B 刷新后可见 | ☐ |

---

## 失败排查

1. 检查 `env.local.json` API 地址是否含 `/api/v1`
2. WebSocket URL 应为 `ws://host:port/api/v1/ws/notifications?token=...`
3. 后端日志应有 `WebSocket 广播 event=items_changed`
4. 防火墙是否拦截 WebSocket
