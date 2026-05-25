# 登录注册模块实施计划

## 一、项目研究结论

### 1.1 现有架构
- **状态管理**: 使用 flutter_riverpod
- **路由管理**: 使用 go_router
- **本地存储**: 使用 drift 数据库 + SharedPreferences
- **现有页面**: 首页、物品页、提醒页、我的页等基础功能页面
- **现有组件**: AppButton、AppEmptyState 等基础组件

### 1.2 设计规范
- **颜色系统**: 主色 #2196F3 (Primary-500)，符合 Material Design
- **圆角**: 输入框/按钮 8px，卡片 12px
- **字体**: H3-Semibold (20px), Body-Regular (14px) 等
- **间距**: 基础间距 16px，输入框间距 20px

### 1.3 需要补充的设计规范
根据文档需要在 AppColors 中补充完整的灰色体系：
- Gray-50 (#FAFAFA)
- Gray-100 (#F5F5F5)
- Gray-200 (#EEEEEE)
- Gray-300 (#E0E0E0)
- Gray-400 (#BDBDBD)
- Gray-500 (#9E9E9E)
- Gray-700 (#616161)
- Gray-900 (#212121)

---

## 二、文件和模块修改清单

### 2.1 新增文件

#### 2.1.1 认证相关页面 (lib/presentation/auth/)
- `splash_page.dart` - 启动页
- `welcome_page.dart` - 欢迎引导页（3屏）
- `login_page.dart` - 登录页
- `register_page.dart` - 注册页
- `verify_code_page.dart` - 验证码输入页
- `forgot_password_page.dart` - 忘记密码页
- `create_family_page.dart` - 创建家庭页
- `join_family_page.dart` - 加入家庭页

#### 2.1.2 认证组件 (lib/presentation/auth/widgets/)
- `phone_input.dart` - 手机号输入组件（带区号）
- `code_input.dart` - 验证码输入组件（6格独立方框）
- `password_input.dart` - 密码输入组件（带可见切换+强度指示）
- `auth_button.dart` - 认证按钮（带loading状态）

#### 2.1.3 认证服务 (lib/core/services/)
- `auth_service.dart` - 认证 API 服务（模拟）

#### 2.1.4 认证状态管理 (lib/core/providers/)
- `auth_provider.dart` - 认证状态 Provider

### 2.2 修改文件

#### 2.2.1 常量文件
- `app_colors.dart` - 补充完整的灰色体系
- `app_typography.dart` - 补充字体样式（如有需要）

#### 2.2.2 路由配置
- `app_router.dart` - 添加认证相关路由和路由守卫

#### 2.2.3 入口文件
- `main.dart` - 修改启动流程，添加 Splash 作为初始路由

#### 2.2.4 文档
- `doc/figma 组件.md` - 补充登录注册相关组件描述

#### 2.2.5 变更记录
- 创建 `lwh/code_changed/phase7_login_register.md`

---

## 三、实施步骤

### 阶段 1: 基础准备
1. **更新 AppColors** - 补充完整的灰色体系
2. **创建 AuthService** - 模拟登录注册 API
3. **创建 AuthProvider** - 认证状态管理（包含 Token 存储）

### 阶段 2: 认证组件
4. **创建 PhoneInput** - 手机号输入组件（带区号前缀）
5. **创建 CodeInput** - 6格验证码输入组件
6. **创建 PasswordInput** - 密码输入组件（含强度条）
7. **创建 AuthButton** - 认证按钮（带loading状态）

### 阶段 3: 基础页面
8. **创建 SplashPage** - 启动页（1.5秒 + Logo动画）
9. **创建 WelcomePage** - 欢迎引导页（3屏 PageView）

### 阶段 4: 认证流程页面
10. **创建 LoginPage** - 登录页（密码登录 + 验证码登录）
11. **创建 RegisterPage** - 注册页（完整表单）
12. **创建 VerifyCodePage** - 验证码输入页
13. **创建 ForgotPasswordPage** - 忘记密码页

### 阶段 5: 家庭设置页面
14. **创建 CreateFamilyPage** - 创建家庭页（含房间选择）
15. **创建 JoinFamilyPage** - 加入家庭页（邀请码输入）

### 阶段 6: 路由和集成
16. **更新 AppRouter** - 添加认证路由、路由守卫
17. **更新 Main.dart** - 修改启动流程
18. **更新 AddMethodSheet** - 修正为 push 而非 go

### 阶段 7: 文档
19. **更新 Figma组件文档** - 补充登录注册相关组件
20. **创建变更记录文档** - 记录本次改动

---

## 四、潜在依赖和注意事项

### 4.1 依赖
- `shared_preferences` - 已有，用于 Token 存储
- `go_router` - 已有，用于路由
- `flutter_riverpod` - 已有，用于状态管理
- **可能需要** `lottie` - 如果需要动画（文档中提到 Lottie，但示例中使用简单 emoji）

### 4.2 注意事项
1. **路由守卫逻辑**:
   - 未登录访问主页 → 重定向到登录页
   - 已登录访问登录页 → 重定向到主页
   - 首次安装时显示欢迎页

2. **数据持久化**:
   - Token 使用 SharedPreferences 存储
   - 是否首次启动使用 SharedPreferences 标记

3. **输入验证**:
   - 手机号: 11位，1开头
   - 密码: ≥8位，含字母+数字
   - 验证码: 6位数字
   - 邀请码: 8位字母+数字

4. **模拟 API**:
   - 文档明确说明不要实现真实 API，使用 Future.delayed 模拟
   - 模拟网络延迟（约1-2秒）
   - 模拟成功/失败场景

---

## 五、风险处理

### 5.1 风险1: 路由配置复杂
**处理方式**: 先画出路由状态图，确保各状态转换逻辑正确，再编码。

### 5.2 风险2: 键盘弹出导致溢出
**处理方式**: 所有表单页面使用 SingleChildScrollView 包裹。

### 5.3 风险3: 状态管理复杂
**处理方式**: 使用 Riverpod AsyncValue 处理认证状态，确保加载/错误/成功状态都有对应的 UI。

---

## 六、验证和测试要点

### 6.1 功能测试
- [ ] 首次安装启动流程（Splash → 欢迎页 → 登录页）
- [ ] 正常登录流程（密码登录）
- [ ] 验证码登录流程
- [ ] 注册流程（含创建家庭）
- [ ] 加入家庭流程
- [ ] 忘记密码流程
- [ ] 已登录用户再次启动直接进入主页
- [ ] 路由守卫正常工作
- [ ] 输入验证提示正确显示
- [ ] Loading 状态正常显示
- [ ] 错误状态正常显示

### 6.2 UI 测试
- [ ] 所有页面符合设计规范（颜色、圆角、间距）
- [ ] 输入框样式正确（默认/聚焦/错误状态）
- [ ] 按钮样式正确（默认/禁用/Loading 状态）
- [ ] 键盘弹出时页面不溢出
- [ ] 欢迎页动画正常
- [ ] 密码强度条正确显示

### 6.3 兼容性测试
- [ ] iOS 设备测试
- [ ] Android 设备测试
- [ ] 不同屏幕尺寸测试
