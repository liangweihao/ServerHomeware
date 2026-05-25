import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import 'widgets/phone_input.dart';
import 'widgets/code_input.dart';
import 'widgets/password_input.dart';
import 'widgets/auth_button.dart';

/// 注册页面
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _phoneError;
  String? _codeError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _phoneError = '请输入手机号';
      });
      return;
    } else if (phone.length != 11 || !phone.startsWith('1')) {
      setState(() {
        _phoneError = '请输入正确的手机号';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _phoneError = null;
    });

    try {
      await AuthService().sendVerifyCode(phone: phone, purpose: 'register');

      setState(() {
        _codeSent = true;
        _countdown = 60;
      });

      _startCountdown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// 验证输入
  bool _validate() {
    bool isValid = true;
    setState(() {
      _passwordError = null;
    });

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
    final code = _codeController.text;
    if (code.isEmpty || code.length != 6) {
      setState(() {
        _codeError = '请输入验证码';
      });
      return;
    }
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    try {
      await ref.read(authProvider.notifier).register(
            phone: _phoneController.text.trim(),
            code: code,
            password: _passwordController.text,
          );

      if (mounted) {
        context.go('/create-family');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
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
      backgroundColor: AppColors.white,
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
              // 手机号输入
              PhoneInput(
                controller: _phoneController,
                errorText: _phoneError,
                enabled: !_isLoading && !_isSendingCode,
                onChanged: (_) {
                  if (_phoneError != null) {
                    setState(() {
                      _phoneError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 发送验证码按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_codeSent && _countdown > 0) || _isLoading || _isSendingCode
                          ? null
                          : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _codeSent && _countdown > 0 ? AppColors.gray200 : AppColors.primary,
                        disabledBackgroundColor: AppColors.gray300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSendingCode
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : Text(
                              _countdown > 0 ? '${_countdown}s' : '获取验证码',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    _codeSent && _countdown > 0 ? AppColors.gray500 : AppColors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              if (_codeSent) ...[
                const SizedBox(height: 32),
                // 验证码输入
                CodeInput(
                  controller: _codeController,
                  errorText: _codeError,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                // 密码输入
                PasswordInput(
                  controller: _passwordController,
                  errorText: _passwordError,
                  enabled: !_isLoading,
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
          '创建账号',
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
