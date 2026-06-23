import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/auth_button.dart';

/// 创建家庭页
class CreateFamilyPage extends ConsumerStatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  ConsumerState<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends ConsumerState<CreateFamilyPage> {
  final _nameController = TextEditingController();
  String? _nameError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 创建家庭
  Future<void> _createFamily() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = '请输入家庭名称';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _nameError = null;
    });

    try {
      await ref.read(authProvider.notifier).createFamily(name: name);

      if (mounted) {
        context.go('/');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[CreateFamilyPage] _createFamily',
        userMessage: '创建家庭失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 跳转到加入家庭
  void _goToJoinFamily() {
    context.push('/join-family');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          color: AppColors.gray700,
        ),
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
                  '🏠',
                  style: TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                '创建你的家庭',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '创建一个家庭空间，邀请家人一起管理物品',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              const SizedBox(height: 40),
              // 输入框
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: '给你的家庭起个名字',
                  errorText: _nameError,
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
                  prefixIcon: const Icon(Icons.home_outlined),
                  prefixIconColor: AppColors.gray400,
                ),
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() {
                      _nameError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // 提示文字
              Text(
                '家庭名称需要2-15个字符',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 24),
              // 创建按钮
              AuthButton(
                label: '创建家庭',
                onPressed: _createFamily,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              // 加入已有家庭
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '已有家庭？',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _goToJoinFamily,
                    child: Text(
                      '加入家庭',
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
