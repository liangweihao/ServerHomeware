# 物品变更事件通知框架

## 设计思路

设计一个基于 Riverpod StateNotifier 的事件总线，解耦物品 CRUD 的生产者和消费者：

- **生产者**：物品创建/更新/删除处，调用 `notifyCreated/Updated/Deleted` 发射事件
- **消费者**：需要刷新 UI 的页面（首页、列表页等），通过 `ref.listen` 监听事件并刷新

## 新增文件

### `lib/core/events/item_events.dart`
定义事件类型和数据类：
- `ItemChangeType` 枚举：`created`, `updated`, `deleted`
- `ItemChangeEvent` 数据类：包含 `type` 和可选的 `itemId`

### `lib/core/events/item_event_bus.dart`
事件总线实现：
- `ItemEventBus` 继承 `StateNotifier<int>`，用递增版本号确保每次变更触发监听
- `lastEvent` 属性记录最近一次事件详情，供监听者读取
- 三个通知方法：`notifyCreated()`, `notifyUpdated()`, `notifyDeleted()`
- 全局 Provider：`itemEventBusProvider`

## 生产者（发射事件）

| 文件 | 操作 | 事件类型 |
|------|------|----------|
| `add_item_page.dart:152` | 新建物品 | `notifyCreated` |
| `edit_item_page.dart:107` | 编辑物品 | `notifyUpdated` |
| `item_detail_page.dart:532` | 标记用完 | `notifyUpdated` |
| `item_detail_page.dart:610` | 移动位置 | `notifyUpdated` |
| `item_detail_page.dart:637` | 标记过期 | `notifyUpdated` |
| `item_detail_page.dart:676` | 丢弃物品 | `notifyUpdated` |
| `item_detail_page.dart:706` | 删除物品 | `notifyDeleted` |
| `usage_dialog.dart:77` | 记录使用 | `notifyUpdated` |
| `alert_center_page.dart:112` | 快速使用 | `notifyUpdated` |
| `alert_center_page.dart:137` | 快速丢弃 | `notifyUpdated` |

## 消费者（监听刷新）

### 首页 `home_page.dart`
- 改回 `ConsumerWidget`，移除 GoRouter location 检测 hack
- 通过 `ref.listen(itemEventBusProvider, (prev, next) => ...)` 监听
- 收到事件后 invalidate 四个 provider：
  - `currentFamilyProvider`
  - `homeStatsProvider`
  - `spacesProvider`
  - `recentActivitiesProvider`

## 扩展方式

其他需要刷新的页面只需添加：

```dart
ref.listen(itemEventBusProvider, (prev, next) {
  ref.invalidate(xxxProvider);
});
```

## 测试点

- [ ] 新增物品 → 返回首页，数据自动刷新
- [ ] 编辑物品 → 返回首页，数据自动刷新
- [ ] 在详情页标记用完/过期/丢弃 → 返回首页，数据自动刷新
- [ ] 在详情页删除物品 → 返回首页，数据自动刷新
- [ ] 在详情页记录使用 → 返回首页，数据自动刷新
- [ ] 在提醒中心快速使用/丢弃 → 返回首页，数据自动刷新
- [ ] 首次加载首页不重复刷新
