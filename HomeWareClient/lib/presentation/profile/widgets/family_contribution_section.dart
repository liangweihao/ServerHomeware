import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/family_contribution_provider.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_section_header.dart';
import 'profile_contribution_podium.dart';
import 'member_contribution_navigation.dart';
import 'member_contribution_detail_sheet.dart';

/// 家庭协作区块 — 贡献排行 + 最近动态
class FamilyContributionSection extends ConsumerWidget {
  const FamilyContributionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(familyContributionLeaderboardProvider);
    final activityAsync = ref.watch(familyRecentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: '家庭协作',
          actionLabel: '查看全部',
          onAction: () {
            debugPrint('[FamilyContributionSection] INFO: 打开贡献详情');
            context.push('/profile/family/contribution');
          },
        ),
        const SizedBox(height: 10),
        leaderboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            debugPrint('[FamilyContributionSection] WARN: $e');
            return const SizedBox.shrink();
          },
          data: (list) {
            if (list.isEmpty) {
              return _emptyHint('本月还没有协作记录，录入或使用物品后会出现在这里');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileContributionPodium(
                  members: list.take(3).toList(),
                  onMemberTap: (m) => _openMemberDetail(context, ref, list, m),
                ),
                if (list.length > 3) ...[
                  const SizedBox(height: 10),
                  ProfileContributionRankList(
                    members: list.skip(3).take(2).toList(),
                    startRank: 4,
                    onMemberTap: (m) => _openMemberDetail(context, ref, list, m),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        activityAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (entries) {
            if (entries.isEmpty) return const SizedBox.shrink();
            return _RecentActivityCard(entries: entries.take(5).toList());
          },
        ),
      ],
    );
  }

  Widget _emptyHint(String text) {
    return AppCard(
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }

  void _openMemberDetail(
    BuildContext context,
    WidgetRef ref,
    List<FamilyMemberContribution> all,
    FamilyMemberContribution member, {
    bool previewSheet = false,
  }) {
    final total = all.fold<int>(0, (sum, e) => sum + e.totalActions);
    if (previewSheet) {
      showMemberContributionDetailSheet(
        context,
        ref,
        member,
        familyTotalActions: total,
      );
      return;
    }
    openMemberContributionDetail(
      context,
      member,
      familyTotalActions: total,
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.entries});

  final List<FamilyActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              '最近动态',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...entries.map((entry) {
            final r = entry.record;
            final label = _actionLabel(r.type);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint(
                    '[FamilyContributionSection] INFO: 打开物品 itemId=${r.itemId}',
                  );
                  context.push('/items/${r.itemId}');
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$label · ${r.operatorName ?? "家人"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _actionLabel(int type) {
    switch (type) {
      case 0:
        return '入库';
      case 1:
        return '消耗';
      case 2:
        return '丢弃';
      case 3:
        return '移动';
      default:
        return '操作';
    }
  }
}
