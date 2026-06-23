import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/auth_button.dart';

/// 加入家庭页
class JoinFamilyPage extends ConsumerStatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  ConsumerState<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends ConsumerState<JoinFamilyPage> {
  final _codeController = TextEditingController();
  String? _codeError;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 加入家庭
  Future<void> _joinFamily() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _codeError = '请输入邀请码';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    try {
      await ref.read(authProvider.notifier).joinFamily(code: code);

      if (mounted) {
        context.go('/');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[JoinFamilyPage] _joinFamily',
        userMessage: '加入家庭失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 跳转到创建家庭
  void _goToCreateFamily() {
    context.push('/create-family');
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              // 图标
              const Center(
                child: Text(
                  '👨‍👩‍👧‍👦',
                  style: TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                '加入已有家庭',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '输入家人分享的邀请码，加入家庭空间',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              const SizedBox(height: 40),
              // 邀请码输入
              TextField(
                controller: _codeController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: '请输入邀请码',
                  errorText: _codeError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                ),
                onChanged: (_) {
                  if (_codeError != null) {
                    setState(() {
                      _codeError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              // 加入按钮
              AuthButton(
                label: '加入家庭',
                onPressed: _joinFamily,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              // 创建新家庭
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '没有邀请码？',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _goToCreateFamily,
                    child: Text(
                      '创建家庭',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isLoading ? AppColors.gray400 : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
