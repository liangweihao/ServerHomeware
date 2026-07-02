# Phase1-3 三方参考连续优化实现

> 日期：2026-07-01  
> 参考：书旗（分区横滑）、大众点评（卡片信息/搜索热词/详情底栏）、闲鱼（发布向导/实拍卡）  
> 范围：HomeWareClient 首页双层、搜索、邻里服务、个人中心

---

## 技术开发文档

### 产品形态（双层首页）

```
顶栏：头像 | 搜索 | +（发布选择）
├── 我家层：过期 / 临期 / 低库存 / 全部（原有 API）
└── 邻里层：儿童托管 / 家政清洗 / 门店系统（Mock + 本地发布）
```

### Phase 1 — 体验统一

| 改动 | 文件 |
|------|------|
| 搜索页暖色重写：历史 + 热词 + 推荐分区 + 轮播占位 | `search_page.dart`, `search_constants.dart` |
| 「+」发布选择弹层：入库 / 扫码 / 发布服务 | `publish_action_sheet.dart`, `home_top_bar.dart` |
| 物品卡片副信息行（位置） | `home_item_card.dart` |
| 通用暖色 Scaffold / TagChip / FilterChip / AsyncListBody | `community_scaffold.dart` 等 |
| 个人中心迁移 CommunityScaffold | `profile_panel_page.dart` |

### Phase 2 — 邻里模块 MVP

| 改动 | 文件 |
|------|------|
| 服务模型与 Mock 数据 | `community_service.dart`, `community_home_mock_data.dart` |
| 首页邻里分区 Provider | `community_home_provider.dart` |
| 服务卡片 / 分区组件 | `service_card.dart`, `service_section.dart` |
| 服务详情（底栏 CTA） | `service_detail_page.dart` |
| 分类列表 + 筛选 chip + 触底加载 | `service_category_list_page.dart` |
| 四步发布向导 + 本地持久化 | `service_publish_page.dart`, `service_publish_provider.dart` |
| 路由 | `/services/publish`, `/services/category/:slug`, `/services/:id` |

### Phase 3 — 差异化

| 改动 | 文件 |
|------|------|
| 邻里可见范围：同小区 / 我的家庭 | `community_scope_provider.dart`, `family_activity_section.dart` |
| 搜索物品-服务联动提示 | `item_service_link_banner.dart` |
| 家庭共享统计 + 范围切换 UI | `profile_panel_page.dart` |

### 新增路由

- `GET /` — 双层首页
- `/search` — 新搜索结构
- `/services/publish` — 发布服务
- `/services/category/:slug` — 分类列表
- `/services/:id` — 服务详情

### 影响范围

- 首页由单层物品分区扩展为双层（我家 + 邻里）
- 顶栏「+」行为变更（弹层选择，非直接入库）
- 搜索页视觉与信息架构变更
- 个人中心增加家庭共享区与「我的发布」入口
- 二级页（物品列表/详情等）仍为卡通风，后续可继续迁移

---

## 提测开发文档

### 测试点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 冷启动首页 | 我家四分区 + 邻里三分类 |
| T2 | 下拉刷新 | 物品与邻里数据均刷新 |
| T3 | 顶栏「+」 | 弹层三项，各自跳转正确 |
| T4 | 搜索空态 | 历史、热词、推荐横滑分区 |
| T5 | 搜索有结果 | 暖色列表 + 联动提示条（如搜「托管」） |
| T6 | 邻里卡片点击 | 进入服务详情，底栏可点 |
| T7 | 发布服务四步 | 成功后出现在邻里分区首位 |
| T8 | 个人中心范围切换 | 「我的家庭」仅见自己发布 |
| T9 | 查看全部 | 物品/服务分类列表正常 |

### 验证方式

1. 启动客户端，登录有家庭账号
2. 首页滑动验证双层结构
3. 发布一条测试服务，刷新后出现在邻里对应分类
4. 个人中心切换「我的家庭」，邻里 Mock 隐藏、仅见自己发布
5. 搜索「家政」验证联动条与结果列表

### 注意事项

- 邻里服务仍为 Mock + 本地发布，无后端 API
- 物品列表等页面尚未统一暖色主题
- 服务联系/收藏为演示 SnackBar

---

## 后续迭代建议

1. 物品列表/详情/提醒中心迁移 `CommunityScaffold`
2. 后端 `/api/v1/community/*` 对接
3. 发布服务支持图片上传
4. 小区绑定与 LBS 筛选
