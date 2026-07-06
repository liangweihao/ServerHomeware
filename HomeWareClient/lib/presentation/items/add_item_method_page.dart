import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/space_type.dart';
import '../../core/auth/shop_role_guard.dart';
import '../../core/providers/family_role_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../common/widgets/warm_scaffold.dart';
import '../home/widgets/publish_action_sheet.dart';
import 'item_add_draft_storage.dart';
import 'widgets/add_item_nl_sheet.dart';

/// 录入方式选择页 — Epic E4 D1（借鉴闲鱼发布入口）
class AddItemMethodPage extends ConsumerStatefulWidget {
  const AddItemMethodPage({super.key});

  @override
  ConsumerState<AddItemMethodPage> createState() => _AddItemMethodPageState();
}

class _AddItemMethodPageState extends ConsumerState<AddItemMethodPage> {
  int _draftRefreshKey = 0;

  Future<void> _navigateAndRefresh(String path) async {
    await context.push(path);
    if (mounted) {
      setState(() => _draftRefreshKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    final role = ref.watch(familyRoleProvider);
    final canCsv = ShopRoleGuard.canBulkImport(skin, role);
    return WarmScaffold(
      title: '选择录入方式',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            skin.spaceType == SpaceType.shop
                ? '选最快的方式把商品记进店里'
                : '选最快的方式把物品记进家庭库存',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (skin.spaceType == SpaceType.shop && canCsv)
            _MethodCard(
              icon: Icons.table_chart_outlined,
              title: skin.csvImportTitle,
              subtitle: skin.csvImportSubtitle,
              eta: '批量',
              highlight: true,
              onTap: () {
                debugPrint('[AddItemMethodPage] INFO: 选择 CSV 批量进货');
                _navigateAndRefresh('/items/import/csv');
              },
            ),
          _MethodCard(
            icon: Icons.mic_none_outlined,
            title: '说话添物品',
            subtitle: '一句话描述，自动预填分类、位置与数量',
            eta: '约 15 秒',
            highlight: true,
            onTap: () {
              debugPrint('[AddItemMethodPage] INFO: 选择说话添物品');
              AddItemNlSheet.show(context);
            },
          ),
          _MethodCard(
            icon: Icons.qr_code_scanner_outlined,
            title: '扫码录入',
            subtitle: '对准条码，自动识别商品信息',
            eta: '约 10 秒',
            onTap: () {
              debugPrint('[AddItemMethodPage] INFO: 选择扫码录入');
              _navigateAndRefresh('/items/scan');
            },
          ),
          _MethodCard(
            icon: Icons.edit_note_outlined,
            title: '手动向导',
            subtitle: '分步填写分类、数量、位置与过期',
            eta: '约 30 秒',
            onTap: () {
              debugPrint('[AddItemMethodPage] INFO: 选择手动向导');
              _navigateAndRefresh('/items/add');
            },
          ),
          _DraftCard(key: ValueKey(_draftRefreshKey)),
          _MethodCard(
            icon: Icons.photo_camera_outlined,
            title: '拍照识别',
            subtitle: '拍摄包装或小票，自动填表（即将上线）',
            eta: '敬请期待',
            enabled: false,
            onTap: () {
              debugPrint('[AddItemMethodPage] INFO: OCR 占位点击');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('拍照识别功能开发中，敬请期待')),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '其他快捷操作',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _SecondaryTile(
            icon: Icons.remove_circle_outline,
            title: '记消耗',
            onTap: () => PublishActionSheet.showQuickConsume(context, ref),
          ),
          _SecondaryTile(
            icon: Icons.list_alt_outlined,
            title: '要处理的物品',
            onTap: () => context.push('/items?tab=action'),
          ),
        ],
      ),
    );
  }
}

/// 有草稿时显示继续录入卡片（含摘要）
class _DraftCard extends StatelessWidget {
  const _DraftCard({super.key});

  static const _stepLabels = ['分类', '信息', '位置', '时效'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ItemAddDraftStorage.load(),
      builder: (context, snapshot) {
        final draft = snapshot.data;
        if (draft == null) return const SizedBox.shrink();

        final name = (draft['name'] as String?)?.trim();
        final stepIndex = (draft['wizardStep'] as int?) ?? 0;
        final stepLabel = _stepLabels[stepIndex.clamp(0, 3)];
        final savedAtRaw = draft['savedAt'] as String?;
        var timeHint = '';
        if (savedAtRaw != null) {
          try {
            final savedAt = DateTime.parse(savedAtRaw);
            timeHint = DateFormat('M/d HH:mm').format(savedAt);
          } catch (_) {}
        }

        final subtitle = [
          if (name != null && name.isNotEmpty) name else '未命名物品',
          '步骤：$stepLabel',
          if (timeHint.isNotEmpty) timeHint,
        ].join(' · ');

        return _MethodCard(
          icon: Icons.restore_outlined,
          title: '继续录入',
          subtitle: subtitle,
          eta: '继续上次',
          onTap: () {
            debugPrint('[AddItemMethodPage] INFO: 继续草稿 step=$stepLabel');
            context.push('/items/add?resumeDraft=1');
          },
        );
      },
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.onTap,
    this.highlight = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String eta;
  final VoidCallback onTap;
  final bool highlight;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlight && enabled
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.homeDivider;

    final iconAccent = enabled
        ? (highlight ? AppColors.primary : AppColors.textSecondary)
        : AppColors.textHint;
    final (wellBg, wellFg) = AppColors.iconWellFor(iconAccent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: enabled ? AppColors.white : AppColors.gray100,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: highlight && enabled ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: wellBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: wellFg,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: enabled
                              ? AppColors.textSecondary
                              : AppColors.textHint,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      eta,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                      ),
                    ),
                    if (enabled)
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  const _SecondaryTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
