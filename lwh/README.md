# lwh 知识库索引

> Agent 与开发者检索上下文时的入口。  
> **现行真源**：`doc/core/`（系统逻辑 + 模块专题）+ `doc/`（产品/设计/架构）。

---

## 目录结构

```
lwh/
├── README.md              ← 本文件
├── code_changed/          活跃变更记录（2026-06-30 及以后）
└── archive/
    └── code_changed/      历史记录（6 月前 + 已整合的执行计划/主题实验）
```

**当前规模**（2026-07-04）：活跃 ~34 份，归档 ~73 份。

---

## 模块专题（推荐先读）

| 模块 | 文档 |
|------|------|
| 同步与实时 | [`doc/core/modules/sync-and-realtime.md`](../doc/core/modules/sync-and-realtime.md) |
| 问管家 | [`doc/core/modules/assistant-guanguan.md`](../doc/core/modules/assistant-guanguan.md) |
| 物品录入与消耗 | [`doc/core/modules/items-entry-and-consume.md`](../doc/core/modules/items-entry-and-consume.md) |
| 认证与家庭 | [`doc/core/modules/auth-and-family.md`](../doc/core/modules/auth-and-family.md) |
| UI 与首页 | [`doc/core/modules/ui-and-home.md`](../doc/core/modules/ui-and-home.md) |
| **UI/Icon 全局审计** | [`ui_icon_style_audit.md`](ui_icon_style_audit.md) ← 替换清单与批次 |

---

## code_changed 活跃记录（2026-07）

| 文件 | 内容 |
|------|------|
| `20260703_m2_quick_consume.md` | M2 一键消耗 |
| `20260703_m3_home_scene_chips.md` | M3 首页空间 Chip |
| `20260703_ai_mascot_character_design.md` | 管管 IP 设计 |
| `20260702_ai_assistant_phase1_impl.md` | 问管家 Phase 1 |
| `20260702_ui_system_unification.md` | UI 体系统一 |
| `20260702_phase_d_consumption_sync_impl.md` | 消耗预测 sync |
| `20260701_p_item_id_mapping.md` | serverItemId 映射 |
| `20260630_home_single_page_sections.md` | 单页首页分区 |

---

## 归档规则

| 条件 | 处理 |
|------|------|
| 日期 < 20260601（6 月前） | 移入 `archive/code_changed/` |
| 20260601~20260625 早期实现 | 整合进 `doc/core/modules/` 后归档 |
| 执行计划 / 验收清单 / 主题实验 | 交付完成后归档 |
| 与 `doc/` 重复的规格 | 归档 |

保留在 `code_changed/`：**2026-06-30 及以后**的功能实现、Bug 修复、架构决策。

---

## 检索建议

1. 了解某模块怎么工作 → `doc/core/modules/{模块}.md`
2. 查某次具体改动细节 → 模块文档「历史变更索引」→ 对应 md 文件
3. 查废弃方案原因 → `lwh/archive/code_changed/`
