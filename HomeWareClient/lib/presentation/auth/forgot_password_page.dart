import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/phone_input.dart';
import 'widgets/code_input.dart';
import 'widgets/password_input.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_cartoon_wrap.dart';

/// 忘记密码页
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _phoneError;
  String? _codeError;
  String? _newPasswordError;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
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
      await AuthService().sendVerifyCode(phone: phone, purpose: 'reset');

      setState(() {
        _codeSent = true;
        _countdown = 60;
      });

      _startCountdown();
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[ForgotPasswordPage] _sendCode',
        userMessage: '发送验证码失败，请稍后重试',
      );
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
      _newPasswordError = null;
    });

    final newPassword = _newPasswordController.text;
    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = '请设置新密码';
      });
      isValid = false;
    } else if (newPassword.length < 6) {
      setState(() {
        _newPasswordError = '密码至少6位';
      });
      isValid = false;
    }

    return isValid;
  }

  /// 重置密码
  Future<void> _resetPassword() async {
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
      await ref.read(authProvider.notifier).resetPassword(
            phone: _phoneController.text.trim(),
            code: code,
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('密码重置成功'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/login');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[ForgotPasswordPage] _resetPassword',
        userMessage: '重置密码失败，请稍后重试',
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_codeSent && _countdown > 0) ||
                                    _isLoading ||
                                    _isSendingCode
                                ? null
                                : _sendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _codeSent && _countdown > 0
                                  ? AppColors.gray200
                                  : AppColors.primary,
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
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _countdown > 0 ? '${_countdown}s' : '获取验证码',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _codeSent && _countdown > 0
                                          ? AppColors.gray500
                                          : AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 32),
                      CodeInput(
                        controller: _codeController,
                        errorText: _codeError,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 24),
                      PasswordInput(
                        controller: _newPasswordController,
                        hintText: '请设置新密码',
                        errorText: _newPasswordError,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        label: '重置密码',
                        onPressed: _resetPassword,
                        isLoading: _isLoading,
                      ),
                    ],
                  ],
                ),
              ),
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
          authPageTitle('忘记密码', emoji: '🔑'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '输入手机号，重置密码',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray500,
              ),
        ),
      ],
    );
  }
}
