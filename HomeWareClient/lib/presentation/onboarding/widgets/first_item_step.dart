import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../common/widgets/app_button.dart';

class FirstItemStep extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const FirstItemStep({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(height: 16),

          // 标题
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity( 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '📦',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '试着添加第一件物品',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '开始管理你的家庭物品',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          // 扫码添加按钮
          AppButton(
            label: '📷 扫码添加',
            onPressed: () {
              context.push('/items/scan');
              onComplete();
            },
            isFullWidth: true,
            size: ButtonSize.large48,
            variant: ButtonVariant.primary,
          ),
          const SizedBox(height: 12),

          // 手动添加按钮
          AppButton(
            label: '✏️ 手动添加',
            onPressed: () {
              context.push('/items/add');
              onComplete();
            },
            isFullWidth: true,
            size: ButtonSize.large48,
            variant: ButtonVariant.secondary,
          ),
          const SizedBox(height: 12),

          // 跳过按钮
          Center(
            child: TextButton(
              onPressed: onComplete,
              child: const Text('稍后再说'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
