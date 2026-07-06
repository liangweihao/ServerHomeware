import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/icons/candy_icon.dart';
import '../../../core/icons/candy_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/auth_service.dart';
import '../providers/family_contribution_provider.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_progress_bar.dart';
import 'member_category_breakdown.dart';
import 'member_operation_type_chart.dart';

/// 成员贡献详情内容区 — Sheet / 全屏页共用
class MemberContributionDetailBody extends ConsumerWidget {
  const MemberContributionDetailBody({
    super.key,
    required this.member,
    this.familyTotalActions,
    this.scrollController,
    this.isSheet = false,
  });

  final FamilyMemberContribution member;
  final int? familyTotalActions;
  final ScrollController? scrollController;
  final bool isSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(memberActivityByNameProvider(member.name));
    final rank = member.rank;
    final colors = AuthService.getAvatarColors(member.name.hashCode.abs() % 10);
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    final share = familyTotalActions != null && familyTotalActions! > 0
        ? ((member.totalActions / familyTotalActions!) * 100)
            .round()
            .clamp(0, 100)
        : null;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(20, isSheet ? 12 : 8, 20, 24),
      children: [
        if (isSheet)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (isSheet) const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(colors[0]), Color(colors[1])],
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (rank != null)
                    Text(
                      '本月家庭排名第 $rank 名',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (rank != null && rank <= 3) MemberRankChip(rank: rank),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: MemberStatBox(
                label: '录入',
                value: '${member.recordCount}',
                unit: '件',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MemberStatBox(
                label: '消耗',
                value: '${member.consumeCount}',
                unit: '次',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MemberStatBox(
                label: '总操作',
                value: '${member.totalActions}',
                unit: '次',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (share != null) ...[
          const SizedBox(height: 16),
          Text(
            '占家庭本月操作 $share%',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppProgressBar(
            value: share / 100,
            height: 8,
            colorMode: ColorMode.fixed,
            fixedColor: AppColors.primary,
          ),
        ],
        const SizedBox(height: 20),
        MemberCategoryBreakdown(operatorName: member.name),
        const SizedBox(height: 16),
        MemberOperationTypeChart(operatorName: member.name),
        const SizedBox(height: 20),
        Text(
          '最近操作',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            '加载动态失败',
            style: TextStyle(color: AppColors.textHint),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return AppCard(
                child: Text(
                  '暂无最近操作记录',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: entries.map((entry) {
                  final r = entry.record;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (isSheet) Navigator.pop(context);
                        context.push('/items/${r.itemId}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            CandyIcon(
                              _actionIcon(r.type),
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${_actionLabel(r.type)} · ${_formatTime(r.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const CandyIcon(
                              CandyIcons.chevronRight,
                              size: 18,
                              color: AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            if (isSheet) Navigator.pop(context);
            context.push('/profile/family');
          },
          icon: const CandyIcon(CandyIcons.people, size: 18),
          label: const Text('管理家庭成员'),
        ),
      ],
    );
  }

  String _actionLabel(int type) {
    return switch (type) {
      0 => '入库',
      1 => '消耗',
      2 => '丢弃',
      3 => '移动',
      _ => '操作',
    };
  }

  IconData _actionIcon(int type) {
    return switch (type) {
      0 => Icons.add_box_outlined,
      1 => Icons.remove_circle_outline,
      2 => Icons.delete_outline,
      3 => Icons.drive_file_move_outline,
      _ => Icons.circle_outlined,
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    return DateFormat('M月d日 HH:mm').format(time);
  }
}

/// 成员统计小卡
class MemberStatBox extends StatelessWidget {
  const MemberStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(unit, style: TextStyle(fontSize: 10, color: AppColors.textHint)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// 排名奖牌 Chip
class MemberRankChip extends StatelessWidget {
  const MemberRankChip({super.key, required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (rank) {
      1 => ('冠军', AppColors.warning, Icons.emoji_events_outlined),
      2 => ('亚军', AppColors.textSecondary, Icons.military_tech_outlined),
      3 => ('季军', const Color(0xFFCD7F32), Icons.workspace_premium_outlined),
      _ => ('', AppColors.primary, Icons.leaderboard_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CandyIcon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
