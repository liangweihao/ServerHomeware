# 产品路线图

> 最后更新：2026-07-04。功能状态以代码与 `doc/core/` 为准。  
> Phase A 方向见 [current-phase.md](current-phase.md)。

---

## 一、MVP（已交付）

### 客户端（HomeWareClient）

| 模块 | 状态 | 说明 |
|------|------|------|
| 认证与引导 | ✅ | Splash → Welcome → 登录/注册 → 创建/加入家庭 |
| 单页首页 | ✅ | 顶栏 + 今日待办 + 分区 Feed + 空间 Chip |
| 物品 CRUD | ✅ | 列表、详情、添加/编辑、图片上传、扫码录入 |
| 提醒中心 | ✅ | 过期 / 库存 / 补购 / 保修 Tab |
| 空间管理 | ✅ | 多级位置、位置详情、位置照片 |
| 购物清单 | ✅ | 待购 / 已购 / 历史 |
| 数据统计 | ✅ | 消费趋势、分类占比、浪费、排行 |
| 搜索 | ✅ | 关键词搜索 + 历史 |
| 个人中心 | ✅ | 资料编辑、分类/成员、导出、提醒设置 |
| 用户面板 | ✅ | 切换家庭、贡献度、邀请码 |
| 通知中心 | ✅ | `/notifications` + 未读 Badge |
| 问管家 Phase 1 | ✅ | 本地规则引擎，5 类查询意图 |
| 一键消耗 | ✅ | 物品详情 + QuickConsumeSheet |
| 本地缓存 | ✅ | Drift SQLite + 全量同步 |
| WebSocket 实时 | ✅ | 多设备 800ms 防抖同步 |

### 服务端（HomeWareServer）

| 模块 | 状态 | 说明 |
|------|------|------|
| 认证 JWT | ✅ | 注册 / 登录 / 刷新 / 登出 |
| 家庭协作 | ✅ | 创建、加入、切换、成员与角色 |
| 物品 / 分类 / 位置 | ✅ | CRUD + 树形结构 |
| 使用记录 | ✅ | 按物品或全家庭分页 |
| 提醒与通知 | ✅ | 提醒 API + Celery 定时任务 |
| 购物清单 / 统计 | ✅ | 清单 CRUD、统计概览 |
| 文件上传 | ✅ | 单张/批量图片，WebP 存储 |
| 条码查询 | ✅ | 接口已提供 |
| 数据导出 | ✅ | CSV / JSON |
| 增量同步 API | ✅ | `/sync/changes`、`/sync/push`（客户端未接） |
| WebSocket | ✅ | 实时推送通道 |
| 部署 | ✅ | Docker Compose（开发 / 生产） |

---

## 二、Phase A 进行中（2026 Q3）

详见 [current-phase.md](current-phase.md)。

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M1 问管管 | 查询 + 首页入口 + hello 动效 | 🟡 Phase 1 规则引擎已上线 |
| M2 一键消耗 | 物品详情「用了 1」 | ✅ |
| M3 场景入口 | 首页空间 Chip | ✅ |
| M4 清单+库存 | 购物清单显示现有量 | ❌ |
| M5 录入减负 | NL 规则预填 | ❌ |

---

## 三、已知差距

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 增量 sync 客户端接入 | 服务端 `/sync/changes` 已有 | P2 |
| 验证码/SMS 登录 | 当前 Mock（123456） | P2 |
| 问管家写操作 | 添加入库、记消耗 | P1（M1 后续） |
| 盘点任务 | Profile 菜单占位 | P2 |
| 操作系统 Push | FCM/APNs | P3 |

---

## 四、下一阶段 Epic

### Epic E1：首页通知与提醒统一 — ✅ 已完成

通知中心 `/notifications` 已上线，Badge 与提醒数据一致。

PRD：[prd/PRD-home-notification-center.md](prd/PRD-home-notification-center.md)

### Epic E2：提醒实时同步 — ✅ 基本完成

WebSocket 推送 → 客户端防抖 sync → Badge 刷新。FCM/APNs 仍 Out of Scope。

### Epic E3：盘点任务（轻量）

按空间生成待核对清单，逐项确认/修正/跳过。

### Epic E4：录入增强

方式选择页 ✅ 已上线；OCR / 语音为子 Epic。

**建议排期**：

```
2026 Q3  M4 清单+库存 → M5 NL 预填
2026 Q4  E3 盘点任务 → E4 OCR 评审
2027 H1  问管家 LLM 增强
```

---

## 五、阶段 3 规划（AI 增强）

详见 [`roadmap/ai-mode/README.md`](../roadmap/ai-mode/README.md)。

| 阶段 | 内容 | 状态 |
|------|------|------|
| 问管家 Phase 1 | 本地规则查询 | ✅ 已交付 |
| AI-1 云端对话 | `/api/v1/chat`、意图引擎 | ❌ 未开始 |
| AI-2 语音 + 对话 UI | STT、会话页增强 | ❌ 未开始 |
| AI-3 智能增强 | 模糊匹配、主动提醒 | ❌ 未开始 |
| OCR / 小票识别 | 拍照自动填表 | ❌ 未开始 |
| 电商订单同步 | 淘宝 / 京东 / 美团 | ❌ 未开始 |

---

## 六、演进阶段

```
阶段 1  MVP 手动录入 + 位置 + 过期提醒     → ✅ 已完成
阶段 2  扫码 + 统计 + 家庭共享 + WS 同步    → ✅ 已完成
阶段 2.5 Phase A 问管家 + 一键消耗 + 场景   → 🟡 进行中（M4/M5 待做）
阶段 3  AI 增强 + OCR + 智能补购           → 规划中
阶段 4  IoT / 开放生态 / Phase B 店铺皮肤   → 远期
```

---

## 七、Out of Scope

- 5 Tab / 4 Tab 底部导航（已改为单页首页）
- Clean Architecture 全量重构
- 站外消息推送、短信提醒
- IoT / 智能冰箱联动
- 店铺皮肤（Phase B，见 current-phase.md）

---

## 八、文档约定

| 类型 | 路径 |
|------|------|
| 核心逻辑 | `doc/core/` |
| Phase A 方向 | `doc/product/current-phase.md` |
| 功能 PRD | `doc/product/prd/PRD-{feature}.md` |
| 变更记录 | `lwh/code_changed/` |
