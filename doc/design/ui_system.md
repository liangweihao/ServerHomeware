# HomeStock UI 规范（Utility System）

> **状态**：现行规范，开发与 Code Review 以此为准。  
> **默认主题**：`utilityClean`（清爽工具风）。  
> **代码真源**：`HomeWareClient/lib/core/constants/` + `presentation/common/widgets/app_*.dart`  
> **关联**：[design-system.md](design-system.md)（Token 速查）、[information-architecture.md](information-architecture.md)（信息架构）

---

## 一、设计目标（用户需要什么）

HomeStock 是**家庭库存工具**，不是内容社区。用户打开 App 的核心诉求：

| 用户问题 | UI 要回答 |
|----------|-----------|
| 家里还有什么？ | 列表/搜索一眼看到名称、数量、位置 |
| 什么要处理了？ | **理由优先**标签（临期、库存低、已过期） |
| 怎么最快记进去？ | 闲鱼式「+」→ 方式选择 → 分步向导 |
| 谁用了/还剩多少？ | 详情进度条 + 最后操作人 |
| 家人协作了吗？ | 个人中心贡献、实时同步状态 |

**设计原则**：

1. **工具优先**：信息密度 > 装饰；3 秒内读懂一条物品  
2. **理由优先**：列表先展示「为什么现在看它」，再展示位置/数量  
3. **操作集中**：全站唯一黄色主操作（添加/发布）；其余用橙/描边  
4. **录入减负**：分步表单、扫码/OCR、搜索空结果一键添加  
5. **一套默认 UI**：`utilityClean` 只维护一套组件；卡通主题为可选皮肤  

---

## 二、参考映射（借交互，不借视觉堆砌）

| 参考产品 | 借鉴到 HomeStock | 落地位置 |
|----------|------------------|----------|
| **大众点评** | 灰底 + 白卡分区、理由标签、列表信息层级 | 物品列表、搜索、提醒 |
| **闲鱼** | 黄色「+」、录入方式选择、分步发布 | 首页 FAB、`/items/add/method` |
| **系统提醒事项** | 左色条状态、分组列表、设置行 | 提醒中心、StatCard、设置 |
| **Notion 字段感** | 详情分组、标签、弱装饰 | 物品详情 Section |

**禁止**：整页卡通贴纸、随机倾斜卡片、emoji 当全站图标（空态/分类 icon 除外）。

---

## 三、Design Tokens

### 3.1 颜色（`utilityClean`）

| Token | 值 | 用途 |
|-------|-----|------|
| `scaffoldBackground` | `#F5F5F5` | 页面底 |
| `white` / 卡片底 | `#FFFFFF` | 卡片、顶栏 |
| `primary` | `#FF6633` | 链接、筛选、次要 CTA、Chip 强调 |
| `accentHighlight` | `#FFDA44` | **仅** FAB、首页「+」 |
| `textPrimary/Secondary/Hint` | `#333 / #666 / #999` | 三级文字 |
| `homeDivider` | 浅灰描边 | 卡片 border、AppBar 底部分割 |
| `success/warning/danger` | 语义色 | 临期/库存/过期 |

### 3.2 圆角与间距

| Token | 值 | 用途 |
|-------|-----|------|
| `AppRadius.sm` | 8 | Chip、小图标底 |
| `AppRadius.md` | 12 | **标准卡片**、列表行 |
| `AppRadius.lg` | 16 | Sheet、大弹窗 |
| 页面水平边距 | **16** | 全站统一 |
| 卡片间距 | **12** | 列表 item 间距 |
| 卡片内边距 | **12–16** | 根据密度 |

### 3.3 阴影

工具风卡片：`elevation: 1`，`shadowColor: black @ 6%`。  
**禁止**多层贴纸阴影（卡通主题除外）。

### 3.4 字体

- 列表标题：15px，`w600–w700`  
- 辅助信息：12px，`textSecondary`  
- 分区标题：13–15px，`w600`，`textSecondary` 或 `textPrimary`  
- 使用 `Theme.of(context).textTheme`，禁止随意 `w900` 贴纸字重  

---

## 四、组件体系（必须使用）

路径：`presentation/common/widgets/`

### 4.1 布局壳

| 组件 | 用途 | 禁止替代 |
|------|------|----------|
| `WarmScaffold` | 二级页标准壳（白顶栏 + 灰底） | 裸 `Scaffold` 自定义 AppBar |
| `HomePage` | 单页首页（顶栏 + 滚动 Feed） | 旧 `MainScaffold` 4 Tab（已废弃） |

### 4.2 容器与列表

| 组件 | 用途 | 禁止替代 |
|------|------|----------|
| **`AppCard`** | 白卡片分组容器 | 工具风下禁止 `AppSurface` |
| **`AppListRow`** | 设置项、功能入口、成员行 | emoji + `InkWell` 手写 |
| **`AppSectionHeader`** | 区块标题（如「消费概览」） | `💰 标题` emoji 前缀 |

### 4.3 标签与筛选

| 组件 | 用途 | 禁止替代 |
|------|------|----------|
| **`AppTag`** | 详情/状态语义标签（success/warning/danger） | — |
| **`TagChip`** | 列表内低饱和标签（理由、数量） | — |
| **`AppReasonTag`** | 物品「出现理由」主题感知封装 | 工具风禁止 `CartoonStickerBadge` |
| **`AppSegmentChip`** | 时间维度等分段筛选 | 工具风禁止 `CartoonChip` |

### 4.4 已有组件（继续用）

| 组件 | 用途 |
|------|------|
| `AppButton` | 主/次/危险按钮 |
| `AppFab` / `AppTabBar` / `AppListEntrance` | 主题感知 FAB、Tab、列表入场 |
| `AppEmptyState` | 空列表 |
| `ItemCard` | 物品卡片（`reasonFirst` / `feed` / `grid`） |
| `AsyncListBody` | 搜索/列表 loading-empty-error |

### 4.5 卡通主题（`cartoon` / 仅回退）

`AppSurface`、`CartoonStickerBadge`、`CartoonChip` 等 **仅允许**在 `!AppColors.isUtilityStyle` 分支内使用。  
新页面**不得**直接 import 卡通组件而不做分支。

---

## 五、页面模板

### 5.1 列表页（物品 / 搜索 / 提醒 / 购物）

```
WarmScaffold
└─ 灰底 ListView
   └─ ItemCard(layout: reasonFirst) 或 业务卡片
      结构：名称 → AppReasonTag/TagChip → 位置·数量（一行）
```

**信息优先级**：名称 > 理由/状态 > 位置·数量 > 品牌

### 5.2 详情页（物品）

```
WarmScaffold
└─ 图 → 标题区 → AppSectionHeader + AppCard(状态总览)
   → AppSectionHeader + 详情行 → 使用记录时间线
```

### 5.3 表单 / 向导（添加入库）

```
WarmScaffold
└─ Step 指示器（4 步）
└─ AppCard 包裹表单区
└─ 底栏：AppButton 上一步 | 下一步（高 48）
```

路由：`/items/add/method` → 扫码 / 手动 / OCR（待上）  
搜索无结果：`/items/add?name=` 预填。

### 5.4 设置 / 个人中心

```
WarmScaffold 或 Tab 内 ScrollView
└─ AppCard
   └─ AppListRow(icon: Icons.xxx, title, trailing: chevron)
```

**图标**：工具风用 `Icons.*`，不用 emoji 菜单项。

### 5.5 统计 / 图表

```
WarmScaffold
└─ AppSegmentChip 行（本周/本月/本年）
└─ AppCard + AppSectionHeader + 图表/数字
```

---

## 六、交互与动效

| 场景 | 规范 |
|------|------|
| 列表点击 | `InkWell` + 12px 圆角，无弹性缩放（工具风） |
| 列表入场 | `AppListEntrance`（180ms fade + 6px 位移） |
| 页面切换 | 已有 `FadeTransitionPage` / `SlideTransitionPage` |
| 下拉刷新 | `RefreshIndicator` |
| 空态 | `AppEmptyState`：灰圆底 emoji + 标题 + 行动按钮 |
| 加载 | `ShimmerLoading` 或 `CircularProgressIndicator` 居中 |

卡通主题可保留 `CartoonPressable` 弹性反馈。

---

## 七、开发约束（Code Review 检查项）

### 必须

- [ ] 新二级页使用 `WarmScaffold`  
- [ ] 工具风卡片使用 `AppCard`  
- [ ] 设置/功能列表使用 `AppListRow` + Material Icon  
- [ ] 物品列表理由标签走 `AppReasonTag` 或 `TagChip`  
- [ ] 黄色仅用于 FAB / 首页「+」  
- [ ] 新增/修改 UI 代码加注释说明分支意图  

### 禁止（`utilityClean` 下）

- [ ] 直接使用 `AppSurface` 作为卡片容器  
- [ ] 直接使用 `CartoonStickerBadge` / `CartoonChip`  
- [ ] 设置项用 emoji 代替 Icon  
- [ ] 同一页面混用 Card elevation 与贴纸描边两种语法  

---

## 八、迁移清单（逐步清零）

| 优先级 | 文件/区域 | 动作 |
|--------|-----------|------|
| P0 | `profile_page.dart` | `AppSurface` → `AppCard`，`AppListRow` |
| P0 | `profile_panel_page.dart` | 功能列表 emoji → Icons |
| P0 | `statistics_page.dart` | `CartoonChip/SectionCard` → 工具风组件 |
| P1 | `edit_profile_page.dart` | `_wrapProfileCard` → `AppCard` |
| P1 | `category_management_page.dart` | 分类卡 `AppSurface` → `AppCard` |
| P2 | `item_card.dart` 卡通路径 | 保持；工具路径已 OK |
| P2 | 删除未引用 `warm_search_result_tile.dart` | ✅ 已删除 |
| P2 | `theme_settings_page.dart` | 新建主题选择页 AppCard |
| P2 | `notification_settings_page.dart` | AppCard + AppListRow |
| P2 | `profile_panel_page.dart` | 邀请码「复制」去 emoji |
| P2 | `family_contribution_page.dart` | AppSectionHeader + AppCard |
| P2 | `family_management_page.dart` | 工具风成员行 AppListRow |
| P2 | `edit_item_page.dart` / `add_item_page.dart` | 向导外包 AppCard |
| P2 | `item_detail_page.dart` | 区块标题 AppSectionHeader |
| P2 | `alert_card.dart` | TagChip → AppReasonTag.plain |
| P2 | `auth_cartoon_wrap.dart` | 工具风 AppCard |

---

## 九、维护

1. 改 Token → 同步 `app_colors.dart` + 本文件 + `design-system.md`  
2. 新增通用组件 → 写入 §四 并更新本文件  
3. 功能 UI 改动 → `lwh/code_changed/YYYYMMDD_ui_*.md`  

---

## 十、版本

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0 | 2026-07-02 | 首版：Utility System 规范 + 组件体系 + 迁移清单 |
| 1.1 | 2026-07-02 | P2 迁移清单完成状态更新 |
