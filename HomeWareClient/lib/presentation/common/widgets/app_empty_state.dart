import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_copy.dart';
import 'app_button.dart';
import 'cartoon_empty_illustration.dart';

/// 通用空状态 — SVG 插画与温暖文案
class AppEmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  /// 插画类型（传入后优先展示 SVG + 温暖文案）
  final CartoonEmptyKind? cartoonKind;
  /// 搜索场景关键词（配合 [CartoonEmptyKind.search]）
  final String? searchQuery;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.cartoonKind,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final cartoonCopy = cartoonKind != null
        ? CartoonCopy.emptyState(cartoonKind!, searchQuery: searchQuery)
        : null;

    final displayTitle = cartoonCopy?.title ?? title;
    final displaySubtitle = cartoonCopy?.subtitle ?? subtitle;
    final displayAction = cartoonCopy?.actionLabel ?? actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cartoonKind != null)
              CartoonEmptyIllustration(kind: cartoonKind!)
            else
              Text(
                icon,
                style: const TextStyle(fontSize: 72),
              ),
            const SizedBox(height: 20),
            Text(
              displayTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (displaySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                displaySubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (displayAction != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: displayAction,
                onPressed: onAction,
                variant: ButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
