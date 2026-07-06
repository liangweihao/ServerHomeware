# Phase B B1 — space_type + Onboarding

**日期**：2026-07-04  
**状态**：B1 已交付（待联调）  
**关联**：[phase-b-shop-skin-prd.md](../../doc/product/phase-b-shop-skin-prd.md)

---

## 一、实现方案

### 服务端

| 项 | 路径 |
|----|------|
| 常量 | `app/core/space_type.py` |
| 模型 | `families.space_type` default `home` |
| 迁移 | `alembic/versions/0008_add_family_space_type.py` |
| Schema | `CreateFamilyRequest.space_type`、`FamilyResponse.space_type` |
| API | `POST /families` 接收；`GET /current`、家庭列表返回 |
| 创建逻辑 | shop → icon 🏪；位置模板仍用家庭模板（B3 再换） |

### 客户端

| 项 | 路径 |
|----|------|
| 枚举 | `core/models/space_type.dart` |
| 皮肤骨架 | `core/config/space_skin_config.dart` |
| Provider | `core/providers/space_skin_provider.dart` |
| 创建页 | `create_family_page.dart` 家庭/店铺二选一卡片 |
| 持久化 | `persistFamilySpaceType` + 登出清除 |

---

## 二、提测

| # | 步骤 | 预期 |
|---|------|------|
| 1 | 后端 `alembic upgrade head` | 0008 成功 |
| 2 | 创建页选「小店铺」→ 提交 | API body 含 `space_type: shop` |
| 3 | `GET /families/current` | 返回 `space_type: shop` |
| 4 | 旧家庭 | 默认 `home` |
| 5 | 日志 | `[spaceSkinProvider] spaceType=shop` |

### 自动化

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/config/space_skin_config_test.dart
```

---

## 三、已知限制（B2/B3）

- UI 除创建页外仍为家庭文案（B2 换肤）
- 店铺仍 seed 家庭位置树（B3 店铺模板）
- 创建后 **不可改** space_type

---

## 四、下一步

- **B2** 全局 Label 走 `spaceSkinProvider`
- **B3** shop 位置/分类 seed
