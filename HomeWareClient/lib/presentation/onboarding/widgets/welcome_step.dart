import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../common/widgets/app_button.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // 大图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🏠',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '欢迎使用 HomeStock',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '轻松管理家庭物品，再也不担心过期浪费',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // 开始按钮
          AppButton(
            label: '开始设置',
            onPressed: onNext,
            isFullWidth: true,
            size: ButtonSize.large48,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
