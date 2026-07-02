import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

/// 搜索词 → 物品预警快捷入口（非外链业务）
class ItemAlertLinkBanner extends StatelessWidget {
  const ItemAlertLinkBanner({super.key, required this.query});

  final String query;

  static const _expiringHints = ['临期', '过期', '牛奶', '食品', '药'];
  static const _lowStockHints = ['低库存', '补货', '纸巾', '库存'];

  String? get _targetRoute {
    final q = query.trim();
    if (q.isEmpty) return null;
    for (final h in _expiringHints) {
      if (q.contains(h)) return '/home/section/expiring';
    }
    for (final h in _lowStockHints) {
      if (q.contains(h)) return '/home/section/low_stock';
    }
    return null;
  }

  String get _message {
    final route = _targetRoute;
    if (route == '/home/section/expiring') {
      return '也在找临期物品？查看即将过期列表';
    }
    if (route == '/home/section/low_stock') {
      return '也在找补货物品？查看库存不足列表';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final route = _targetRoute;
    if (route == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            debugPrint('[ItemAlertLink] INFO: 跳转 $route');
            context.push(route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _message,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primaryDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
