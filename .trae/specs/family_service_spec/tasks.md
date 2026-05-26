# 家庭信息服务实现 - 任务分解与优先级

## [x] Task 1: 更新 FamilyService 获取当前家庭接口
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 修改 `getCurrentFamily()` 方法，与服务端 `GET /api/v1/families/current` 接口对接
  - 添加 HTTP 请求逻辑，使用 auth token
  - 处理响应数据结构
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3, AC-4, AC-5
- **Test Requirements**:
  - `programmatic` TR-1.1: 调用成功时返回 ApiResponse(code=200)
  - `programmatic` TR-1.2: 返回数据包含 family.id, family.name, members 列表, invite_code
  - `programmatic` TR-1.3: 网络错误时返回 ApiResponse(code != 200)
- **Notes**: 需要从 AuthService 获取 access_token

## [ ] Task 2: 更新 FamilyService 刷新邀请码接口
- **Priority**: P0
- **Depends On**: Task 1
- **Description**: 
  - 修改 `refreshInviteCode()` 方法，与服务端 `POST /api/v1/families/current/refresh-invite-code` 接口对接
  - 添加权限检查（仅 owner/admin）
- **Acceptance Criteria Addressed**: AC-4, AC-5
- **Test Requirements**:
  - `programmatic` TR-2.1: 调用成功返回新的邀请码
  - `programmatic` TR-2.2: 无权限时返回错误响应
- **Notes**: 需要验证用户角色

## [ ] Task 3: 更新个人面板页面使用真实 API
- **Priority**: P1
- **Depends On**: Task 1
- **Description**: 
  - 修改 `profile_panel_page.dart` 使用 FamilyService 的真实 API
  - 添加加载状态和错误处理
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 页面加载时显示 loading 状态
  - `human-judgement` TR-3.2: 加载完成后正确显示家庭信息和成员列表
- **Notes**: 确保错误状态下显示友好提示

## [ ] Task 4: 添加日志记录
- **Priority**: P2
- **Depends On**: Task 1, Task 2
- **Description**: 
  - 在 FamilyService 中添加关键流程日志
  - 记录成功请求和错误信息
- **Acceptance Criteria Addressed**: NFR-1
- **Test Requirements**:
  - `human-judgement` TR-4.1: 关键流程有日志输出
  - `human-judgement` TR-4.2: 错误场景有 WARN/ERROR 日志
- **Notes**: 遵循项目日志规范

## [ ] Task 5: 代码审查和优化
- **Priority**: P2
- **Depends On**: Task 1, Task 2, Task 3
- **Description**: 
  - 检查代码符合项目编码规范
  - 优化代码结构和可读性
- **Acceptance Criteria Addressed**: 代码质量
- **Test Requirements**:
  - `human-judgement` TR-5.1: flutter analyze 无错误
  - `human-judgement` TR-5.2: 代码结构清晰，注释完整
- **Notes**: 使用项目代码风格规范