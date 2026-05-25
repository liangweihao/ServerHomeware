# Phase 3: 位置管理 & 提醒系统实现计划

## 一、项目当前状态总结

### 已完成（Phase 1 & Phase 2）
✅ **项目结构**：完整的 Flutter 项目结构已建立  
✅ **数据库设计**：Locations 表已定义（id, name, icon, parentId, level, fullPath, sortOrder）  
✅ **位置页面占位**：`location_overview_page.dart` 和 `location_detail_page.dart` 已存在  
✅ **提醒页面占位**：`alert_center_page.dart` 已存在  
✅ **依赖配置**：`flutter_local_notifications: ^21.0.0` 已添加到 pubspec.yaml  
✅ **通用组件**：AppButton、AppTag、AppEmptyState 等组件已实现  

---

## 二、Phase 3 实现范围

### 2.1 任务拆分

#### 任务 1: 位置总览页（LocationOverviewPage）
- 网格布局展示所有一级位置（房间）
- 每个卡片显示 emoji 图标 + 名称 + 物品数量
- 添加空间功能（弹窗输入名称和图标）

#### 任务 2: 位置详情页（LocationDetailPage）
- 显示子位置卡片网格
- 显示该位置下的物品列表（使用 ItemCard 组件）
- 编辑布局模式（删除子位置、添加子位置、拖拽排序）

#### 任务 3: 位置删除逻辑
- 检查该位置及其子位置下是否有物品
- 有物品时阻止删除并提示
- 无物品时确认后级联删除

#### 任务 4: 提醒中心页（AlertCenterPage）
- TabBar 分类：全部 | 过期 | 库存 | 补购 | 其他
- AlertCard 组件（状态色条、图标、操作按钮）
- 各类提醒的查询逻辑和操作处理

#### 任务 5: 本地通知服务
- NotificationScheduler 服务类
- scheduleExpiryNotification / cancelNotification / rescheduleAllNotifications
- 每日检查任务（检查过期状态、重新调度通知）
- 通知点击处理（跳转物品详情页）

#### 任务 6: Tab Badge 角标
- 底部导航"提醒"Tab 显示未处理提醒数量
- 数量为 0 时隐藏角标

---

## 三、文件结构设计

```
lib/
├── core/
│   ├── providers/
│   │   └── notification_provider.dart    # 新增：通知服务 Provider
│   └── services/
│       └── notification_scheduler.dart   # 新增：通知调度服务
├── data/
│   └── database/
│       └── app_database.dart             # 扩展：添加位置和提醒相关查询
├── presentation/
│   ├── alerts/
│   │   ├── alert_center_page.dart        # 完全重写
│   │   └── widgets/
│   │       └── alert_card.dart           # 新增：提醒卡片组件
│   ├── locations/
│   │   ├── location_overview_page.dart   # 完全重写
│   │   ├── location_detail_page.dart     # 完全重写
│   │   └── widgets/
│   │       ├── location_card.dart         # 新增：位置卡片组件
│   │       └── add_location_dialog.dart  # 新增：添加位置弹窗
│   └── common/
│       └── widgets/
│           └── main_scaffold.dart        # 修改：添加 Badge 角标
└── main.dart                             # 修改：初始化通知服务
```

---

## 四、实现步骤详细分解

### 阶段一：数据库层扩展（优先级：高）
1. 扩展 `app_database.dart`，添加：
   - 获取位置下物品数量的方法
   - 获取所有子位置的方法
   - 删除位置及其子位置的方法
   - 过期提醒查询方法
   - 库存提醒查询方法
   - 补购提醒查询方法

### 阶段二：位置管理功能（优先级：高）
1. 创建 `location_card.dart` 组件
2. 创建 `add_location_dialog.dart` 组件
3. 重写 `location_overview_page.dart`
4. 重写 `location_detail_page.dart`
5. 实现位置删除逻辑

### 阶段三：提醒中心（优先级：高）
1. 创建 `alert_card.dart` 组件
2. 重写 `alert_center_page.dart`，实现：
   - TabBar 分类展示
   - 各类提醒的查询和展示
   - 操作按钮逻辑（今天用掉、已丢弃、加入购物清单等）

### 阶段四：通知服务（优先级：高）
1. 创建 `notification_scheduler.dart` 服务类
2. 创建 `notification_provider.dart` Provider
3. 修改 `main.dart`，初始化通知服务和每日检查任务

### 阶段五：Tab Badge 角标（优先级：中）
1. 修改 `main_scaffold.dart`，添加提醒数量角标
2. 创建提醒数量 Provider

### 阶段六：测试和验证（优先级：高）
1. 验证所有验收标准
2. 代码生成（drift_dev, build_runner）
3. 项目构建验证

---

## 五、依赖和技术考虑

### 已有的依赖
- ✅ flutter_local_notifications: ^21.0.0 - 本地通知
- ✅ permission_handler: ^12.0.1 - 权限管理（用于 iOS 通知权限）
- ✅ intl: ^0.20.2 - 日期格式化

### 需要注意的 API 变更
- `flutter_local_notifications` 21.x 版本使用新的 API（`FlutterLocalNotificationsPlugin`）
- Android 需要创建 notification channel
- iOS 需要在 Info.plist 中添加权限描述

---

## 六、风险和注意事项

### 技术风险
1. **通知权限**：iOS 需要请求权限，Android 需要创建 channel
2. **时区问题**：通知调度需要正确处理时区
3. **数据一致性**：删除位置时需确保级联删除正确

### 业务风险
1. **过期状态自动更新**：需要确保每日检查任务正确执行
2. **提醒数量计算**：需要高效查询，避免性能问题

---

## 七、验收标准对照

根据 Phase 3 文档，实现后需验证：
- ✅ 位置总览页正确显示所有房间，带物品数量统计
- ✅ 可以逐层进入位置详情，查看该位置下的物品
- ✅ 可以添加/删除位置，有物品时阻止删除
- ✅ 提醒中心按 Tab 分类显示不同类型提醒
- ✅ 提醒卡片的操作按钮功能正确（丢弃/加购物清单等）
- ✅ 通知权限获取正常
- ✅ 添加有过期时间的物品后，通知被正确调度
- ✅ 到达提醒时间时收到本地通知
- ✅ 点击通知跳转到物品详情页
- ✅ 底部 Tab 角标正确显示提醒数量

---

## 八、变更记录保存

根据项目规则，每完成一个主要子任务后，需在 `/Users/lwh/Desktop/Project/ServerHomeWare/lwh/code_changed/` 目录下保存变更记录，文件名需清晰描述变更内容。

---

## 九、关键实现细节

### 9.1 位置删除逻辑流程
```
用户点击删除位置
    ↓
查询该位置及其所有子位置下的物品数量
    ↓
数量 > 0 ?
    ├─ YES → 弹窗提示"该位置下有X件物品，请先移走物品再删除"
    └─ NO  → 确认弹窗 → 删除该位置及所有子位置
```

### 9.2 提醒查询逻辑
| 提醒类型 | 查询条件 | 显示内容 |
|---------|---------|---------|
| 过期提醒 | status=0 AND expiry_date 不为空 AND expiry_date - expiry_alert_days <= today | 🔴/🟡图标 + "XXX还剩X天过期" |
| 库存提醒 | status=0 AND current_quantity <= safety_stock | 📦图标 + "XXX库存不足" |
| 补购提醒 | status=1 且最近7天变为用完 | 🛒图标 + "XXX已用完" |

### 9.3 通知调度流程
```
物品新增/编辑
    ↓
计算提醒日期 = expiry_date - expiry_alert_days
    ↓
提醒日期 > 今天 ?
    ├─ YES → 调用 zonedSchedule 设置定时通知
    └─ NO  → 跳过（已过期或即将过期）
```
