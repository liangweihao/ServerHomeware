import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../items/item_add_draft_storage.dart';
import '../../items/widgets/quick_consume_sheet.dart';

/// 首页「+」快捷操作弹层 — 物品相关入口
class PublishActionSheet {
  PublishActionSheet._();

  /// 仅打开记消耗（方式选择页复用）
  static Future<void> showQuickConsume(BuildContext context, WidgetRef ref) {
    return QuickConsumeSheet.show(context, ref);
  }

  static Future<void> show(BuildContext context, WidgetRef ref) {
    debugPrint('[PublishActionSheet] INFO: 打开快捷操作');
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '快捷操作',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _ActionTile(
                  icon: Icons.remove_circle_outline,
                  title: '记消耗',
                  subtitle: '选物品，一键用 1 件',
                  onTap: () {
                    Navigator.pop(ctx);
                    QuickConsumeSheet.show(context, ref);
                  },
                ),
                _ActionTile(
                  icon: Icons.inventory_2_outlined,
                  title: '添加入库',
                  subtitle: '记录新物品到家庭库存',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/items/add');
                  },
                ),
                _DraftResumeTile(
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/items/add?resumeDraft=1');
                  },
                ),
                _ActionTile(
                  icon: Icons.qr_code_scanner_outlined,
                  title: '扫码录入',
                  subtitle: '扫描条码快速添加',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/items/scan');
                  },
                ),
                _ActionTile(
                  icon: Icons.list_alt_outlined,
                  title: '要处理',
                  subtitle: '过期、临期、低库存物品',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/items?tab=action');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 有草稿时显示「继续录入」
class _DraftResumeTile extends StatelessWidget {
  const _DraftResumeTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ItemAddDraftStorage.hasDraft(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return _ActionTile(
          icon: Icons.edit_note_outlined,
          title: '继续录入',
          subtitle: '恢复上次未完成的添加入库',
          onTap: onTap,
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
