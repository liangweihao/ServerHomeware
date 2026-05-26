# 用户认证与个人信息编辑功能变更记录

## 概述

实现完整的用户认证和个人信息编辑功能，包括登录接口、用户信息获取、头像分配、首页头像交互修复和编辑资料页。

## 改动点

### 1. AuthService (`lib/core/services/auth_service.dart`)

**修改登录接口 `loginWithPassword`：**
- 返回类型从 `Future<User>` 改为 `Future<ApiResponse<Map<String, dynamic>>>`
- 响应数据包含 `user`、`access_token`、`refresh_token`
- 添加自动分配默认头像逻辑

**新增用户信息获取接口 `getCurrentUser`：**
- 获取当前登录用户信息
- 返回 `ApiResponse<Map<String, dynamic>>` 格式

**新增用户信息更新接口 `updateProfile`：**
- 更新用户昵称、头像、家庭内称呼
- 返回更新后的用户信息

**新增头像分配逻辑：**
- 添加 10 种预设渐变色头像颜色
- 静态方法 `getAvatarColorIndex`：根据用户标识获取头像颜色索引
- 静态方法 `getAvatarColors`：获取指定索引的头像颜色对

### 2. AuthProvider (`lib/core/providers/auth_provider.dart`)

**修改登录处理 `loginWithPassword`：**
- 处理新的 `ApiResponse` 响应格式
- 从响应中提取 `access_token` 和 `refresh_token`
- 提取用户信息并保存到 SharedPreferences

**新增用户信息更新 `updateProfile`：**
- 调用 AuthService.updateProfile
- 更新本地存储的用户信息

### 3. 首页头像交互 (`lib/presentation/home/home_page.dart`)

**添加头像点击功能：**
- 将静态 CircleAvatar 替换为渐变色头像
- 添加 GestureDetector 包装
- 点击后跳转到 `/profile/edit` 编辑资料页

**添加真实头像显示：**
- 从 AuthProvider 获取用户信息
- 根据昵称或手机号显示首字符
- 使用渐变色背景显示头像

### 4. 个人信息页 (`lib/presentation/profile/profile_page.dart`)

**显示真实用户数据：**
- 添加 AuthProvider 导入
- 从 AuthProvider 获取用户信息
- 显示用户昵称和角色
- 添加 `_buildAvatar` 方法显示渐变色头像
- 添加 `_getRoleText` 方法获取角色文本
- 点击编辑按钮跳转到编辑资料页

### 5. 编辑资料页 (`lib/presentation/profile/edit_profile_page.dart`)

**新建页面，包含以下功能：**
- 显示和编辑用户头像（点击更换）
- 显示和编辑昵称
- 显示手机号（脱敏显示）
- 显示和编辑家庭内称呼
- 保存功能
- 修改密码入口（TODO）
- 注销账号入口（TODO）
- 退出登录功能

**头像选择器：**
- 底部弹窗样式
- 5列网格显示 10 种渐变色选项
- 点击选择新颜色

### 6. 路由配置 (`lib/core/router/app_router.dart`)

**添加编辑资料页路由：**
- 路径：`/profile/edit`
- 名称：`editProfile`
- 动画：从右侧滑入

## 影响范围

- 登录流程：登录后用户自动拥有默认头像
- 首页：用户头像显示真实数据，点击可编辑
- 个人中心：显示真实用户信息
- 新增编辑资料页：用户可编辑个人信息

## 测试点

1. **登录功能测试**
   - 使用正确的手机号和密码登录
   - 验证返回包含 `access_token` 和 `refresh_token`
   - 验证用户信息正确保存
   - 验证自动分配默认头像

2. **头像显示测试**
   - 登录后首页头像显示用户昵称首字
   - 头像使用渐变背景色
   - 不同用户显示不同颜色

3. **头像点击测试**
   - 点击首页头像跳转到编辑资料页
   - 点击个人中心编辑按钮跳转到编辑资料页

4. **编辑资料测试**
   - 显示当前用户信息
   - 修改昵称后保存成功
   - 修改头像颜色后保存成功
   - 修改后数据正确更新

5. **退出登录测试**
   - 点击退出登录按钮
   - 弹出确认对话框
   - 确认后清除本地数据并跳转登录页

## 默认头像颜色方案

10 种渐变色组合：
1. 紫蓝渐变 (0xFF667eea → 0xFF764ba2)
2. 粉红渐变 (0xFFf093fb → 0xFFf5576c)
3. 蓝色渐变 (0xFF4facfe → 0xFF00f2fe)
4. 绿蓝渐变 (0xFF43e97b → 0xFF38f9d7)
5. 橙粉渐变 (0xFFfa709a → 0xFFfee140)
6. 深蓝渐变 (0xFF30cfd0 → 0xFF330867)
7. 浅粉渐变 (0xFFa8edea → 0xFFfed6e3)
8. 暖橙渐变 (0xFFffecd2 → 0xFFfcb69f)
9. 玫红渐变 (0xFFff9a9e → 0xFFfecfef)
10. 紫粉渐变 (0xFFa18cd1 → 0xFFfbc2eb)

头像生成规则：根据用户手机号 hashCode 分配固定颜色，同一用户始终显示相同颜色。

## 注意事项

- 头像颜色索引存储在 `avatar` 字段，格式为 `avatar_X`（X 为颜色索引）
- 用户信息变更后会自动更新 AuthProvider 状态
- 退出登录需要清除所有本地存储
- 编辑页面需要添加加载状态和错误处理
- 遵循项目编码规范，添加必要的注释