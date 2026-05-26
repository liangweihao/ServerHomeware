# 家庭信息服务实现 - 产品需求文档

## Overview
- **Summary**: 实现客户端家庭信息服务，与服务端 `GET /api/v1/families/current` 接口对接
- **Purpose**: 为个人面板页面提供家庭信息数据，包括家庭成员、邀请码、统计数据等
- **Target Users**: 已登录用户

## Goals
- 实现符合服务端规范的家庭信息获取接口
- 支持获取家庭成员列表（含角色信息）
- 支持获取邀请码（用于邀请新成员）
- 支持获取家庭统计数据（物品总数等）
- 支持刷新邀请码功能

## Non-Goals (Out of Scope)
- 家庭创建功能
- 成员管理（添加/删除/角色修改）
- 家庭切换功能

## Background & Context
根据服务端文档 `doc/serverPhase/Phase 3：家庭协作 & 数据同步.md`，`GET /api/v1/families/current` 接口应返回：
- 家庭基础信息
- 成员列表
- 邀请码
- 统计数据（物品总数等）

## Functional Requirements
- **FR-1**: 获取当前家庭信息，包含基本信息（id, name, created_at）
- **FR-2**: 获取家庭成员列表，包含成员ID、昵称、角色、头像
- **FR-3**: 获取邀请码（用于分享邀请）
- **FR-4**: 获取家庭统计数据（物品总数等）
- **FR-5**: 支持刷新邀请码（生成新码，旧码失效）

## Non-Functional Requirements
- **NFR-1**: 接口调用失败时有错误处理和日志记录
- **NFR-2**: 返回数据结构与服务端保持一致
- **NFR-3**: 支持模拟数据（用于开发测试）

## Constraints
- **Technical**: 使用 Dart + Flutter, 遵循项目现有架构模式
- **Dependencies**: 依赖 AuthService 获取用户认证信息

## Assumptions
- 用户已登录，有有效的 access_token
- 服务端 API 已就绪

## Acceptance Criteria

### AC-1: 获取当前家庭信息成功
- **Given**: 用户已登录且属于某个家庭
- **When**: 调用 `getCurrentFamily()`
- **Then**: 返回包含家庭基本信息的响应
- **Verification**: `programmatic`

### AC-2: 获取家庭成员列表
- **Given**: 家庭有多个成员
- **When**: 调用 `getCurrentFamily()`
- **Then**: 返回包含成员列表的响应，每个成员包含 id、昵称、角色、头像
- **Verification**: `programmatic`

### AC-3: 获取邀请码
- **Given**: 家庭已生成邀请码
- **When**: 调用 `getCurrentFamily()` 或 `getInviteCode()`
- **Then**: 返回有效的8位邀请码
- **Verification**: `programmatic`

### AC-4: 刷新邀请码
- **Given**: 用户有权限（owner/admin）
- **When**: 调用 `refreshInviteCode()`
- **Then**: 生成新邀请码，旧码失效
- **Verification**: `programmatic`

### AC-5: 错误处理
- **Given**: 网络错误或服务端返回错误
- **When**: 调用任意方法
- **Then**: 返回错误响应，包含错误码和错误信息
- **Verification**: `programmatic`

## Open Questions
- [ ] 是否需要缓存家庭信息？
- [ ] 邀请码过期时间如何处理？