import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/phone_input.dart';
import 'widgets/password_input.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_cartoon_wrap.dart';

/// 注册页面
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _phoneController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _phoneError;
  String? _nicknameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 验证输入
  bool _validate() {
    bool isValid = true;
    setState(() {
      _nicknameError = null;
      _passwordError = null;
    });

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _nicknameError = '请输入昵称';
      });
      isValid = false;
    } else if (nickname.length > 50) {
      setState(() {
        _nicknameError = '昵称不能超过50个字符';
      });
      isValid = false;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = '请设置密码';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = '密码至少6位';
      });
      isValid = false;
    }

    return isValid;
  }

  /// 注册
  Future<void> _register() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).register(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            nickname: _nicknameController.text.trim(),
          );

      if (mounted) {
        context.go('/');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[RegisterPage] _register',
        userMessage: '注册失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              _buildTitle(),
              const SizedBox(height: 40),
              wrapAuthFormSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhoneInput(
                      controller: _phoneController,
                      errorText: _phoneError,
                      enabled: !_isLoading,
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() {
                            _phoneError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nicknameController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: '昵称',
                        hintText: '请输入昵称',
                        errorText: _nicknameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.danger),
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: AppColors.gray900),
                      onChanged: (_) {
                        if (_nicknameError != null) {
                          setState(() {
                            _nicknameError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    PasswordInput(
                      controller: _passwordController,
                      errorText: _passwordError,
                      enabled: !_isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 注册按钮
              AuthButton(
                label: '注册',
                onPressed: _register,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              // 协议
              _buildAgreement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          authPageTitle('创建账号', emoji: '✨'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '加入 HomeStock，开始管理你的家庭物品',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray500,
              ),
        ),
      ],
    );
  }

  Widget _buildAgreement() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '注册即代表同意',
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
