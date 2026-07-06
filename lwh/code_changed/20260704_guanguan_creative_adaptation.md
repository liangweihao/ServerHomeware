# 管管创意借鉴落地 — 管家面板 PRD + P0 实现

**日期**：2026-07-04  
**状态**：P0 已落地；P1 待 M4 后启动  
**灵感**：《菜鸟炊事兵》底层岗位 + 可视成长 + 单元危机闭环  
**PRD**：[`doc/product/guanguan-butler-panel-prd.md`](../../doc/product/guanguan-butler-panel-prd.md)

---

## 一、技术开发说明

### 1.1 交付内容（按 1→2→3 顺序）

| 顺序 | 交付物 | 路径 |
|------|--------|------|
| 1 | 《管管管家面板 PRD》 | `doc/product/guanguan-butler-panel-prd.md` |
| 2 | P0 话术库 + 提醒闭环微动效 | 见下方改动清单 |
| 3 | 「每日一危机」用户流程图 | PRD 第六节 Mermaid |

### 1.2 P0 代码改动

| 文件 | 变更 |
|------|------|
| `core/assistant/guanguan_copy.dart` | **新增** — 管管话术唯一真源 |
| `core/assistant/daily_crisis_helper.dart` | **新增** — 主危机解析（过期>临期>低库存） |
| `presentation/common/widgets/guanguan_celebration_snackbar.dart` | **新增** — 处理庆祝 SnackBar + 图标微弹跳 |
| `core/assistant/assistant_executor.dart` | 全部用户可见文案改走 `GuanguanCopy` |
| `presentation/assistant/assistant_chat_page.dart` | 标题「问管管」、欢迎语、错误文案 |
| `presentation/home/widgets/today_summary_banner.dart` | 每日一危机单主标题 + 火焰图标轻脉冲 |
| `presentation/items/widgets/quick_consume_button.dart` | 消耗完成 → 庆祝 SnackBar |
| `presentation/alerts/alert_center_page.dart` | 用了/丢弃/加清单 → 庆祝 SnackBar |
| `test/core/assistant/daily_crisis_helper_test.dart` | **新增** — 主危机优先级单测 |

### 1.3 每日一危机规则

```
已过期 > 临期（7 天内）> 低库存
```

- 主标题示例：`管管提醒：「牛奶」快过期了`
- 副标题：`还有 N 件待处理 · 先搞定这一件？`
- 主危机 Chip 高亮（先处理过期/临期/补货）

### 1.4 P1 预留（未实现）

- 首页可折叠「管管今日面板」
- 空间熟练度 Lv
- 成员协作态一句话
- 每日结算卡

**门禁**：M4（清单带库存）ship 后启动 P1-A。

### 1.5 影响范围

- 客户端文案与首页 Banner 交互；无后端 / DB 迁移
- 问管家查询结果语义不变，仅语气调整
- 与 `doc/core/modules/assistant-guanguan.md` 互补，后续应补充话术库引用

---

## 二、提测说明

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 有 1 过期 + 2 临期 | Banner 主标题指向过期物品名 |
| T2 | 仅低库存 | 主标题「快见底了」 |
| T3 | 问管管「什么快过期」 | 管管语气回复，数据与提醒 Tab 一致 |
| T4 | 提醒中心点「用了 1」 | 浮动深色庆祝 SnackBar，带管管署名 |
| T5 | 物品详情一键消耗 | 同上 |
| T6 | 丢弃 / 加购物清单 | 对应庆祝文案 |
| T7 | 无待处理 | Banner 不显示 |
| T8 | 系统「减少动态效果」 | Banner 无脉冲；SnackBar 图标不弹跳 |
| T9 | `daily_crisis_helper_test` | 5 个用例全绿 |

### 注意事项

- 庆祝 SnackBar 会 `hideCurrentSnackBar`，避免堆叠
- 话术新增/修改须只改 `guanguan_copy.dart`
- P1 面板勿在 M4 前开工，避免分散 Phase A 精力

---

## 三、与编剧创意的映射（备忘）

| 剧元素 | HomeStock 落地 |
|--------|----------------|
| RPG 厨神面板 | P1 管管今日面板 |
| 单元食堂危机 | P0 每日一危机 Banner |
| 好感度透视 | P1 成员协作态 |
| 美食治愈反馈 | P0 庆祝 SnackBar |
| 反差喜剧 | 管管话术库语气 |
