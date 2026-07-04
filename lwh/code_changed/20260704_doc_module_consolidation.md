# 模块专题文档 + 6 月前历史归档

**日期**：2026-07-04  
**状态**：已完成  
**关联**：[`20260704_doc_consolidation.md`](./20260704_doc_consolidation.md)

---

## 一、技术开发说明

### 背景

首轮文档整合后 `lwh/code_changed/` 仍保留 63 份记录，其中 5 月及早期 6 月实现已稳定且分散，不便检索。

### 方案

1. **新建 `doc/core/modules/`** — 5 个业务域专题文档 + 索引
2. **归档 6 月前及早期 6 月记录** — 30 份移入 `lwh/archive/code_changed/`
3. **活跃区保留** — 2026-06-30 及以后（34 份）

### 新增模块文档

| 路径 | 覆盖 |
|------|------|
| `doc/core/modules/sync-and-realtime.md` | ItemSync、UsageSync、WS、ID 映射 |
| `doc/core/modules/assistant-guanguan.md` | 问管家、管管 IP |
| `doc/core/modules/items-entry-and-consume.md` | 向导、扫码、消耗、提醒闭环 |
| `doc/core/modules/auth-and-family.md` | 认证、家庭、贡献度 |
| `doc/core/modules/ui-and-home.md` | utilityClean、单页首页、M3 Chip |
| `doc/core/modules/README.md` | 模块索引 |

### 归档文件（30 份）

- **202605\***（5 月，16 份）：认证、用户面板、物品详情、图片上传、ItemEventBus 等
- **20260601~20260625**（14 份）：API sync 文档、通知中心 impl、主题切换、列表分页等

### 活跃 code_changed 保留（34 份）

- `20260630_home_single_page_sections.md` — 单页首页架构转折点
- 全部 `20260701_*`、`20260702_*`、`20260703_*`、`20260704_*`

### 更新文档

- `doc/README.md` — 增加 modules/ 目录
- `lwh/README.md` — 模块索引、归档规则、规模统计
- `lwh/archive/README.md` — 补充 6 月前归档说明

---

## 二、提测说明

| 项 | 验证方式 |
|----|----------|
| 模块文档链接 | 打开 `doc/core/modules/README.md` 逐一点击 |
| 归档数量 | `lwh/archive/code_changed/` 累计 ~73 份；活跃 34 份 |
| 模块与代码一致 | 对照 `item_sync_service.dart`、`assistant/`、`home_page.dart` |
| 历史索引 | 各模块文档末尾「历史变更索引」路径可访问 |

### 注意事项

- 模块文档为**摘要真源**，细节仍以归档 md 为准
- 新功能交付：先更新对应模块文档摘要，再写 `lwh/code_changed/`
