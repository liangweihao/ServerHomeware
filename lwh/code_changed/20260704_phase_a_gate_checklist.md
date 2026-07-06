# Phase A Gate 走查清单定稿

**日期**：2026-07-04  
**状态**：文档已交付，**待人工走查**  
**真源**：[`doc/product/phase-a-gate.md`](../../doc/product/phase-a-gate.md)

---

## 一、交付说明

### 新增

| 路径 | 内容 |
|------|------|
| `doc/product/phase-a-gate.md` | Gate 通过条件、北极星三问、M1～M5 + 管管 + 回归清单、缺陷表、签核 |

### 更新

| 路径 | 变更 |
|------|------|
| `doc/product/current-phase.md` | Gate 章节链接；A1 状态说明 |
| `doc/product/roadmap.md` | M4/M5/Gate 状态同步 |
| `doc/README.md` | 产品路径增加 phase-a-gate |

---

## 二、Gate 怎么跑

1. 按 `phase-a-gate.md` **第四节** 完成环境准备  
2. **第五节 P0** 逐项打勾（建议 1 人操作 + 1 人计时）  
3. P0 bug 记入 **第八节** 表格，清零后再判通过  
4. 填写 **第九节** 结论 + **第十一节** 签核  
5. 通过后观察 **2 周 P0**（G-1 条件）

### 北极星快速测（3 条）

| 问 | 路径 | 限时 |
|----|------|------|
| 在哪 | 问管管 / 搜索 | 10s |
| 剩多少 | 物品详情 / 购物清单现有量 | 10s |
| 要不要处理 | 首页危机 Banner / 管管面板 | 10s |

---

## 三、提测分工建议

| 角色 | 负责块 |
|------|--------|
| 产品 | NS 北极星三问、GG 管管体验、结论签核 |
| 研发 | M1～M5 技术项、自动化命令、P0 修复 |
| 测试 | A5 闭环、回归 R-1～R-7、缺陷记录 |

### 可选自动化（走查前）

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/assistant/ test/core/utils/shopping_stock_helper_test.dart
C:\flutter\bin\flutter.bat analyze 2>&1 | Select-String "error -"  # 应无输出
```

**2026-07-04 执行结果**：单测 **26/26 通过**；analyze **0 error**（修复 `add_item_nl_sheet` 路径、`add_item_page` 引用 `add_item_nl_applier.dart`）。

---

## 四、通过后下一步

| 顺序 | 事项 |
|------|------|
| 1 | 2 周 P0 观察期 |
| 2 | M1 hello 动效（非阻塞增强） |
| 3 | 管管 P2 或 Phase B 立项评审 |

### 不通过

回到对应里程碑修复 → 重跑 `phase-a-gate.md` 第五节 P0。

---

## 五、注意事项

- hello 序列帧 **不阻塞** Gate（M1-8 标 P2/N/A 即可）
- 双设备 WS（R-7）为 P1 可选
- 走查结果请回填 `phase-a-gate.md` 第九、十一节，不必另建表格
