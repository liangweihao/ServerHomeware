# Token有效性检测与过期处理 - 产品需求文档

## Overview
- **Summary**: 实现客户端启动时token有效性检测，以及接口请求中token过期时的自动跳转登录页面功能
- **Purpose**: 确保用户在token失效时能够被正确引导重新登录，提升安全性和用户体验
- **Target Users**: 所有HomeStock应用用户

## Goals
- 客户端启动时自动检测token有效性
- 接口请求返回401/403时自动跳转到登录页面
- 提供统一的token过期处理机制
- 保持用户体验流畅，避免重复登录

## Non-Goals (Out of Scope)
- 实现token刷新机制（使用refresh_token获取新token）
- 修改服务端认证逻辑
- 实现复杂的session管理

## Background & Context
- 当前已有`AuthGuard`组件监听认证状态
- 已有`AuthException`处理认证异常
- 各服务已有独立的token获取逻辑
- 需要统一处理token过期场景

## Functional Requirements
- **FR-1**: 客户端启动时调用验证接口检测token有效性
- **FR-2**: 所有API请求在收到401/403响应时自动触发退出登录并跳转登录页面
- **FR-3**: 提供统一的响应处理工具类，自动识别认证错误
- **FR-4**: 避免重复跳转登录页面

## Non-Functional Requirements
- **NFR-1**: 响应时间 < 500ms
- **NFR-2**: 安全性：token过期后立即清除本地存储
- **NFR-3**: 用户体验：token过期时显示友好提示

## Constraints
- **Technical**: Flutter Riverpod状态管理、GoRouter路由、SharedPreferences存储
- **Business**: 必须与现有认证体系兼容
- **Dependencies**: 服务端需提供token验证接口

## Assumptions
- 服务端返回401表示token无效/过期
- 服务端返回403表示无权限
- 用户登录后token存储在SharedPreferences

## Acceptance Criteria

### AC-1: 启动时Token验证
- **Given**: 用户已登录过，本地存储有token
- **When**: 客户端启动
- **Then**: 自动调用验证接口检测token有效性
- **Verification**: `programmatic`
- **Notes**: 在Splash页面完成验证

### AC-2: Token有效时正常进入应用
- **Given**: token验证成功
- **When**: 验证接口返回200
- **Then**: 跳转到主页面
- **Verification**: `programmatic`

### AC-3: Token无效时跳转登录
- **Given**: token验证失败（401/403）
- **When**: 验证接口返回认证错误
- **Then**: 清除本地token，跳转到登录页面，显示"登录已过期，请重新登录"提示
- **Verification**: `programmatic`

### AC-4: 接口请求Token过期处理
- **Given**: 用户正在使用应用，token已过期
- **When**: 发起API请求，服务端返回401/403
- **Then**: 自动退出登录，跳转到登录页面，显示友好提示
- **Verification**: `programmatic`

### AC-5: 避免重复跳转
- **Given**: 已经在登录页面
- **When**: token过期
- **Then**: 不重复跳转登录页面
- **Verification**: `programmatic`

## Open Questions
- [ ] 是否需要实现token自动刷新机制？
- [ ] 是否需要区分token过期和token无效的不同提示？