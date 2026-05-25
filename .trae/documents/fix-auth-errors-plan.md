# 修复登录/认证模块错误计划

## 问题概览

需要修复以下问题：
1. 将所有 `AppColors.white` 替换为 `AppColors.card`
2. 修复 `AuthService.sendVerifyCode` 调用（从位置参数改为命名参数）
3. 修复 `withOpacity` 为 `withValues` 的 deprecated 调用

## 修改文件列表

### 1. auth 文件
- `lib/presentation/auth/login_page.dart`
- `lib/presentation/auth/register_page.dart`
- `lib/presentation/auth/verify_code_page.dart`
- `lib/presentation/auth/forgot_password_page.dart`
- `lib/presentation/auth/splash_page.dart`
- `lib/presentation/auth/welcome_page.dart`
- `lib/presentation/auth/create_family_page.dart`
- `lib/presentation/auth/join_family_page.dart`

### 2. widgets 文件
- `lib/presentation/auth/widgets/phone_input.dart`
- `lib/presentation/auth/widgets/code_input.dart`
- `lib/presentation/auth/widgets/password_input.dart`
- `lib/presentation/auth/widgets/auth_button.dart`

## 具体修复内容

### 1. 颜色常量替换
在所有文件中搜索 `AppColors.white`，替换为 `AppColors.card`

### 2. AuthService.sendVerifyCode 调用修复
在以下文件中修复调用：
- `register_page.dart:65` - 将位置参数改为命名参数
- `verify_code_page.dart:61` - 将位置参数改为命名参数  
- `forgot_password_page.dart:65` - 将位置参数改为命名参数

### 3. withOpacity 替换为 withValues
在以下文件中替换：
- `phone_input.dart:67`
- `code_input.dart:181`
- `password_input.dart:120`

## 预期结果
所有文件编译通过，没有错误和 deprecated 警告
