# 客户端注册接口实现 - 实现计划

## [x] Task 1: 创建 Token 模型类
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 创建 Token 类，包含 access_token、refresh_token 字段
  - 添加 copyWith 方法
- **Acceptance Criteria Addressed**: [AC-3]
- **Test Requirements**:
  - `programmatic` TR-1.1: Token 类包含 access_token 和 refresh_token 字段
  - `programmatic` TR-1.2: copyWith 方法正确复制对象

## [x] Task 2: 创建统一响应模型类
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 创建 ApiResponse 泛型类，包含 code、message、data 字段
  - 添加 fromJson 工厂方法
- **Acceptance Criteria Addressed**: [AC-5]
- **Test Requirements**:
  - `programmatic` TR-2.1: ApiResponse 包含 code、message、data 字段
  - `programmatic` TR-2.2: fromJson 能正确解析 JSON

## [x] Task 3: 修改 AuthService.register 方法参数
- **Priority**: P0
- **Depends On**: Task 1, Task 2
- **Description**: 
  - 将 register 方法参数从 {phone, password, code} 改为 {phone, password, nickname}
  - 移除 code 参数验证
  - 添加 nickname 参数验证
- **Acceptance Criteria Addressed**: [AC-1]
- **Test Requirements**:
  - `programmatic` TR-3.1: register 方法接受 phone、password、nickname 参数
  - `programmatic` TR-3.2: 不接受 code 参数

## [x] Task 4: 修改注册响应返回 Token 信息
- **Priority**: P0
- **Depends On**: Task 1, Task 2, Task 3
- **Description**: 
  - 修改 register 方法返回类型为 ApiResponse<Map<String, dynamic>>
  - 响应数据包含 user、access_token、refresh_token
- **Acceptance Criteria Addressed**: [AC-2, AC-3]
- **Test Requirements**:
  - `programmatic` TR-4.1: 注册成功返回包含 user 的响应
  - `programmatic` TR-4.2: 注册成功返回包含 access_token 和 refresh_token 的响应

## [x] Task 5: 实现自动创建默认家庭
- **Priority**: P0
- **Depends On**: Task 4
- **Description**: 
  - 注册成功时自动创建默认家庭
  - 用户信息中设置 familyId 和 familyRole
- **Acceptance Criteria Addressed**: [AC-4]
- **Test Requirements**:
  - `programmatic` TR-5.1: 注册成功后用户的 familyId 不为空
  - `programmatic` TR-5.2: 用户的 familyRole 为 admin

## [x] Task 6: 更新 AuthProvider 调用
- **Priority**: P1
- **Depends On**: Task 3, Task 4
- **Description**: 
  - 更新 AuthProvider 中调用 register 的代码
  - 处理新的响应格式
- **Acceptance Criteria Addressed**: [AC-1, AC-2, AC-3]
- **Test Requirements**:
  - `programmatic` TR-6.1: AuthProvider.register 调用正确传递参数
  - `programmatic` TR-6.2: 正确处理包含 token 的响应

## [x] Task 7: 更新 RegisterPage UI 调用
- **Priority**: P1
- **Depends On**: Task 3
- **Description**: 
  - 更新注册页面调用 register 方法的代码
  - 移除验证码输入逻辑（服务端处理）
- **Acceptance Criteria Addressed**: [AC-1]
- **Test Requirements**:
  - `human-judgement` TR-7.1: 注册页面正确传递 nickname 参数

## [x] Task 8: 编写变更记录
- **Priority**: P2
- **Depends On**: All previous tasks
- **Description**: 
  - 在 lwh/code_changed 目录创建变更记录文档
- **Acceptance Criteria Addressed**: [NFR-2]
- **Test Requirements**:
  - `human-judgement` TR-8.1: 变更记录文档完整清晰