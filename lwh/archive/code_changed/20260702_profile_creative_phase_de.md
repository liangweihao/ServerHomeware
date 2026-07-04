# 个人中心创意增强 Phase D/E

**日期**：2026-07-02  
**前置**：[`20260702_profile_creative_enhancement_plan.md`](20260702_profile_creative_enhancement_plan.md)

---

## Phase D — 领奖台点击成员详情

### 目标

点击领奖台 / 排行列表成员，弹出 **贡献详情 BottomSheet**：本月数据 + 最近操作。

### 实现

1. `FamilyMemberContribution` 增加 `userId`
2. `member_contribution_detail_sheet.dart` + `memberActivityByNameProvider`
3. 领奖台 / 列表行可点击

---

## Phase E — 健康分变化过渡动画

### 目标

健康分、圆环进度、头图渐变在数据刷新后 **平滑过渡**，避免跳变。

### 实现

1. `ProfileHealthRing` 改为 StatefulWidget，弧线与数字 Tween 动画
2. `ProfileIdentityHeader` 渐变 / 问候色 `AnimatedContainer` / `AnimatedDefaultTextStyle`

---

## 测试点

1. 点击 Top3 任一柱 → Sheet 展示录入/消耗与最近动态
2. 点击第 4+ 名列表行 → 同上
3. 下拉刷新个人中心 → 健康分与头图渐变平滑变化

## 执行记录

| 阶段 | 改动文件 |
|------|----------|
| D | `member_contribution_detail_sheet.dart`、`memberActivityByNameProvider`、`profile_contribution_podium.dart`、`family_contribution_section.dart`、`family_contribution_page.dart` |
| E | `profile_health_ring.dart`、`profile_identity_header.dart` |
