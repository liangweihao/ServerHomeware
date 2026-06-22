# HomeStock — Phase 4：智能功能

## 前置条件
Phase 1-3 已完成。物品CRUD、位置管理、提醒通知均已可用。

## 本阶段目标
实现首页 Dashboard、搜索功能、购物清单、消耗预测算法。
让App从「记录工具」升级为「智能助手」。

---

## 任务1：首页 Dashboard（HomePage）

路由：/（底部Tab第一个）

### 布局（CustomScrollView，支持下拉刷新）

**AppBar区域：**
- 左侧显示"我的家"标题
- 右侧通知铃铛图标（带Badge数量）+ 头像

**搜索栏：**
- 使用 AppSearchBar 组件，readOnly=true
- 点击跳转 /search 页面

**警告摘要区域：** 标题"⚠️ 需要关注"
- 2×2 网格，4个 StatCard：
  - 🔴 即将过期 | X件 | "最近：牛奶，还剩2天"
  - 📦 库存不足 | X件 | "最近：洗衣液，预计3天用完"
  - 🛒 待购清单 | X项
  - 📊 本月消费 | ¥X,XXX | "比上月↑X%"
- 每个卡片可点击，跳转对应页面

**快捷空间入口：** 标题"📍 快捷查看"
- 横向滚动的房间卡片列表
- 每个卡片：emoji + 房间名 + 物品数
- 点击跳转 /locations/:id

**最近动态：** 标题"📅 最近动态"
- 时间线样式，显示最近5条 usage_records
- 格式："今天 10:30 用完了「厨房纸巾」"
- 底部"查看全部→"

### 数据获取
创建 HomeController (Riverpod)，加载：
- expiringCount: status=0 且 7天内过期的数量
- lowStockCount: status=0 且 current_quantity <= safety_stock 数量
- shoppingCount: shopping_list 中 is_purchased=false 数量
- monthlyExpense: 本月 purchase_date 的物品 total_price 总和
- spaces: 所有 level=1 的位置 + 各自的物品数
- recentActivities: 最近5条 usage_records（关联物品名）

---

## 任务2：搜索页（SearchPage）

路由：/search

### 页面结构
- 顶部搜索输入框（自动聚焦，带清除按钮）
- 输入前：显示搜索历史 + 热门搜索
- 输入时：实时搜索（防抖300ms）

### 搜索逻辑
搜索范围：items 表的 name、brand 字段 + locations 表的 full_path
查询：LIKE '%keyword%'
结果按相关度排序（名称匹配优先于品牌匹配）

### 结果展示
使用 ItemCard 组件展示，突出位置信息（方便「找东西」场景）
每个结果卡片增加一个"导航到位置"的小标签

### 无结果
AppEmptyState: "没有找到 XXX 相关物品" + [手动添加"XXX"] 按钮

### 搜索历史
- 本地存储（SharedPreferences 或数据库）
- 最多保留10条
- 支持清除历史

---

## 任务3：购物清单页（ShoppingListPage）

路由：/shopping

### 页面结构
- AppBar 标题"购物清单"，右侧"分享清单"按钮
- 顶部 Tab：待购 | 已购 | 历史

### 待购 Tab

**系统推荐区域：** 标题"系统推荐（根据消耗预测）"
- 显示 is_auto_generated=true 且 is_purchased=false 的项
- 每项：名称 + 数量+单位 + 上次价格 + 推荐原因（"预计3天后用完"/"已用完"）

**手动添加区域：**
- 显示 is_auto_generated=false 且 is_purchased=false 的项
- 每项：名称 + 数量

**底部：**
- 预估总消费：¥ XXX（sum of estimated_price × quantity）
- 「+ 添加物品」按钮
- 「标记全部已购买」按钮

### 添加到购物清单
弹出 Dialog：
- 输入物品名称（支持从已有物品中搜索选择）
- 数量 + 单位
- 预估价格（可选）
- 确认添加

### 标记已购买
- 每项左侧有 Checkbox
- 勾选后该项移到"已购"Tab
- 更新 is_purchased=true, purchased_at=now

### 已购 Tab
显示最近已购项，支持"一键入库"操作：
- 点击某项 → 跳转到 AddItemPage，预填名称、数量、价格

### 分享功能
将待购清单生成纯文本，通过 share_plus 分享：
```
📋 购物清单 (2024-01-25)

- 洗衣液 3kg × 1
- 纯牛奶 250ml × 6
- 厨房纸巾 × 2
```

---

## 任务4：消耗预测算法

创建 ConsumptionPredictionService 类：

### calculateAvgDailyConsumption(itemId)
```
1. 查询该物品所有 type=1(使用) 的 usage_records，按时间排序
2. 如果记录 < 2 条：
   用 (purchase_quantity - current_quantity) / (today - created_at天数) 估算
3. 如果记录 >= 2 条：
   加权平均法（越近的记录权重越高）：
   遍历相邻两条记录，计算 rate = quantity / 间隔天数
   weight = 记录序号（越新序号越大）
   avg = sum(rate × weight) / sum(weight)
4. 返回日均消耗量
```

### predictEmptyDate(item, avgDailyConsumption)
```
如果 avgDailyConsumption <= 0：返回 null
daysRemaining = current_quantity / avgDailyConsumption
return today + daysRemaining天
```

### 更新时机
在以下场景调用并更新 items 表的 avg_daily_consumption 和 predicted_empty_date：
- 记录使用后
- App启动时批量更新所有 status=0 的物品

---

## 任务5：购物清单自动生成

创建定时任务（App启动时 + 每次记录使用后执行）：

```
遍历所有 status=0 的物品：
IF (current_quantity <= safety_stock)
OR (predicted_empty_date != null AND predicted_empty_date - today <= 7天)
THEN:
检查 shopping_list 中是否已存在 related_item_id = 该物品ID 且 is_purchased=false
如果不存在：
INSERT shopping_list (
name = 物品name,
related_item_id = 物品id,
quantity = 物品purchase_quantity,
unit = 物品unit,
estimated_price = 物品purchase_price,
is_auto_generated = true
)
```

---

## 验收标准

1. ✅ 首页正确显示4个统计卡片，数据实时准确
2. ✅ 首页空间入口横向滚动，点击进入位置详情
3. ✅ 首页最近动态展示正确
4. ✅ 搜索实时响应，结果突出位置信息
5. ✅ 搜索历史可保存和清除
6. ✅ 购物清单区分系统推荐和手动添加
7. ✅ 手动添加购物项功能正常
8. ✅ 标记已购买功能正确
9. ✅ 分享清单生成格式正确
10. ✅ 消耗预测算法正确计算日均消耗和预计用完日期
11. ✅ 系统自动生成购物推荐在合适时机触发
12. ✅ 详情页的"预计用完时间"显示正确