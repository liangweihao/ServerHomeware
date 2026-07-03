# M3 首页场景入口（Phase A）

**日期**：2026-07-03  
**状态**：已实现  
**关联**：[`20260703_product_direction_home_first.md`](./20260703_product_direction_home_first.md) M3

---

## 一、目标

站在厨房/某房间时，**少点 2 次** 即可看到该空间物品 — 不用先滚到底或进全库列表筛。

---

## 二、改动点

| 文件 | 说明 |
|------|------|
| `home_page.dart` | **今日待办 + 分区 Feed + 按空间** 同一 `ListView` 滚动；顶栏固定 |
| `home_space_section.dart` | 点击进 `/locations/:id`；「查看全部」→ `/locations` |
| `home_provider.dart` | `spacesProvider` 按物品数 **从大到小** 排序 |
| ~~`home_scene_chip_bar.dart`~~ | 已移除（与底部「按空间」重复） |

---

## 三、提测

1. 首页顶栏下可见空间 Chip，可横滑  
2. Chip 件数与进入后列表数量一致（含子位置）  
3. 点子位置（如冰箱）仍只看该层逻辑  
4. 无空间数据时 Chip 栏隐藏  

---

## 四、下一步（M4）

购物清单项旁显示 **「家里现有 x」**，减少超市重复购买。
