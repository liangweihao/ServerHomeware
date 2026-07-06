# Phase B 里程碑拆解

> **真源 PRD**：[phase-b-shop-skin-prd.md](phase-b-shop-skin-prd.md)  
> **Gate**：[phase-b-gate.md](phase-b-gate.md)  
> **状态**：2026-07-06 — B1～B4 ✅，Gate **暂定通过**

---

## 总览

| 里程碑 | 名称 | 依赖 | 状态 |
|--------|------|------|------|
| **B1** | 空间类型 + Onboarding | Phase A Gate（建议） | ✅ |
| **B2** | 文案皮肤层 | B1 | ✅ |
| **B3** | 店铺默认模板 | B1 | ✅ |
| **B4** | 管管 + 提醒口径 | B2, B3 | ✅ |
| **Gate** | Phase B 小店北极星走查 | B1～B4 | 🟢 暂定通过 |
| **B+** | 售价 / 日销 / CSV 等 | Gate | ⬜ 待排期 |

---

## B1 — 空间类型 + Onboarding

### 目标

用户创建空间时选择 **家庭** 或 **小店铺**，数据写入 `Family.space_type`。

### 服务端

| # | 任务 | 文件/位置 |
|---|------|-----------|
| B1-S1 | Alembic：`families.space_type` default `home` | `HomeWareServer/alembic/` |
| B1-S2 | Model + Schema 暴露 `space_type` | `models/family.py`, `schemas/family.py` |
| B1-S3 | 创建家庭 API 接收 `space_type` | `api/v1/families`, `family_service.py` |
| B1-S4 | 当前家庭响应含 `space_type` | `GET /families/current` |

### 客户端

| # | 任务 | 文件/位置 |
|---|------|-----------|
| B1-C1 | Family 模型增 `spaceType` | `core/services/family_service.dart` |
| B1-C2 | 家庭创建页二选一 UI | `presentation/auth/` 或 `family_setup` |
| B1-C3 | 本地 Drift 缓存 space_type（可选） | `family_members` 或 prefs |
| B1-C4 | `spaceSkinProvider` 读取当前 type | `core/providers/space_skin_provider.dart` |

### 验收

- [ ] 新建店铺空间 API 返回 `space_type=shop`
- [ ] 旧用户默认 `home`，无回归
- [ ] 客户端能读到 type 并打日志

---

## B2 — 文案皮肤层

### 目标

UI 全局 Label 不再硬编码家庭用语；`shop` 显示店铺文案。

### 核心交付

| # | 任务 | 说明 |
|---|------|------|
| B2-1 | `SpaceSkinConfig` | home/shop 两套 copy map |
| B2-2 | 首页 / 顶栏 / Tab | orgLabel、搜索 hint |
| B2-3 | 物品详情 | `consumeLabel`：用了 1 → 卖出 1 |
| B2-4 | 购物清单页 | 标题 → 采购清单 |
| B2-5 | 提醒中心 | Tab 文案、空态 |
| B2-6 | 管管 P1 面板 / P2 周报 | 后厨档口叙事 |
| B2-7 | 庆祝 SnackBar | `GuanguanCopy` 按 skin 分支 |
| B2-8 | grep 审计 | 清除关键路径「家庭」「厨房」硬编码 |

### 验收

- [ ] `space_type=shop` 全流程无「家庭」字样（Gate SB-4）
- [ ] `space_type=home` 与 Phase A 截图对比无 diff

---

## B3 — 店铺默认模板

### 目标

`shop` 空间首次 seed 店铺分类与位置树。

### 预设草案

**分类（Top）**：烟酒百货、饮料、休闲食品、日用洗护、其他  

**位置（Level 1）**：店面、库房、柜台  

**位置（Level 2 示例）**：店面 → A架 / B架 / 冷柜  

| # | 任务 |
|---|------|
| B3-1 | `AppDatabase.seedData()` 分支 `shop` |
| B3-2 | 仅新租户 seed，不覆盖已有数据 |
| B3-3 | 管管 `defaultSpaceName` = 店面 |

### 验收

- [ ] 新店铺空间打开位置管理可见店面/A架
- [ ] 新店铺分类含「烟酒百货」

---

## B4 — 管管 + 提醒口径

### 目标

店铺 persona 下问管管与首页危机符合小店主心智。

### 管管

| # | 任务 |
|---|------|
| B4-1 | `AssistantParser`：卖出/断货/货架 utterance |
| B4-2 | `GuanguanCopy` shop 欢迎语 + suggestions |
| B4-3 | NL 进货：「进了10箱可乐」→ M5 预填 |
| B4-4 | 单测 ≥6 条店铺 parse case |

### 提醒 / 危机

| # | 任务 |
|---|------|
| B4-5 | `DailyCrisisHelper`：`SpaceCrisisPriority` shop 低库存优先 |
| B4-6 | `TodaySummaryBanner` shop headline 文案 |
| B4-7 | 提醒中心默认 Tab shop 可偏 stock |

### 验收

- [x] Gate SB-1～SB-3 走查通过（暂定通过 2026-07-06）
- [x] 家庭 crisis 优先级不变

---

## Phase B Gate 清单（草案）

| ID | 操作 | 预期 |
|----|------|------|
| SB-1 | 问管管「XX在哪」 | 货架路径 + 数量 ≤10s |
| SB-2 | 详情 / 采购清单 | 现有量清晰 ≤10s |
| SB-3 | 冷启动首页 | 断货危机明确 ≤10s |
| SB-4 | 全 App 浏览 | 无家庭用语泄漏 |
| SB-5 | 切换 home 测试账号 | Phase A 回归通过 |

---

## B+  backlog（立项不排期）

| 能力 | 说明 |
|------|------|
| `sale_price` | 售价字段 + 详情展示 |
| 简易日销 | 7 日卖出次数统计 |
| CSV 导入 | 批量进货 |
| 供应商 | 物品扩展字段 |
| 供应商 | 物品扩展字段 |
| 店员角色 | 只读 / 录入 / 老板 — ✅ 见 [phase-b-staff-role-prd.md](phase-b-staff-role-prd.md) |

---

## 建议执行顺序

```
Week 1   B1 评审 + 后端字段 + 创建页分叉
Week 2   B2 皮肤层（并行 B3 seed）
Week 3   B4 管管 + 危机
Week 4   Phase B Gate + 3 店主走查
```

与 **Phase A Gate 2 周 P0 观察** 并行：Week 1 仅文档/评审，Week 2 起编码 B1。
