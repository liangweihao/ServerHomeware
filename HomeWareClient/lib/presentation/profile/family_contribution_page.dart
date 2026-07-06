import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/candy_icon.dart';
import '../../core/icons/candy_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/usage_record_sync_service.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_section_header.dart';
import '../common/widgets/warm_scaffold.dart';
import 'providers/family_contribution_provider.dart';
import 'widgets/member_contribution_navigation.dart';
import 'widgets/profile_contribution_podium.dart';
import 'widgets/profile_podium_share_service.dart';

/// 家庭贡献详情页 — 领奖台 + 分享 + 最近动态
class FamilyContributionPage extends ConsumerStatefulWidget {
  const FamilyContributionPage({super.key});

  @override
  ConsumerState<FamilyContributionPage> createState() =>
      _FamilyContributionPageState();
}

class _FamilyContributionPageState extends ConsumerState<FamilyContributionPage> {
  final _podiumKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(familyContributionLeaderboardProvider);
    final activityAsync = ref.watch(familyRecentActivityProvider);
    final leaderboard = leaderboardAsync.valueOrNull ?? [];

    return WarmScaffold(
      title: '家庭协作',
      actions: leaderboard.isEmpty
          ? null
          : [
              IconButton(
                icon: const CandyIcon(CandyIcons.share),
                tooltip: '分享排行榜',
                onPressed: () => ProfilePodiumShareService.share(
                  context,
                  leaderboard,
                  podiumKey: _podiumKey,
                ),
              ),
            ],
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          debugPrint('[FamilyContributionPage] INFO: 下拉刷新');
          final db = ref.read(databaseProvider);
          await UsageRecordSyncService(db).syncBidirectional();
          ref.invalidate(familyContributionLeaderboardProvider);
          ref.invalidate(familyRecentActivityProvider);
          await ref.read(familyContributionLeaderboardProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const AppSectionHeader(title: '本月贡献排行'),
            const SizedBox(height: 12),
            leaderboardAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) {
                debugPrint('[FamilyContributionPage] ERROR: $e');
                return _emptyBox('加载排行失败，请下拉重试');
              },
              data: (list) {
                if (list.isEmpty) {
                  return _emptyBox('本月还没有协作记录\n录入或使用物品后会出现在这里');
                }
                return Column(
                  children: [
                    RepaintBoundary(
                      key: _podiumKey,
                      child: ProfileContributionPodium(
                        members: list.take(3).toList(),
                        onMemberTap: (m) =>
                            _openMemberDetail(context, list, m),
                      ),
                    ),
                    if (list.length > 3) ...[
                      const SizedBox(height: 12),
                      ProfileContributionRankList(
                        members: list.skip(3).toList(),
                        startRank: 4,
                        onMemberTap: (m) =>
                            _openMemberDetail(context, list, m),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: '最近动态'),
            const SizedBox(height: 12),
            activityAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (entries) {
                if (entries.isEmpty) {
                  return _emptyBox('暂无动态');
                }
                return _ActivityList(entries: entries);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openMemberDetail(
    BuildContext context,
    List<FamilyMemberContribution> all,
    FamilyMemberContribution member,
  ) {
    final total = all.fold<int>(0, (sum, e) => sum + e.totalActions);
    openMemberContributionDetail(
      context,
      member,
      familyTotalActions: total,
    );
  }

  Widget _emptyBox(String text) {
    return AppCard(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.entries});

  final List<FamilyActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: entries.map((entry) {
          final r = entry.record;
          final label = _actionLabel(r.type);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint(
                  '[FamilyContributionPage] INFO: 打开物品 itemId=${r.itemId}',
                );
                context.push('/items/${r.itemId}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CandyIcon(CandyIcons.circle, size: 6, color: AppColors.primary),
                    const SizedBox(width: 8),
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
                          const SizedBox(height: 2),
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
                    const CandyIcon(CandyIcons.chevronRight, size: 18, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
