import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_stock/core/icons/candy_icon.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/icons/app_icon.dart';
import '../../../core/icons/candy_icon_assets.dart';
import '../../../core/icons/candy_icons.dart';
import '../../../core/models/space_type.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../items/item_add_draft_storage.dart';
import '../../items/widgets/quick_consume_sheet.dart';

/// 首页「+」快捷操作弹层 — 物品相关入口
class PublishActionSheet {
  PublishActionSheet._();

  static Future<void> showQuickConsume(BuildContext context, WidgetRef ref) {
    return QuickConsumeSheet.show(context, ref);
  }

  static Future<void> show(BuildContext context, WidgetRef ref) {
    final skin = ref.read(spaceSkinProvider);
    debugPrint('[PublishActionSheet] INFO: 打开快捷操作 skin=${skin.spaceType.name}');
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
                  svgAsset: CandyIconAssets.consume,
                  accent: AppColors.accentRose,
                  title: skin.consumeActionLabel,
                  subtitle: skin.spaceType == SpaceType.shop
                      ? '选商品，一键卖出 1 件'
                      : '选物品，一键用 1 件',
                  onTap: () {
                    Navigator.pop(ctx);
                    QuickConsumeSheet.show(context, ref);
                  },
                ),
                _ActionTile(
                  svgAsset: CandyIconAssets.add,
                  accent: AppColors.accentCoral,
                  title: skin.addItemLabel,
                  subtitle: skin.spaceType == SpaceType.shop
                      ? '记录新商品到店库存'
                      : '记录新物品到家庭库存',
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
                  svgAsset: CandyIconAssets.scan,
                  accent: AppColors.accentSky,
                  title: '扫码录入',
                  subtitle: '扫描条码快速添加',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/items/scan');
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
          svgAsset: CandyIconAssets.edit,
          accent: AppColors.accentAmber,
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
    this.icon,
    this.svgAsset,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : assert(icon != null || svgAsset != null);

  final IconData? icon;
  final String? svgAsset;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: _buildLeading(),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: const CandyIcon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildLeading() {
    if (svgAsset != null) {
      final (wellBg, wellFg) = AppColors.iconWellFor(accent);
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: wellBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: AppIcon.svg(
          asset: svgAsset!,
          color: wellFg,
          size: 22,
          showWell: false,
        ),
      );
    }
    return AppIcon.feature(
      icon: icon ?? CandyIcons.inventory,
      accent: accent,
      wellSize: 44,
      iconSize: 22,
    );
  }
}
