import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme_variant.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_list_row.dart';
import '../common/widgets/warm_scaffold.dart';

/// 主题样式设置 — 遵循 ui_system 设置页模板
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appThemeVariantProvider);

    return WarmScaffold(
      title: '主题样式',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < AppThemeVariant.values.length; i++) ...[
                  if (i > 0) const AppListDivider(),
                  _ThemeOptionRow(
                    variant: AppThemeVariant.values[i],
                    selected: current == AppThemeVariant.values[i],
                    onSelect: () {
                      debugPrint(
                        '[ThemeSettingsPage] INFO: 选择 ${AppThemeVariant.values[i].label}',
                      );
                      ref
                          .read(appThemeVariantProvider.notifier)
                          .setVariant(AppThemeVariant.values[i]);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '「清爽工具」为默认；「糖果轻点」为多彩点缀预览，可在真机对比后选择是否设为默认。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.variant,
    required this.selected,
    required this.onSelect,
  });

  final AppThemeVariant variant;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    variant.description,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22)
            else
              Icon(Icons.circle_outlined, color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
