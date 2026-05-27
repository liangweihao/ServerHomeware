# Token有效性检测与过期处理 - 实现计划

## [x] Task 1: 在AuthService中添加token验证接口
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 在AuthService中添加`validateToken()`方法
  - 调用服务端`GET /api/v1/users/me`接口验证token有效性
  - 添加响应日志打印
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: 调用validateToken返回200表示token有效
  - `programmatic` TR-1.2: 调用validateToken返回401表示token无效
- **Notes**: 服务端已存在`GET /api/v1/users/me`接口

## [x] Task 2: 更新Splash页面实现启动时token验证
- **Priority**: P0
- **Depends On**: Task 1
- **Description**: 
  - 更新SplashPage添加token验证逻辑
  - 根据验证结果决定跳转页面（首页/登录页/欢迎页）
  - 显示加载状态
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3
- **Test Requirements**:
  - `programmatic` TR-2.1: 有有效token时跳转首页
  - `programmatic` TR-2.2: token无效时跳转登录页并显示提示
  - `programmatic` TR-2.3: 无token时跳转欢迎页
- **Notes**: 需要处理三种状态：有有效token、有无效token、无token

## [x] Task 3: 创建统一的响应处理工具类
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 创建统一的HTTP响应处理工具类
  - 自动检测401/403响应码
  - 提供全局认证错误处理机制
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-3.1: 响应码401时自动触发logout
  - `programmatic` TR-3.2: 响应码403时自动触发logout
- **Notes**: 可考虑在ApiService基类中添加通用方法

## [x] Task 4: 更新各Service的响应处理
- **Priority**: P1
- **Depends On**: Task 3
- **Description**: 
  - 更新AuthService、FamilyService、ContributionService的响应处理
  - 在_handleResponse中集成统一的认证错误处理
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-4.1: 所有API请求收到401时触发logout
  - `programmatic` TR-4.2: 所有API请求收到403时触发logout
- **Notes**: 需要修改多个服务文件

## [x] Task 5: 更新AuthGuard增强跳转逻辑
- **Priority**: P1
- **Depends On**: Task 3
- **Description**: 
  - 增强AuthGuard的跳转逻辑
  - 确保token过期时正确跳转登录页面
  - 添加友好的错误提示
- **Acceptance Criteria Addressed**: AC-4, AC-5
- **Test Requirements**:
  - `programmatic` TR-5.1: 已在登录页面时不重复跳转
  - `human-judgement` TR-5.2: token过期显示友好提示
- **Notes**: 需要添加SnackBar提示

## [x] Task 6: 更新AuthNotifier添加logout方法
- **Priority**: P1
- **Depends On**: None
- **Description**: 
  - 在AuthNotifier中添加完善的logout方法
  - 清除本地token和用户信息
  - 更新认证状态为unauthenticated
- **Acceptance Criteria Addressed**: AC-3, AC-4
- **Test Requirements**:
  - `programmatic` TR-6.1: logout后本地token被清除
  - `programmatic` TR-6.2: logout后auth状态变为unauthenticated
- **Notes**: 需要确保所有相关数据都被清除