# 模块专题索引

> 按业务域拆分的实现真源，整合 `lwh/code_changed/` 历史记录。  
> 总览见 [system-overview.md](../system-overview.md)，流程图见 [business-flows.md](../business-flows.md)。

---

| 模块 | 文档 | 覆盖范围 |
|------|------|----------|
| 同步与实时 | [sync-and-realtime.md](sync-and-realtime.md) | ItemSync、UsageSync、WebSocket、ID 映射 |
| 问管家 | [assistant-guanguan.md](assistant-guanguan.md) | 规则引擎、管管 IP、M1 |
| 物品录入与消耗 | [items-entry-and-consume.md](items-entry-and-consume.md) | 向导、扫码、一键消耗、提醒闭环 |
| 认证与家庭 | [auth-and-family.md](auth-and-family.md) | 登录、家庭、贡献度 |
| UI 与首页 | [ui-and-home.md](ui-and-home.md) | utilityClean、单页首页、空间 Chip |

---

## 使用方式

1. **开发某模块前** → 读对应模块文档 + `business-flows.md` 相关章节
2. **查某次具体改动** → 模块文档末尾「历史变更索引」→ `lwh/code_changed/` 或 `lwh/archive/`
3. **新功能交付后** → 更新模块文档摘要 + 写 `lwh/code_changed/` 变更记录
