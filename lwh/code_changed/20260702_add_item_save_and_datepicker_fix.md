# 添加入库保存失败 + 日期选择器 + 扫码分类修复

**日期**：2026-07-02  
**触发**：验收测试日志（Android 真机）

---

## 问题与根因

### 1. 保存失败 `UNIQUE constraint failed: items.id`（P0）

**现象**：服务端 POST 成功，但客户端 SnackBar「保存失败」；重复点击产生多条服务端重复物品。

**根因**：WS `items_changed` 触发 `ItemSync` 抢先以 serverId 插入本地 → `AddItemPage._saveItemLocally` 再次 INSERT 同 id 冲突。

**修复**：插入前检测 `getItemById(serverId)`，已存在则 `applyToExistingItem` 更新；保存按钮增加 `_isSaving` 防重复提交。

### 2. 扫码入库末尾提示「请选择分类」（P0）

**现象**：扫码未识别条码后走完向导，保存时跳回 Step1 选分类。

**根因**：扫码路径跳过 Step1，分类选择器仅在分类步展示。

**修复**：
- Step2「信息」步在未选分类时展示分类 Chips
- 校验失败时扫码路径回到 Step2 而非 Step1

### 3. 日期选择器英文难用（P1）

**根因**：`MaterialApp` 未配置 `localizationsDelegates`，`showDatePicker` 无中文。

**修复**：
- 添加 `flutter_localizations`
- 新建 `AppDatePicker` 统一中文日历（帮助文案、确定/取消、展示格式 `yyyy年M月d日`）
- 向导页 / 编辑表单页接入

### 5. 保存成功无提示且页面不跳转（P0）

**根因**：扫码用 `context.go` 进入添加入库，`context.pop()` 无法返回；`_saveAndExit` 无成功 SnackBar。

**修复**：
- 保存成功显示「保存成功」SnackBar
- `canPop()` 则 pop，否则 `go('/items')`
- 扫码改 `pushReplacement` 保留返回栈
- 保存中显示「正在保存…」遮罩

**修复**：`NotificationScheduler._zonedScheduleSafe` 精确闹钟失败时降级 `inexactAllowWhileIdle`。

---

## 改动文件

| 文件 | 改动 |
|------|------|
| `add_item_page.dart` | WS 竞态 upsert、防重复保存、分类校验跳转 |
| `add_item_wizard_view.dart` | Step2 补分类、AppDatePicker |
| `app_date_picker.dart` | 新增 |
| `main.dart` | localizationsDelegates |
| `pubspec.yaml` | flutter_localizations |
| `item_form_view.dart` | AppDatePicker |
| `notification_scheduler.dart` | 闹钟降级 |

---

## 提测

| ID | 场景 | 预期 |
|----|------|------|
| F-T1 | 扫码未识别 → 填名称/分类 → 保存 | 成功，无 UNIQUE 错误 |
| F-T2 | 保存中连点 | 不重复 POST |
| F-T3 | 选择过期日 | 中文日历，确定/取消 |
| F-T4 | 冷启动 | 无 exact_alarms 红字（或仅 WARN 日志） |

**注意**：测试产生的重复「郁美净」×4 需在服务端或物品列表手动删除后再测。

---

## 验证命令

```powershell
cd HomeWareClient
flutter pub get
flutter analyze
```
