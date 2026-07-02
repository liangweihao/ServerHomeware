# 2026-07-02 优化计划执行 — WebSocket 同步 + UI 组件 + 搜索预填

> 依据：[`20260702_optimization_execution_plan.md`](20260702_optimization_execution_plan.md)

---

## 技术开发文档

### Phase A — WebSocket 实时同步（Epic E2）

| 改动 | 文件 |
|------|------|
| 广播 helper | `HomeWareServer/app/services/realtime_broadcast.py` |
| 物品 CRUD/消耗/移动/丢弃后广播 | `HomeWareServer/app/services/item_service.py` |
| usage 创建后广播 | `HomeWareServer/app/api/v1/usage_records.py` |
| WS URL 构造 | `HomeWareClient/lib/core/config/app_env.dart` |
| 连接/心跳/重连 | `HomeWareClient/lib/core/services/realtime_sync_service.dart` |
| 防抖 sync + EventBus | `HomeWareClient/lib/core/providers/realtime_sync_provider.dart` |
| 登录绑定生命周期 | `HomeWareClient/lib/core/providers/auth_guard.dart` |
| 依赖 | `web_socket_channel: ^3.0.3` |

**事件协议**：
- `items_changed` — `{action, item_id}`
- `usage_changed` — `{item_id}`
- `alerts_changed` — `{}`
- 服务端 `ping` → 客户端 `pong`

### Phase B — UI 组件工具风收尾

| 组件 | 文件 |
|------|------|
| `AppFloatingActionButton` | `app_fab.dart` |
| `AppTabBar` / `AppTabItem` | `app_tab_bar.dart` |
| `AppListEntrance` | `app_list_entrance.dart` |

**迁移页面**：购物清单、位置详情/总览、家庭管理、分类管理、通知中心、使用记录

### Phase C — 搜索/录入闭环

| 改动 | 文件 |
|------|------|
| 空结果携带 query | `search_page.dart` |
| `initialName` 路由参数 | `app_router.dart`, `add_item_page.dart` |

---

## 提测开发文档

### 测试点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 登录后 | 日志 `[RealtimeSync] INFO: 连接`，无 ERROR |
| T2 | 设备 A 记消耗 | 设备 B ≤5s 首页/提醒数据刷新 |
| T3 | 登出 | WebSocket 断开 |
| T4 | 购物清单 | 工具风 Tab + 黄 FAB |
| T5 | 搜「创可贴」无结果 → 手动添加 | 向导 Step2 名称已填 |
| T6 | 切卡通主题 | FAB/Tab/列表入场仍正常 |

### 验证方式

1. 双设备同家庭账号，A 记消耗，B 观察首页分区/提醒 Badge
2. 搜索不存在物品，点「手动添加」核对名称预填
3. 购物清单/位置/家庭页目视检查工具风组件

### 注意事项

- WebSocket 需后端已启动且 token 有效
- 离线设备重连后自动 sync（指数退避，最长 30s）
- OCR/录入方式选择页未纳入本次

---

## 后续

- Epic E4 录入方式选择独立页
- CartoonScaffold 死代码清理
- 自动化 sync 集成测试
