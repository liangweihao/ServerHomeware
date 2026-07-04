# 个人中心创意增强 Phase F/G/H

**日期**：2026-07-02

| 阶段 | 功能 | 状态 |
|------|------|------|
| F | 成员贡献详情独立路由页 | ✅ 已完成 |
| G | 健康分 7 日历史曲线 | ✅ 已完成 |
| H | 领奖台分享（文字 + 图片） | ✅ 已完成 |

---

## Phase F — 成员详情独立路由

- 路由：`/profile/family/member?name=...&record=...&consume=...`
- 页面：`member_contribution_detail_page.dart`
- 共用内容：`member_contribution_detail_body.dart`
- 点击领奖台/列表 → 全屏页；Sheet 仍可用于快速预览（`showMemberContributionDetailSheet`）

## Phase G — 健康分历史曲线

- `ProfileHealthHistoryService`：每日快照写入 SharedPreferences（最多 14 天）
- 首页统计刷新时自动 `recordFromStats`
- `ProfileHealthTrendCard`：个人中心展示近 7 日 fl_chart 折线

## Phase H — 领奖台分享

- `ProfilePodiumShareService`：生成文字排行榜 + RepaintBoundary 截图
- 家庭协作页 AppBar「分享」按钮
- 优先 `shareXFiles` 图片，失败回退纯文本

---

## 测试点

1. 点击领奖台成员 → 进入全屏详情页，返回正常
2. 个人中心出现健康分趋势（需 ≥2 天数据；首日仅提示文案）
3. 家庭协作页点分享 → 系统分享面板有图或文字
4. 下拉刷新后趋势图更新

## 改动文件

- `member_contribution_detail_page.dart`、`member_contribution_detail_body.dart`、`member_contribution_navigation.dart`
- `profile_health_history_service.dart`、`profile_health_history_provider.dart`、`profile_health_trend_card.dart`
- `profile_podium_share_service.dart`
- `app_router.dart`、`family_contribution_page.dart`、`profile_page.dart`、`profile_panel_page.dart`、`home_provider.dart`
