# HomeStock — Phase 3：位置管理 & 提醒系统

## 前置条件
Phase 1（骨架）和 Phase 2（核心CRUD）已完成。
物品可以录入、查看、编辑、记录使用。

## 本阶段目标
1. 完善位置管理功能（可视化查看、增删改位置结构）
2. 实现提醒中心（过期/库存/补购提醒展示和操作）
3. 接入本地通知（定时检查并推送提醒）

---

## 任务1：位置总览页（LocationOverviewPage）

路由：/locations

### 页面结构
- AppBar 标题"我的家"，右侧"+ 添加空间"按钮
- 网格布局（2列），展示所有一级位置（房间）
- 每个房间卡片：emoji图标(32px) + 名称 + "X件物品"数量
- 卡片样式：灰色背景、圆角12、1:1比例、点击跳转位置详情

### 添加空间
点击"+"弹出 Dialog：输入名称、选择emoji图标、确认后插入 locations 表（level=1）

---

## 任务2：位置详情页（LocationDetailPage）

路由：/locations/:id

### 页面结构
- AppBar 显示位置名称，右侧"编辑布局"按钮
- 如果当前位置有子位置：显示子位置卡片网格（点击进入下一层）
- 如果当前位置是最末层或有物品：显示该位置下的物品列表

### 子位置卡片
与总览页类似，显示子位置名称 + 物品数量

### 物品列表
使用 Phase2 的 ItemCard 组件，展示 location_id = 当前位置ID 的物品
按过期时间排序（快过期的在前面）

### 编辑布局
点击后进入编辑模式：
- 每个子位置卡片右上角显示删除按钮
- 底部显示"+ 添加子位置"按钮
- 支持长按拖拽排序（可选，用 ReorderableListView 实现）

### 添加子位置
弹出 Dialog：输入名称，确认后插入 locations 表（parent_id=当前位置ID，level=当前+1，full_path自动拼接）

---

## 任务3：位置删除逻辑

- 删除位置时检查：该位置及其子位置下是否有物品
- 如有物品：弹窗提示"该位置下有X件物品，请先移走物品再删除"，阻止删除
- 如无物品：确认弹窗后删除该位置及所有子位置

---

## 任务4：提醒中心页（AlertCenterPage）

路由：/alerts（底部Tab第四个）

### 页面结构
- AppBar 标题"提醒中心"，右侧"全部已读"按钮
- 顶部 TabBar（5个Tab）：全部 | 过期 | 库存 | 补购 | 其他
- TabBarView 内容为对应的提醒列表

### 提醒数据来源（实时从数据库查询，非单独存储）

**过期提醒：**
查询条件：status=0(使用中) AND expiry_date 不为空 AND expiry_date - expiry_alert_days <= today
显示内容：🔴/🟡图标 + "XXX还剩X天过期" + 位置 + 建议操作

**库存提醒：**
查询条件：status=0 AND current_quantity <= safety_stock AND stock_alert=true
显示内容：📦图标 + "XXX库存不足" + 剩余量 + 预计用完时间

**补购提醒：**
查询条件：status=1(已用完) 且最近7天变为用完的
显示内容：🛒图标 + "XXX已用完" + 上次购买信息

**其他提醒：**
保修即将到期：warranty_date - 30天 <= today

### AlertCard 组件
- 左侧4px状态色条（红/橙/蓝）
- 内容：图标 + 标题 + 描述 + 位置信息
- 底部操作按钮行（根据类型不同）：
  - 过期提醒：[今天用掉] [已丢弃] [忽略]
  - 库存提醒：[加入购物清单] [已知晓]
  - 补购提醒：[加入购物清单] [再次购买]

### 操作按钮逻辑
- 「今天用掉」→ 弹出 UsageDialog
- 「已丢弃」→ 将物品 status 改为 3，记录 usage_record(type=2丢弃)
- 「加入购物清单」→ 添加到 shopping_list
- 「忽略」→ 从列表中移除（本次会话不再显示，但不改数据）

### 空状态
某个Tab下没有提醒时显示：😊 emoji + "一切安好，没有待处理的提醒"

---

## 任务5：本地通知服务

### 初始化
在 main.dart 中初始化 flutter_local_notifications：
- Android channel: expiry_channel(过期提醒), stock_channel(库存提醒)
- iOS 请求通知权限

### 通知调度服务（NotificationScheduler）

创建一个服务类，提供以下功能：

**scheduleExpiryNotification(item)**
- 计算提醒日期 = expiry_date - expiry_alert_days
- 如果提醒日期 > 今天：使用 zonedSchedule 设置定时通知
- 通知标题："⚠️ 物品即将过期"
- 通知内容："[物品名] 将在X天后过期，请及时处理"
- payload: "item:{id}" 用于点击跳转

**cancelNotification(itemId)**
- 取消该物品的所有已调度通知

**rescheduleAllNotifications()**
- 取消所有通知 → 重新遍历所有 status=0 且有 expiry_date 的物品 → 逐个调度
- 应在以下时机调用：App启动时、物品新增/编辑/删除时

### 每日检查任务
- App每次打开时（在 main 或 HomePage initState 中）执行一次全量检查
- 检查所有物品的过期状态，如果 expiry_date < today 且 status 还是 0，自动更新 status=2
- 重新调度所有通知

### 通知点击处理
点击通知后根据 payload 跳转到对应物品详情页

---

## 任务6：Tab Badge 角标

底部导航"提醒"Tab 上显示未处理提醒数量角标：
- 计算方式：过期提醒数 + 库存提醒数
- 数量为0时隐藏角标
- 使用 Badge 组件

---

## 验收标准

1. ✅ 位置总览页正确显示所有房间，带物品数量统计
2. ✅ 可以逐层进入位置详情，查看该位置下的物品
3. ✅ 可以添加/删除位置，有物品时阻止删除
4. ✅ 提醒中心按Tab分类显示不同类型提醒
5. ✅ 提醒卡片的操作按钮功能正确（丢弃/加购物清单等）
6. ✅ 通知权限获取正常
7. ✅ 添加有过期时间的物品后，通知被正确调度
8. ✅ 到达提醒时间时收到本地通知
9. ✅ 点击通知跳转到物品详情页
10. ✅ 底部Tab角标正确显示提醒数量