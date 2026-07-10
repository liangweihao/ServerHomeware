import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/assistant_item_resolver.dart';
import '../../../core/assistant/assistant_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/icons/app_icon.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/item_deleted_registry.dart';
import '../../../core/services/item_sync_service.dart';
import '../../../data/database/app_database.dart';
import 'assistant_chat_theme.dart';

/// 助手回复中的物品结果 — 可点击跳转详情（本地无记录时从服务端拉取）
class AssistantItemResultList extends ConsumerWidget {
  const AssistantItemResultList({
    super.key,
    required this.items,
  });

  final List<AssistantItemSummary> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ItemCard(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});

  final AssistantItemSummary item;

  Future<void> _openDetail(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final sync = ItemSyncService(db);

    debugPrint(
      '[AssistantItemResultList] INFO: 解析跳转 name=${item.name} '
      'cachedLocalId=${item.itemId} serverId=${item.serverItemId}',
    );

    final navId = await _ensureOpenableNavId(db, sync, item);

    if (!context.mounted) return;
    if (navId == null) {
      debugPrint(
        '[AssistantItemResultList] WARN: 无法打开物品 name=${item.name}',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.serverItemId != null
                ? '「${item.name}」已从本地移除，云端也无法恢复'
                : '找不到「${item.name}」，请先在物品页同步库存',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    debugPrint(
      '[AssistantItemResultList] INFO: 打开物品 localId=$navId name=${item.name}',
    );
    context.push('/items/$navId');
  }

  /// 跳转前二次校验本地行；缓存 id 失效时按 serverId 强制拉取
  Future<int?> _ensureOpenableNavId(
    AppDatabase db,
    ItemSyncService sync,
    AssistantItemSummary item,
  ) async {
    var navId = await AssistantItemResolver.resolveNavIdForTap(db, sync, item);
    if (navId != null && await db.getItemById(navId) != null) {
      return navId;
    }

    debugPrint(
      '[AssistantItemResultList] WARN: 解析 localId=$navId 无效，'
      '强制 serverId=${item.serverItemId}',
    );

    final serverId = item.serverItemId;
    if (serverId == null || serverId <= 0) return null;

    await ItemDeletedRegistry.unmark(serverId);
    navId = await sync.ensureLocalByServerId(serverId);
    if (navId != null && await db.getItemById(navId) != null) {
      return navId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context, ref),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: AssistantChatTheme.itemCardDecoration,
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              AppIcon.feature(
                icon: Icons.inventory_2_rounded,
                accent: AppColors.accentCoral,
                wellSize: 40,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AssistantChatTheme.itemTitle),
                    if (item.itemId <= 0 && item.serverItemId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '云端库存 · 点击恢复查看',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: AssistantChatTheme.itemSubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '详情',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
