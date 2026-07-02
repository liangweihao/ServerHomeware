# 吸引力优化：扫码预填 + 今日摘要强化

> 日期：2026-07-01  
> 依据：产品吸引力分析 — 闲鱼极简录入 + 书旗今日摘要

---

## 一、扫码预填（闲鱼向 · 10 秒录入）

### 流程

```
扫码 → /items/add?barcode=xxx
  → 本地条码命中？→ 弹窗：查看 / 再记一件
  → 服务端 /barcode/{code}
  → Open Food Facts（食品公开库）
  → 预填名称/品牌/图/分类 → 跳到「位置」步
```

### 新增/改动

| 文件 | 说明 |
|------|------|
| `barcode_service.dart` | 服务端 + OFF 综合查询 |
| `add_item_page.dart` | 接收 `initialBarcode`，查询与预填 |
| `item_form_controller.dart` | `barcode` 字段写入 API |
| `add_item_wizard_view.dart` | 基本信息步展示条码 Chip |
| `app_router.dart` | add 路由传 query |

### 验收

| 场景 | 预期 |
|------|------|
| 扫食品条码 | 名称/品牌预填，直达位置步 |
| 家里已有同款 | 弹窗选查看或再记一件 |
| 未识别条码 | 提示手动填写，保留条码 |
| 保存 | 请求体含 `barcode` |

---

## 二、今日摘要强化（书旗 + 点评快捷入口）

### 改动

| 文件 | 说明 |
|------|------|
| `home_provider.dart` | 区分 `expiredCount` / `expiringCount` |
| `today_summary_banner.dart` | 替代简单摘要：标题 + 示例 + Chip 快捷跳转 |
| `home_page.dart` | 使用新 Banner |

### 展示逻辑

- 有已过期 / 临期 / 低库存时显示白卡片摘要
- Chip：`已过期` → `/home/section/expired`，`临期` → `expiring`，`低库存` → `low_stock`
- 点击卡片主体 → 提醒中心

---

## 提测注意

- Open Food Facts 需网络；失败时降级为仅条码
- 临期统计已排除「已过期」物品，与首页分区一致
