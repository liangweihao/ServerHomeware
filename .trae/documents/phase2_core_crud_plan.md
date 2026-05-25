# Phase 2: 核心 CRUD 实现计划

## 一、项目当前状态总结

### 已完成（Phase 1）
✅ **项目结构搭建**：基础 Flutter 项目结构已建立
✅ **数据库设计**：完整的表结构（Categories, Locations, Items, UsageRecords, ShoppingList, FamilyMembers）
✅ **预设数据**：分类和位置的预设数据已添加
✅ **路由配置**：GoRouter 路由已配置完成
✅ **主题常量**：AppColors 等常量已定义
✅ **基础页面**：各页面占位文件已创建
✅ **依赖配置**：pubspec.yaml 已包含 flutter_riverpod, drift, flutter_slidable, intl 等所需依赖

---

## 二、Phase 2 实现范围

### 2.1 任务拆分

#### 任务 1: 通用组件库
创建可复用的 UI 组件，为后续页面开发提供基础：
- **AppButton**：支持多种变体（primary/secondary/outline/ghost/danger）和尺寸
- **AppTag**：状态标签组件
- **AppProgressBar**：进度条组件（支持自动颜色模式）
- **QuantityStepper**：数量选择组件
- **AppEmptyState**：空状态组件
- **AppSearchBar**：搜索栏组件

#### 任务 2: 数据库层扩展
完善数据库 DAO 和查询逻辑：
- 扩展 `app_database.dart`，添加完整的 CRUD 查询方法
- 创建数据模型层（Freezed 或数据类）
- 实现 Riverpod Providers 用于数据访问

#### 任务 3: 物品录入页面 (AddItemPage)
实现完整的物品添加表单：
- 表单分区（基本信息、购买信息、时效信息、存放位置、提醒设置）
- CategorySelector 组件（分类选择弹窗）
- LocationPicker 组件（位置三级选择弹窗）
- QuantityStepper 集成
- 保存逻辑（入库记录 + 物品插入）

#### 任务 4: 物品列表页面 (ItemListPage)
实现物品浏览和筛选：
- 分类 Tab 横向滚动
- 筛选/排序底部弹窗
- ItemCard 组件（带状态色、进度条、快捷操作）
- flutter_slidable 左滑操作（使用、编辑、删除）
- AppEmptyState 空状态

#### 任务 5: 物品详情页面 (ItemDetailPage)
实现物品详情展示和操作：
- 图片/ emoji 展示区域
- 三指标行（剩余数量、过期倒计时、消耗速率）
- AppProgressBar 进度展示
- 使用记录时间线
- 底部固定操作栏

#### 任务 6: 使用/消耗记录功能
实现物品使用记录的完整流程：
- UsageDialog 弹窗组件
- 记录使用逻辑（更新物品 + 插入记录）
- 已用完逻辑
- 再次购买逻辑

#### 任务 7: 编辑物品页面 (EditItemPage)
复用 AddItemPage 结构，实现编辑功能：
- 数据预填充
- 更新而非插入
- 保存逻辑

#### 任务 8: MainScaffold 优化
添加录入方式选择弹窗：
- 点击 FAB 弹出 AddMethodSheet
- 扫码录入（占位，Phase 5 实现）
- 手动录入

---

## 三、文件结构设计

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # 新增：通用常量（单位列表、渠道列表等）
│   │   └── ...
│   ├── providers/
│   │   └── database_provider.dart   # 新增：数据库 Provider
│   └── ...
├── data/
│   ├── models/                      # 新增：数据模型层
│   │   └── item_with_relations.dart # 关联查询数据模型
│   └── database/
│       └── app_database.dart        # 扩展：添加 DAO 和查询方法
├── presentation/
│   ├── common/
│   │   └── widgets/
│   │       ├── app_button.dart      # 新增
│   │       ├── app_tag.dart         # 新增
│   │       ├── app_progress_bar.dart# 新增
│   │       ├── quantity_stepper.dart# 新增
│   │       ├── app_empty_state.dart # 新增
│   │       ├── app_search_bar.dart  # 新增
│   │       ├── category_selector.dart  # 新增
│   │       ├── location_picker.dart    # 新增
│   │       ├── usage_dialog.dart       # 新增
│   │       ├── add_method_sheet.dart   # 新增
│   │       ├── filter_bottom_sheet.dart# 新增
│   │       ├── item_card.dart          # 新增
│   │       └── ...
│   ├── items/
│   │   ├── add_item_page.dart      # 完全重写
│   │   ├── item_list_page.dart     # 完全重写
│   │   ├── item_detail_page.dart   # 完全重写
│   │   └── edit_item_page.dart     # 完全重写
│   └── ...
└── main.dart                        # 可能需要调整 ProviderScope 初始化
```

---

## 四、实现步骤详细分解

### 阶段一：通用组件和基础设施（优先级：高）
1. 创建 `app_constants.dart` - 定义单位列表、购买渠道、保质期选项等常量
2. 扩展 `app_database.dart` - 添加完整的 DAO 查询方法
3. 创建 `database_provider.dart` - Riverpod Provider 提供数据库实例
4. 实现通用组件：
   - AppButton
   - AppTag
   - AppProgressBar
   - QuantityStepper
   - AppEmptyState
   - AppSearchBar

### 阶段二：物品录入功能（优先级：高）
1. 实现 CategorySelector 组件
2. 实现 LocationPicker 组件
3. 实现 AddMethodSheet（FAB 弹窗）
4. 重写 AddItemPage - 完整表单和保存逻辑
5. 修改 MainScaffold - 集成 AddMethodSheet

### 阶段三：物品列表功能（优先级：高）
1. 实现 FilterBottomSheet
2. 实现 ItemCard 组件
3. 重写 ItemListPage - 列表展示、筛选、排序

### 阶段四：物品详情和使用记录（优先级：高）
1. 实现 UsageDialog 组件
2. 重写 ItemDetailPage - 详情展示和操作
3. 实现记录使用、已用完、再次购买逻辑

### 阶段五：编辑功能（优先级：中）
1. 重写 EditItemPage - 数据预填充和更新逻辑

### 阶段六：测试和验证（优先级：高）
1. 验证所有验收标准
2. 代码生成（drift_dev, build_runner）
3. 项目构建验证

---

## 五、依赖和技术考虑

### 已有的依赖
- ✅ flutter_riverpod - 状态管理
- ✅ go_router - 路由
- ✅ drift - 数据库
- ✅ flutter_slidable - 滑动操作
- ✅ intl - 国际化/日期格式化

### 无需新增依赖
所有 Phase 2 功能可基于现有依赖实现

---

## 六、风险和注意事项

### 技术风险
1. **Drift 代码生成**：修改表结构后需重新运行代码生成
2. **关联查询**：Items 需要关联 Categories 和 Locations，需正确处理

### 业务风险
1. **日期计算**：保质期和到期日期的自动计算需仔细验证
2. **库存状态**：库存预警和过期状态的逻辑需正确实现

---

## 七、验收标准对照

根据 Phase 2 文档，实现后需验证：
- ✅ 可以通过手动表单完整录入一个物品
- ✅ 物品列表正确显示，分类 Tab 筛选有效
- ✅ 筛选弹窗可按状态/位置/分类筛选，排序有效
- ✅ 物品卡片正确显示状态色、进度条、紧急标签
- ✅ 物品详情页显示完整信息
- ✅ 记录使用后数量正确更新，usage_records 有记录
- ✅ 已用完正确更新状态
- ✅ 再次购买正确添加到购物清单
- ✅ 左滑删除有确认弹窗，删除后列表刷新
- ✅ 编辑物品可正确回填和保存

---

## 八、变更记录保存

根据项目规则，每完成一个主要子任务后，需在 `/Users/lwh/Desktop/Project/ServerHomeWare/lwh/code_changed/` 目录下保存变更记录，文件名需清晰描述变更内容。
