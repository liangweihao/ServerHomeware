# 客户端注册接口实现变更记录

## 概述

根据服务端文档规范，修改客户端注册接口实现，使其与服务端 API 规范一致。

## 服务端接口规范

**POST /api/v1/auth/register**
- Request: `{phone, password, nickname}`
- Response: `{code, message, data: {user, access_token, refresh_token}}`
- 逻辑：检查手机号唯一 → 创建用户 → 自动创建默认家庭 → 返回token

## 改动点

### 1. AuthService (`lib/core/services/auth_service.dart`)

**新增模型类：**
- `Token` 类：包含 `accessToken`、`refreshToken` 字段，支持序列化/反序列化
- `ApiResponse<T>` 泛型类：统一响应格式，包含 `code`、`message`、`data` 字段

**修改 `register` 方法：**
- 参数从 `{phone, password, code}` 改为 `{phone, password, nickname}`
- 返回类型从 `Future<User>` 改为 `Future<ApiResponse<Map<String, dynamic>>>`
- 注册成功时自动创建默认家庭，用户角色为 `admin`

**User 类新增方法：**
- `toJson()`: 序列化用户信息
- `fromJson()`: 反序列化用户信息

### 2. AuthProvider (`lib/core/providers/auth_provider.dart`)

**修改 `register` 方法：**
- 参数从 `{phone, password, code}` 改为 `{phone, password, nickname}`
- 处理新的 `ApiResponse` 响应格式
- 注册成功后直接进入首页（家庭已自动创建）

### 3. RegisterPage (`lib/presentation/auth/register_page.dart`)

**修改内容：**
- 移除验证码输入逻辑（服务端处理）
- 添加昵称输入框
- 更新注册调用参数

## 影响范围

- 注册流程：用户注册时不再需要验证码，直接输入手机号、昵称、密码即可完成注册
- 注册成功后自动进入首页（无需创建家庭步骤）

## 测试点

1. 注册接口参数验证
   - 手机号格式验证
   - 密码长度验证（至少6位）
   - 昵称长度验证（1-50字符）

2. 响应格式验证
   - 成功响应：`{code: 200, message: 'success', data: {user, access_token, refresh_token}}`
   - 失败响应：`{code: 400, message: '错误描述', data: null}`

3. 自动创建家庭验证
   - 注册成功后用户的 `familyId` 不为空
   - 用户的 `familyRole` 为 `admin`

4. UI 验证
   - 注册页面显示手机号、昵称、密码输入框
   - 注册按钮正常触发注册流程
   - 错误提示正确显示

## 注意事项

- 服务端需要实现相应的注册接口
- 验证码逻辑移至服务端处理