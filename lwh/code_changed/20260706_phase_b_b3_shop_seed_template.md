# Phase B B3 — 店铺默认分类/位置 seed

**日期**：2026-07-06  
**状态**：B3 已交付（待联调）  
**关联**：[phase-b-milestones.md](../../doc/product/phase-b-milestones.md) · [20260706_phase_b_b2_space_skin_labels.md](./20260706_phase_b_b2_space_skin_labels.md)

---

## 一、实现方案

### 服务端

| 项 | 路径 |
|----|------|
| 模板真源 | `app/core/space_templates.py` |
| 家庭创建 | `family_service.create_family` 按 `space_type` 选位置模板 |
| 店铺分类 | `SHOP_CATEGORY_TEMPLATE` 写入 `categories.family_id` |

**店铺位置**：店面 → A架 / B架 / 冷柜；库房；柜台  

**店铺分类**：烟酒百货、饮料、休闲食品、日用洗护、其他

### 客户端

| 项 | 路径 |
|----|------|
| 模板数据 | `core/config/space_shop_seed_data.dart` |
| seed 逻辑 | `AppDatabase.seedShopPresetIfNeeded()` |
| 触发时机 | `auth_provider.createFamily` 当 `spaceType=shop` |

**B3-2 不覆盖**：仅当本地 **无物品** 且尚无「烟酒百货」分类时，清空并重写分类/位置。

---

## 二、提测

| # | 步骤 | 预期 |
|---|------|------|
| 1 | 新装 App → 注册 → 创建「小店铺」 | 本地分类含「烟酒百货」 |
| 2 | 位置管理 | 可见店面、A架、B架、冷柜、库房、柜台 |
| 3 | 管管面板熟练度 | 默认空间「店面」Lv（B2 已接） |
| 4 | API 创建 shop 家庭 | 服务端位置树为店面/A架… |
| 5 | 已有物品后再建 shop（边界） | 不覆盖本地分类/位置 |

### 自动化

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/config/space_shop_seed_data_test.dart
```

---

## 三、已知限制

- 服务端 `get_categories` 仍会返回全局 system 家庭分类 + 店铺家庭分类（MVP 可接受）
- 加入已有店铺家庭时，本地不会自动换模板（需同步 API 或手动）
- home 空间创建逻辑不变

---

## 四、下一步

- **B4** 管管店铺词表 + 断货危机优先级
