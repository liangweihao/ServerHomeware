import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_cartoon_wrap.dart';
import 'widgets/phone_input.dart';
import 'widgets/password_input.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _phoneError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 验证输入
  bool _validate() {
    bool isValid = true;
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _phoneError = '请输入手机号';
      });
      isValid = false;
    } else if (phone.length != 11 || !phone.startsWith('1')) {
      setState(() {
        _phoneError = '请输入正确的手机号';
      });
      isValid = false;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = '请输入密码';
      });
      isValid = false;
    }

    return isValid;
  }

  /// 密码登录
  Future<void> _loginWithPassword() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).loginWithPassword(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        context.go('/');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[LoginPage] _loginWithPassword',
        userMessage: '登录失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 跳转到验证码登录
  void _goToVerifyCode() {
    context.push('/verify-code');
  }

  /// 跳转到忘记密码
  void _goToForgotPassword() {
    context.push('/forgot-password');
  }

  /// 跳转到注册
  void _goToRegister() {
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Logo 区域
                _buildLogoSection(),
                const SizedBox(height: 40),
                // 标题
                _buildTitleSection(),
                const SizedBox(height: 40),
                // 表单区域 — 卡通主题贴纸卡片
                wrapAuthFormSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormSection(),
                      const SizedBox(height: 20),
                      _buildForgotPassword(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 登录按钮
                AuthButton(
                  label: '登录',
                  onPressed: _loginWithPassword,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
                // 验证码登录按钮
                _buildVerifyCodeLoginButton(),
                const SizedBox(height: 32),
                // 分割线
                _buildDivider(),
                const SizedBox(height: 24),
                // 去注册
                _buildRegisterLink(),
                const SizedBox(height: 24),
                // 协议
                _buildAgreement(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logo 区域
  Widget _buildLogoSection() {
    return Column(
      children: [
        const Text(
          '🏠📦',
          style: TextStyle(fontSize: 56),
        ),
        const SizedBox(height: 12),
        Text(
          'HomeStock',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }

  /// 标题区域
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          authPageTitle('欢迎回来', emoji: '👋'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '登录后同步你的家庭数据',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray500,
              ),
        ),
      ],
    );
  }

  /// 表单区域
  Widget _buildFormSection() {
    return Column(
      children: [
        // 手机号输入
        PhoneInput(
          controller: _phoneController,
          errorText: _phoneError,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 20),
        // 密码输入
        PasswordInput(
          controller: _passwordController,
          errorText: _passwordError,
          enabled: !_isLoading,
        ),
      ],
    );
  }

  /// 忘记密码
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _goToForgotPassword,
        child: Text(
          '忘记密码?',
          style: TextStyle(
            fontSize: 14,
            color: _isLoading ? AppColors.gray400 : AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// 验证码登录按钮
  Widget _buildVerifyCodeLoginButton() {
    return AuthButton(
      label: '📱 验证码登录',
      variant: AuthButtonVariant.outline,
      onPressed: _isLoading ? null : _goToVerifyCode,
      enabled: !_isLoading,
    );
  }

  /// 分割线
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.gray300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.gray300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// 去注册链接
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray700,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _goToRegister,
          child: Text(
            '立即注册',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isLoading ? AppColors.gray400 : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// 协议
  Widget _buildAgreement() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '登录即代表同意',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray400,
              ),
            ),
            TextSpan(
              text: '《用户协议》',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
            TextSpan(
              text: '和',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray400,
              ),
            ),
            TextSpan(
              text: '《隐私政策》',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
