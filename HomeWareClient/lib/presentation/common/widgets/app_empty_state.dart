import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_copy.dart';
import 'app_button.dart';
import 'cartoon_empty_illustration.dart';

/// 通用空状态 — 工具风圆形图标 / 卡通 SVG 插画双分支
class AppEmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  /// 插画类型（卡通主题下展示 SVG + 温暖文案）
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

  /// 工具风空态默认 emoji（按插画类型映射）
  static String _utilityIcon(CartoonEmptyKind kind) {
    return switch (kind) {
      CartoonEmptyKind.items => '📦',
      CartoonEmptyKind.search => '🔍',
      CartoonEmptyKind.alerts => '🔔',
      CartoonEmptyKind.family => '👨‍👩‍👧',
      CartoonEmptyKind.error => '⚠️',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cartoonCopy = cartoonKind != null
        ? CartoonCopy.emptyState(cartoonKind!, searchQuery: searchQuery)
        : null;

    final displayTitle = cartoonCopy?.title ?? title;
    final displaySubtitle = cartoonCopy?.subtitle ?? subtitle;
    final displayAction = cartoonCopy?.actionLabel ?? actionLabel;
    final displayIcon =
        cartoonKind != null ? _utilityIcon(cartoonKind!) : icon;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(displayIcon),
            const SizedBox(height: 20),
            Text(
              displayTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w500,
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

  /// 工具风用灰底圆形容器 + emoji；卡通主题保留 SVG 插画
  Widget _buildIllustration(String displayIcon) {
    if (AppColors.isUtilityStyle || cartoonKind == null) {
      return Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Text(
          displayIcon,
          style: const TextStyle(fontSize: 40, height: 1),
        ),
      );
    }

    return CartoonEmptyIllustration(kind: cartoonKind!);
  }
}
