# 个人中心 Icon 糖果轻点统一

> 日期：2026-07-06

## 技术开发文档

### 实现方案

1. **`AppListRow` 升级**：leading 统一 `AppIcon.feature` + 可选 `accent`；chevron 改 `CandyIcon`
2. **`CandyIcons` 扩展**：补充 wallet / label / info / cloud_* / copy / key / share / 奖牌等映射
3. **个人中心全模块替换**：`Icon(` → `CandyIcon` / `AppIcon.feature` / `PresetIcon`

### 改动文件

| 区域 | 文件 |
|------|------|
| 共用 | `app_list_row.dart`, `candy_icons.dart` |
| Tab 页 | `profile_page.dart`, `profile_panel_page.dart` |
| 组件 | `profile_overview_strip`, `profile_identity_header`, `profile_quick_action_grid`, `profile_family_card`, `profile_contribution_card`, `profile_health_*`, `profile_contribution_podium`, `family_contribution_*`, `member_contribution_detail_body` |
| 子页 | `notification_settings_page`, `category_management_page`, `family_management_page`, `edit_profile_page`, `switch_family_bottom_sheet` |

### 影响范围

- 纯客户端视觉；个人中心 Tab + 完整个人中心 + 相关子页
- `AppListRow` 变更影响全 App 设置列表（统一为饱和圆角 leading）

## 提测开发文档

### 验证点

1. 「我的」Tab → 概览条、宫格、管理与偏好列表 icon 均为圆角色块
2. 完整个人中心 → 同步状态云 icon、家庭卡邀请码 key icon
3. 切换家庭弹层 → 家庭 icon 为 PresetIcon，非 emoji
4. 提醒设置 / 分类管理 / 成员管理 FAB 为圆润 + 号
5. 贡献榜 / 健康环 / 编辑资料 chevron 与操作 icon

### 注意事项

- 成员列表 `leadingEmoji` 仍为首字母头像（非 emoji 装饰）
- 空态 `AppEmptyState` emoji 参数待下一轮统一
