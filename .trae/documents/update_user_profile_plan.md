# 更新用户信息接口实现计划

## 概述

实现 PUT /api/v1/users/me 接口的客户端调用，替换当前的模拟实现。

## 当前状态分析

### 服务端
- ✅ 已有完整的 PUT /api/v1/users/me 接口实现
- ✅ 使用 UpdateUserRequest schema（支持 nickname, email, avatar_url）
- ✅ 接口地址: http://192.168.1.104:8000/api/v1/users/me

### 客户端
- ❌ 当前 updateProfile 使用模拟实现（Future.delayed）
- ❌ 参数包括 userId, nickname, avatar, familyNickname
- ❌ 未调用真实 HTTP API

## 实现计划

### 1. 更新 auth_service.dart 的 updateProfile 方法

**修改文件**: `/Users/lwh/Desktop/Project/ServerHomeWare/HomeWareClient/lib/core/services/auth_service.dart`

**修改内容**:
- 从 SharedPreferences 获取 token
- 构造 PUT 请求到 http://192.168.1.104:8000/api/v1/users/me
- 请求体: `{"nickname": "...", "email": "...", "avatar_url": "..."}`
- 注意: 参数映射（avatar -> avatar_url, 移除 familyNickname）
- 添加响应 JSON 日志打印
- 使用 _handleResponse 方法处理响应

### 2. 更新 FamilyMember 和相关逻辑

客户端 updateProfile 当前有 `familyNickname` 参数，服务端不支持。需要：
- 确认 familyNickname 的用途
- 可能需要在服务端或客户端单独处理

**暂时处理**:
- 先实现基础的 nickname 和 avatar/avatar_url 更新
- familyNickname 可后续处理

## 修改文件清单

1. `/Users/lwh/Desktop/Project/ServerHomeWare/HomeWareClient/lib/core/services/auth_service.dart`
   - 更新 updateProfile 方法实现真实 HTTP 调用
   - 添加响应日志

## 验证要点

- [ ] 客户端能正常发送 PUT 请求到服务端
- [ ] 服务端正确更新用户信息
- [ ] 响应日志完整打印
- [ ] 错误处理正常工作
