# 社区邻里便民服务 App — 首页 UI 结构文档 & 开发计划

> 日期：2026-06-30  
> 状态：产品形态规划（替换当前卡通主题 / 家庭物品首页）  
> 目标用户：小区家长（宝妈）、线下小店老板  
> 核心策略：**单页首屏即价值** — 第一眼看到可理解、可点击的关键服务

---

## 一、产品定位变更摘要

| 维度 | 当前（HomeStock） | 新形态（社区便民） |
|------|-------------------|-------------------|
| 核心价值 | 家庭物品库存管理 | 社区邻里生活服务发现与发布 |
| 首页信息 | 过期/库存/空间/动态 | 分类服务卡片横向浏览 |
| 视觉风格 | 卡通珊瑚暖色 + 描边卡片 | 米白极简 + 低饱和居家暖色 + 轻微投影 |
| 导航重心 | 四 Tab（首页/物品/提醒/我的） | **首屏单页为主**，Tab 可后续精简 |
| 商业感 | 工具型 | 亲民服务型，无促销贴纸 |

---

## 二、页面总览（Wireframe 文字版）

```
┌─────────────────────────────────────────────┐  ← 固定顶栏 h=56dp + SafeArea
│ [○头像]   [🔍 搜索托管、家政、门店系统    ]  [⊕] │
├─────────────────────────────────────────────┤  ← 主体滚动区（RefreshIndicator）
│ ░░░ 模块 A：儿童托管 ░░░░░░░░░░░░░░░░░░░░░░ │
│  儿童托管                        查看全部 →  │
│  ┌──────┐ ┌──────┐ ┌──────┐ →              │
│  │ 实景 │ │ 实景 │ │ 实景 │                 │
│  │ 标题 │ │ 标题 │ │ 标题 │                 │
│  │[标签]│ │[标签]│ │[标签]│                 │
│  └──────┘ └──────┘ └──────┘                 │
│ ░░░ 模块 B：家政清洗 ░░░░░░░░░░░░░░░░░░░░░░ │
│  家政清洗                        查看全部 →  │
│  ┌──────┐ ┌──────┐ ┌──────┐ →              │
│  ...                                        │
│ ░░░ 模块 C：门店系统 ░░░░░░░░░░░░░░░░░░░░░░ │
│  门店系统                        查看全部 →  │
│  ┌──────┐ ┌──────┐ ┌──────┐ →              │
│  ...                                        │
└─────────────────────────────────────────────┘
  全局背景 #FAF7F2（米白）  模块底 #F5F0E8（浅米色分割）
```

---

## 三、层级结构拆解（严格按规范）

### 1. 顶部固定导航栏

**容器：`CommunityHomeAppBar`（固定高度，不随滚动折叠）**

| 子组件 | 功能 | 交互行为 | 视觉表现 |
|--------|------|----------|----------|
| **左：用户头像** `UserAvatarButton` | 展示当前用户身份 | 点击 → `/profile/panel` 个人中心 | 圆形 40×40dp；渐变描边环（主色→浅杏 `#E8C4A8`）；内圈用户头像或首字母；无 Badge |
| **中：搜索框** `HomeSearchBar` | 全局服务搜索入口 | 点击整框 → `/search?q=` 或聚焦输入；支持占位文案 | 通栏自适应宽度；圆角 20dp；背景 `#FFFFFF` 90% 不透明；左侧书桌/搜索小图标 `#9E8E7E`；占位「搜索托管、家政、门店系统」14sp `#B0A090`；高度 40dp |
| **右：发布按钮** `PublishFabCompact` | 快捷发布服务 | 点击 → `/services/publish`（待建） | 圆形 44×44dp；暖色渐变底 `#D4A574→#C8956A`；白色「+」图标；轻微投影 `0 2 8 rgba(0,0,0,0.08)` |

**顶栏容器样式：**
- 背景与页面米白一致 `#FAF7F2`，底部分割线 0.5dp `#EDE6DC`（可选）
- 水平内边距 16dp，左中右间距 12dp
- 不使用 SliverAppBar floating，避免首屏信息被顶栏挤压

---

### 2. 主体滚动区域

**容器：`CommunityHomeScrollBody`（`CustomScrollView` + `RefreshIndicator`）**

垂直流式布局，按配置循环渲染 **N 个分类模块**（首版固定 3 类）。

---

#### 2.1 单分类模块 `ServiceCategorySection`

**模块容器样式：**
- 背景 `#F5F0E8`（浅米色，与全局底 `#FAF7F2` 区分层级）
- 上下内边距 20dp，模块间距 8dp
- 圆角 0（通栏分割）或顶部圆角 16dp（首模块可选）

##### 2.1.1 模块头部行 `CategorySectionHeader`

| 子组件 | 功能 | 交互 | 视觉 |
|--------|------|------|------|
| **左：分类标题** | 一级分类名 | 无独立点击（或点击等同查看全部） | 18sp Semibold `#3D3229` |
| **右：查看全部** | 进入分类完整列表 | 点击 → `/services/category/:slug` | 14sp `#8B7355`；浅圆角文字按钮；右箭头 `→` 或 `Icons.chevron_right` 12dp |

布局：`Row(spaceBetween, crossAxisAlignment: center)`，水平 padding 16dp。

##### 2.1.2 横向滑动卡片容器 `HorizontalServiceCardList`

| 属性 | 规格 |
|------|------|
| 组件 | `ListView.separated` / `SingleChildScrollView` + Row，`scrollDirection: horizontal` |
| 高度 | 固定 220dp（含卡片阴影） |
| 首项左边距 | 16dp |
| 卡片间距 | 12dp |
| 末项右边距 | 16dp |
| 滑动 | 单行，惯性滑动，无分页指示器 |

---

#### 2.2 单服务卡片 `ServiceCard`

**固定结构（上图像 + 下文字）：**

| 区域 | 功能 | 交互 | 视觉 |
|------|------|------|------|
| **上层：场景图** `ServiceCardImage` | 真实生活场景展示 | 随卡片整体点击 | 宽 160dp × 高 120dp；圆角 12dp（仅顶部）或整卡统一 12dp；`BoxFit.cover`；占位时用中性灰 `#E8E0D5` + 图标 |
| **下层：文字区** `ServiceCardInfo` | 服务名 + 卖点 | 随卡片整体点击 | 背景 `#FFFFFF`；内边距 12dp；主标题 15sp Bold `#3D3229` 最多 2 行；标签行下方 4dp |

**卡片整体：**
- 宽度 160dp
- 圆角 12dp
- 投影：`BoxShadow(color: rgba(0,0,0,0.06), blur: 12, offset: (0,4))`
- 点击态：scale 0.98 + 投影减弱（150ms）
- 点击 → `/services/:id` 服务详情（待建）

**卖点标签 `ServiceTagChip`：**
- 高 22dp，圆角 11dp，水平 padding 8dp
- 字体 11sp Medium
- 按类别使用低饱和彩色（见 §五）

---

### 3. 首版三类模块内容定义

#### 模块 A：儿童托管

| 卡片 | 主标题 | 标签 | 图片素材方向 |
|------|--------|------|--------------|
| A1 | 午托安心班 | 近社区 · 有监控 | 教室实景，孩子阅读/手工 |
| A2 | 周末创意坊 | 小班制 · 6人上限 | 明亮教室，老师陪伴 |
| A3 | 临时托管 2h | 随约随到 | 门口接送场景 |

#### 模块 B：家政清洗

| 卡片 | 主标题 | 标签 | 图片素材方向 |
|------|--------|------|--------------|
| B1 | 空调深度清洗 | 上门 · 当日可约 | 师傅清洗外机实拍 |
| B2 | 油烟机拆洗 | 专业工具 · 无异味 | 厨房清洗前后对比感 |
| B3 | 沙发除螨护理 | 母婴友好 | 布艺沙发护理场景 |

#### 模块 C：门店系统

| 卡片 | 主标题 | 标签 | 图片素材方向 |
|------|--------|------|--------------|
| C1 | 小店进销存 | 手机就能用 | SaaS 后台截图（清晰 UI） |
| C2 | 会员收银一体 | 适合奶茶/便利店 | 收银界面截图 |
| C3 | 库存预警提醒 | 少踩坑 | 仪表盘/预警列表示意 |

---

## 四、视觉规范（替换卡通主题）

### 4.1 色彩 Token（新主题 `communityWarm`）

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | `#FAF7F2` | 全局米白底 |
| `sectionBackground` | `#F5F0E8` | 分类模块浅米色 |
| `cardBackground` | `#FFFFFF` | 卡片文字区 |
| `textPrimary` | `#3D3229` | 标题、正文主色 |
| `textSecondary` | `#8B7355` | 查看全部、次要文案 |
| `textHint` | `#B0A090` | 搜索占位 |
| `accentGradientStart` | `#D4A574` | 按钮/头像环渐变 |
| `accentGradientEnd` | `#C8956A` | 同上 |
| `divider` | `#EDE6DC` | 分割线 |

**标签色（低饱和，禁止高亮促销红）：**

| 类型 | 背景 | 文字 |
|------|------|------|
| 托管类 | `#E8F0E6` | `#5A7A52` |
| 家政类 | `#E6EDF5` | `#4A6B8A` |
| 系统类 | `#F0E8F5` | `#6B5A7A` |

### 4.2 字体与间距

- 字体：系统默认（PingFang / Roboto），无卡通圆体
- 页面水平基准边距：16dp
- 模块内标题与卡片列表间距：12dp
- 禁止：爆炸贴、限时抢购、大红价格、闪烁动效

### 4.3 阴影与圆角

- 卡片圆角：12dp
- 搜索框圆角：20dp
- 投影统一：`0 4 12 rgba(0,0,0,0.06)`，扁平但有层次

### 4.4 与现有代码映射

| 现有 | 新形态 |
|------|--------|
| `AppColorPalettes.cartoon` | 新增 `AppColorPalettes.communityWarm` |
| `HomePage` 统计/空间/动态 | 替换为 `CommunityHomePage` + 分类模块 |
| `SliverAppBar` + 家庭名标题 | 固定三栏顶栏（头像/搜索/发布） |
| `StatCard` / `SpaceCard` | `ServiceCard` + `ServiceCategorySection` |

---

## 五、组件树（Flutter 实现参考）

```
CommunityHomePage
├── CommunityHomeAppBar
│   ├── UserAvatarButton
│   ├── HomeSearchBar
│   └── PublishFabCompact
└── RefreshIndicator
    └── CustomScrollView
        └── SliverList
            └── ServiceCategorySection × N
                ├── CategorySectionHeader
                │   ├── Text (title)
                │   └── ViewAllButton
                └── HorizontalServiceCardList
                    └── ServiceCard × M
                        ├── ServiceCardImage
                        └── ServiceCardInfo
                            ├── Text (title)
                            └── ServiceTagChip
```

---

## 六、数据模型（首版可 Mock）

```dart
/// 首页分类模块
class ServiceCategory {
  final String id;
  final String title;       // 儿童托管
  final String slug;        // childcare
  final List<ServiceCardItem> items;
}

/// 单张服务卡片
class ServiceCardItem {
  final String id;
  final String title;
  final String tag;         // 核心卖点，单行
  final String imageUrl;    // 实景图 URL 或 asset
  final ServiceTagStyle tagStyle;
}
```

**Provider 规划：**
- `communityHomeCategoriesProvider` — 拉取/缓存首页分类+卡片
- 首版：`MockCommunityHomeData` 静态数据，无需后端
- 二期：对接 `/api/v1/community/home` 或 CMS

---

## 七、路由与交互地图

| 入口 | 目标路由 | 优先级 |
|------|----------|--------|
| 头像 | `/profile/panel` | P0（复用现有） |
| 搜索框 | `/search` | P0（复用，改占位文案） |
| 发布 + | `/services/publish` | P1（新页，可先 SnackBar 占位） |
| 查看全部 | `/services/category/:slug` | P1 |
| 服务卡片 | `/services/:id` | P1 |
| 下拉刷新 | invalidate home provider | P0 |

**单页策略：** 底部 Tab 首版可保留 4 Tab，但 **Tab「首页」仅展示本结构**；物品/提醒 Tab 可隐藏或降为二级入口（产品决策项，建议 Phase 2 处理）。

---

## 八、开发计划

### Phase 0：设计冻结（0.5 天）

- [ ] 确认三类模块名称、卡片数量（各 3 张）
- [ ] 确认素材来源：实拍图 / 占位图 / 远程 URL
- [ ] 确认是否隐藏原 HomeStock 四 Tab 中的「物品」「提醒」

**产出：** 本规格文档评审通过

---

### Phase 1：主题与 Design Token（1 天）

| 任务 | 文件 | 说明 |
|------|------|------|
| 新增色板 | `app_color_palette.dart` | `communityWarm` palette |
| 切换默认主题 | `app_colors.dart` / `main.dart` | 替换 cartoon 为 communityWarm |
| 间距/圆角/阴影常量 | `community_home_constants.dart` | 集中 Token |
| 更新 ThemeData | `app_theme.dart` | 文字色、AppBar、CardTheme |

**验收：** 全局背景变为米白，无珊瑚卡通描边

---

### Phase 2：首页顶栏组件（1 天）

| 组件 | 路径建议 |
|------|----------|
| `CommunityHomeAppBar` | `presentation/community/home/widgets/` |
| `UserAvatarButton` | 复用 `AuthService.getAvatarColors`，加渐变描边环 |
| `HomeSearchBar` | 仿搜索页入口，非全功能输入 |
| `PublishFabCompact` | 渐变圆形按钮 |

**验收：** 顶栏固定、三栏对齐、点击路由正确、关键分支打日志

---

### Phase 3：分类模块与卡片（1.5 天）

| 组件 | 说明 |
|------|------|
| `ServiceCategorySection` | 浅米色模块容器 |
| `CategorySectionHeader` | 标题 + 查看全部 |
| `HorizontalServiceCardList` | 横向 ListView |
| `ServiceCard` | 上图下文 + 阴影 |
| `ServiceTagChip` | 彩色低饱和标签 |

**数据：** `community_home_mock_data.dart` 三组 9 张卡片

**验收：** 3 模块垂直排列、横向可滑、卡片点击有反馈

---

### Phase 4：首页组装与替换（0.5 天）

| 任务 | 说明 |
|------|------|
| 新建 `CommunityHomePage` | 组装顶栏 + 滚动体 |
| 路由切换 | `app_router.dart` Tab 首页指向新页 |
| 下拉刷新 | 刷新 mock / 未来 API |
| Shimmer 骨架 | 复用 `home_shimmer` 模式改卡片骨架 |

**验收：** 冷启动首屏即为社区便民结构，无原统计/grid

---

### Phase 5：二级页占位（1 天，可并行）

| 页面 | 最小实现 |
|------|----------|
| `/services/category/:slug` | 分类下全量列表（竖向） |
| `/services/:id` | 详情：大图 + 标题 + 标签 + 联系/预约按钮 |
| `/services/publish` | 表单占位或「即将上线」 |

**验收：** 首页所有点击有落地页，无 dead end

---

### Phase 6：联调与体验打磨（1 天）

- [ ] 真机滑动性能（图片缓存 `cached_network_image`）
- [ ] 空态 / 错误态 / 弱网
- [ ] 无障碍：搜索框 semanticsLabel、按钮 tooltip
- [ ] 日志：`[CommunityHome] INFO/WARN/ERROR` 覆盖刷新、点击、加载失败

---

### 排期总览

| Phase | 内容 | 工期 | 依赖 |
|-------|------|------|------|
| 0 | 设计冻结 | 0.5d | — |
| 1 | 主题 Token | 1d | 0 |
| 2 | 顶栏 | 1d | 1 |
| 3 | 模块卡片 | 1.5d | 1 |
| 4 | 首页替换 | 0.5d | 2,3 |
| 5 | 二级页占位 | 1d | 4 |
| 6 | 打磨 | 1d | 5 |

**合计：约 6.5 个工作日（1 人）**

---

## 九、提测要点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 冷启动进入首页 | 米白底 + 三分类模块，无卡通统计卡片 |
| T2 | 横向滑动卡片 | 流畅，末卡可滑入视野 |
| T3 | 点击头像/搜索/发布 | 跳转正确页面 |
| T4 | 点击查看全部 | 进入对应分类列表 |
| T5 | 点击服务卡片 | 进入详情页 |
| T6 | 下拉刷新 | 有 loading，数据重新加载 |
| T7 | 视觉 | 无大红促销元素，投影轻微，留白充足 |
| T8 | 两类用户认知 | 宝妈能识别托管/家政，店主能识别门店系统 |

---

## 十、Out of Scope（首版不做）

- 后端 CMS / 真实服务 CRUD API
- 地理位置 LBS、小区绑定
- 订单支付、聊天 IM
- 推荐算法、个性化排序
- 完全移除 HomeStock 物品管理代码（可保留路由，仅隐藏 Tab）

---

## 十一、后续产品决策（需评审）

1. **Tab 结构**：是否改为单 Tab + 侧栏，或 2 Tab（发现 / 我的）？
2. **原 HomeStock 功能**：下架 / 独立 App / 折叠进「工具箱」？
3. **发布服务**：UGC 审核流程与资质展示
4. **搜索**：是否改为首页内联搜索结果，而非跳转独立搜索页

---

*文档版本 v1.0 — 对齐用户提供的 UI 主题描述与页面层级规范*
