import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/icons/app_icon.dart';
import '../../../core/icons/candy_icons.dart';

/// 列表三态容器 — 加载 / 空 / 错误 / 内容
class AsyncListBody extends StatelessWidget {
  const AsyncListBody({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    this.errorMessage,
    this.onRetry,
    required this.emptyIcon,
    required this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionLabel,
    this.onEmptyAction,
    required this.child,
  });

  final bool isLoading;
  final bool isEmpty;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      debugPrint('[AsyncListBody] WARN: 列表错误 $errorMessage');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon.feature(
                icon: CandyIcons.error,
                accent: AppColors.danger,
                wellSize: 56,
                iconSize: 28,
              ),
              const SizedBox(height: 12),
              Text(errorMessage!, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('重试')),
              ],
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      final accent = _accentForEmptyIcon(emptyIcon);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon.feature(
                icon: emptyIcon,
                accent: accent,
                wellSize: 56,
                iconSize: 28,
              ),
              const SizedBox(height: 12),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (emptySubtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  emptySubtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
              if (emptyActionLabel != null && onEmptyAction != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onEmptyAction,
                  child: Text(emptyActionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return child;
  }

  static Color _accentForEmptyIcon(IconData icon) {
    final rounded = CandyIcons.rounded(icon);
    if (rounded == CandyIcons.check) return AppColors.success;
    if (rounded == CandyIcons.error) return AppColors.danger;
    if (rounded == CandyIcons.searchOff) return AppColors.accentSky;
    if (rounded == CandyIcons.notifications) return AppColors.accentRose;
    return AppColors.accentCoral;
  }
}
