# 用户认证与个人信息编辑功能实现计划

## 一、概述

根据服务端文档和交互设计文档，实现完整的用户认证和个人信息编辑功能，包括：
1. 客户端登录接口实现（与 `/api/v1/auth/login` 一致）
2. 用户信息获取接口（`/api/v1/users/me`）
3. 头像默认分配逻辑
4. 首页用户头像交互修复
5. 用户信息编辑页完整实现

## 二、当前状态分析

### 2.1 登录接口现状
- **文件**：`lib/core/services/auth_service.dart`
- **现状**：`loginWithPassword` 方法返回 `Future<User>`，与服务端规范不一致
- **服务端规范**：
  - Request: `{phone, password}`
  - Response: `{code, message, data: {user, access_token, refresh_token}}`

### 2.2 用户信息现状
- **文件**：`lib/core/providers/auth_provider.dart`
- **User 模型**：`lib/core/services/auth_service.dart`
- **现状**：缺少 `avatar` 字段存储，未实现用户头像默认分配

### 2.3 首页头像现状
- **文件**：`lib/presentation/home/home_page.dart` 第59-71行
- **现状**：头像为静态图标，无点击事件，无法显示真实用户头像

### 2.4 个人信息页现状
- **文件**：`lib/presentation/profile/profile_page.dart`
- **现状**：
  - 显示"用户"、"管理员"等静态文本
  - 缺少头像显示
  - 编辑按钮为 TODO
  - 缺少用户信息更新逻辑

## 三、待实现功能

### 3.1 修改登录接口（AuthService.loginWithPassword）
- **文件**：`lib/core/services/auth_service.dart`
- **改动**：
  1. 修改返回类型为 `Future<ApiResponse<Map<String, dynamic>>>`
  2. 响应数据包含 `user`、`access_token`、`refresh_token`
  3. 如果用户无头像，自动分配默认头像（使用预设头像 URL）

### 3.2 修改登录处理（AuthProvider.loginWithPassword）
- **文件**：`lib/core/providers/auth_provider.dart`
- **改动**：
  1. 处理新的 `ApiResponse` 响应格式
  2. 从响应中提取 `access_token` 和 `refresh_token`
  3. 提取用户信息并保存到 SharedPreferences

### 3.3 添加用户信息获取接口
- **文件**：`lib/core/services/auth_service.dart`
- **新增**：
  1. 添加 `getCurrentUser()` 方法（`/api/v1/users/me`）
  2. 返回当前登录用户信息
  3. 自动分配默认头像逻辑

### 3.4 头像默认分配逻辑
- **文件**：`lib/core/services/auth_service.dart`
- **新增**：
  1. 定义预设头像列表（8-10个好看的头像 URL）
  2. 添加 `_getDefaultAvatar()` 方法
  3. 如果用户无头像，根据昵称或手机号分配固定头像

### 3.5 修复首页头像交互
- **文件**：`lib/presentation/home/home_page.dart`
- **改动**：
  1. 将静态 CircleAvatar 替换为用户信息显示
  2. 添加 GestureDetector 或 InkWell 包装
  3. 点击后跳转到个人面板或编辑页
  4. 从 AuthProvider 获取用户信息并显示

### 3.6 实现用户信息编辑页
- **新建文件**：`lib/presentation/profile/edit_profile_page.dart`
- **页面功能**：
  1. 显示当前用户头像（可点击更换）
  2. 显示和编辑昵称
  3. 显示手机号（不可编辑）
  4. 家庭内称呼编辑
  5. 保存功能
  6. 修改密码入口
  7. 退出登录功能

### 3.7 更新个人信息页显示
- **文件**：`lib/presentation/profile/profile_page.dart`
- **改动**：
  1. 从 AuthProvider 获取用户信息
  2. 显示真实头像和昵称
  3. 点击编辑按钮跳转到编辑页

### 3.8 添加用户信息更新接口
- **文件**：`lib/core/services/auth_service.dart`
- **新增**：`updateProfile({nickname, avatar, familyNickname})` 方法

### 3.9 更新 AuthProvider
- **文件**：`lib/core/providers/auth_provider.dart`
- **新增**：
  1. `updateProfile()` 方法
  2. `logout()` 方法完善
  3. `getCurrentUser()` 方法
  4. 从本地存储加载头像逻辑

## 四、文件清单

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `lib/core/services/auth_service.dart` | 修改 | 登录接口、用户信息、头像分配 |
| `lib/core/providers/auth_provider.dart` | 修改 | 登录处理、用户信息管理 |
| `lib/presentation/home/home_page.dart` | 修改 | 修复头像交互 |
| `lib/presentation/profile/profile_page.dart` | 修改 | 显示真实用户信息 |
| `lib/presentation/profile/edit_profile_page.dart` | 新建 | 用户信息编辑页 |
| `lib/core/router/app_router.dart` | 修改 | 添加编辑页路由 |

## 五、实现步骤

### 步骤 1：修改 AuthService - 登录接口
1. 修改 `loginWithPassword` 返回类型
2. 添加默认头像分配逻辑
3. 添加 `getCurrentUser()` 方法

### 步骤 2：修改 AuthProvider - 登录处理
1. 更新 `loginWithPassword` 处理新响应格式
2. 添加 `updateProfile()` 方法
3. 完善 `logout()` 方法

### 步骤 3：修复首页头像交互
1. 添加用户信息获取
2. 显示真实头像或默认头像
3. 添加点击事件

### 步骤 4：更新个人信息页
1. 从 AuthProvider 获取用户信息
2. 显示真实数据

### 步骤 5：创建编辑资料页
1. 创建 `edit_profile_page.dart`
2. 实现头像选择器
3. 实现昵称编辑
4. 实现家庭内称呼编辑
5. 添加保存功能

### 步骤 6：添加用户信息更新接口
1. 在 AuthService 添加 `updateProfile()`
2. 在 AuthProvider 添加对应的调用方法

### 步骤 7：添加路由配置
1. 在 `app_router.dart` 添加编辑页路由

## 六、默认头像方案

### 6.1 预设头像列表
使用纯色渐变背景 + 首字母的圆形头像，生成 10 个预设头像：
- 10 种不同的渐变色组合
- 白色首字母居中
- 无需网络加载，离线可用

### 6.2 头像生成逻辑
```dart
Color _getAvatarColor(String text) {
  final colors = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // 紫蓝渐变
    [Color(0xFFf093fb), Color(0xFFf5576c)], // 粉红渐变
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // 蓝色渐变
    [Color(0xFF43e97b), Color(0xFF38f9d7)], // 绿蓝渐变
    [Color(0xFFfa709a), Color(0xFFfee140)], // 橙粉渐变
    [Color(0xFF30cfd0), Color(0xFF330867)], // 深蓝渐变
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // 浅粉渐变
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // 暖橙渐变
    [Color(0xFFff9a9e), Color(0xFFfecfef)], // 玫红渐变
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)], // 紫粉渐变
  ];
  final index = text.hashCode.abs() % colors.length;
  return colors[index];
}

String _getInitial(String? nickname, String phone) {
  final text = nickname ?? phone.substring(phone.length - 4);
  return text[0].toUpperCase();
}
```

## 七、用户信息编辑页布局

```
┌─────────────────────────────────────────┐
│ ← 编辑资料                       保存    │
│─────────────────────────────────────────│
│                                         │
│              ┌────────┐                 │
│              │        │                 │
│              │  👤 📷 │                 │  ← 点击更换头像
│              │        │                 │
│              └────────┘                 │
│           点击更换头像                   │
│                                         │
│  昵称                                   │
│  ┌─────────────────────────────────┐    │
│  │ 妈妈                            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  手机号                                 │
│  ┌─────────────────────────────────┐    │
│  │ 138****1234            [更换]   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  家庭内称呼                             │
│  ┌─────────────────────────────────┐    │
│  │ 妈妈                            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  修改密码                            >  │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │        🗑️ 注销账号              │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

## 八、验证步骤

1. **登录功能验证**：
   - 使用正确的手机号和密码登录
   - 验证返回包含 `access_token` 和 `refresh_token`
   - 验证用户信息正确保存

2. **头像显示验证**：
   - 登录后首页头像显示用户昵称首字
   - 头像使用渐变背景色
   - 不同用户显示不同颜色

3. **头像点击验证**：
   - 点击首页头像有按压缩放反馈
   - 点击后跳转到编辑资料页

4. **编辑资料验证**：
   - 显示当前用户信息
   - 修改昵称后保存成功
   - 修改后数据正确更新

5. **退出登录验证**：
   - 点击退出登录按钮
   - 弹出确认对话框
   - 确认后清除本地数据并跳转登录页

## 九、注意事项

1. 所有用户信息变更后需要更新 AuthProvider 中的状态
2. 头像选择时使用本地图片选择器
3. 退出登录需要清除所有本地存储
4. 编辑页面需要添加加载状态和错误处理
5. 遵循项目编码规范，添加必要的注释