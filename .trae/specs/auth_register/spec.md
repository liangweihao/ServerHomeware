# 客户端注册接口实现 - 产品需求文档

## Overview
- **Summary**: 根据服务端文档规范，修改客户端 AuthService 的注册接口实现，使其与服务端 API 规范一致
- **Purpose**: 确保客户端注册功能与服务端 API 无缝对接
- **Target Users**: HomeStock 家庭物品管理 App 用户

## Goals
- 客户端注册接口参数与服务端规范一致
- 注册响应包含 token 信息
- 注册时自动创建默认家庭
- 遵循编码规范

## Non-Goals (Out of Scope)
- 修改其他认证接口（登录、验证码等）
- 修改服务端实现
- 修改 UI 页面

## Background & Context
服务端文档 `/Users/lwh/Desktop/Project/ServerHomeWare/doc/serverPhase/Phase 1：基础骨架.md` 定义了注册接口规范：
- POST /api/v1/auth/register
- Request: {phone, password, nickname}
- Response: {user, access_token, refresh_token}
- 逻辑：检查手机号唯一 → 创建用户 → 自动创建默认家庭 → 返回token

当前客户端实现的 register 方法参数不匹配，需要更新。

## Functional Requirements
- **FR-1**: 注册接口接收 phone、password、nickname 参数
- **FR-2**: 注册成功返回用户信息和 token（access_token、refresh_token）
- **FR-3**: 注册时自动创建默认家庭
- **FR-4**: 返回统一响应格式

## Non-Functional Requirements
- **NFR-1**: 响应格式遵循服务端统一规范 {code, message, data}
- **NFR-2**: 遵循项目编码规范

## Constraints
- **Technical**: Flutter 框架，现有的 AuthService 结构
- **Dependencies**: 服务端 API 规范

## Assumptions
- 服务端已实现注册接口
- 用户已完成手机号验证码验证（服务端处理）

## Acceptance Criteria

### AC-1: 注册接口参数正确
- **Given**: 客户端调用注册接口
- **When**: 传入 phone、password、nickname 参数
- **Then**: 接口正确处理并返回成功响应
- **Verification**: `programmatic`

### AC-2: 响应包含用户信息
- **Given**: 注册成功
- **When**: 服务端返回响应
- **Then**: 响应中包含完整的用户信息（id、phone、nickname、familyId）
- **Verification**: `programmatic`

### AC-3: 响应包含 token
- **Given**: 注册成功
- **When**: 服务端返回响应
- **Then**: 响应中包含 access_token 和 refresh_token
- **Verification**: `programmatic`

### AC-4: 自动创建家庭
- **Given**: 用户首次注册
- **When**: 注册成功
- **Then**: 用户自动拥有默认家庭，familyId 不为空
- **Verification**: `programmatic`

### AC-5: 统一响应格式
- **Given**: 任何注册请求
- **When**: 服务端返回响应
- **Then**: 响应格式为 {code, message, data}
- **Verification**: `programmatic`

## Open Questions
- [ ] 暂无