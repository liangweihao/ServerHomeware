import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../providers/family_contribution_provider.dart';
import '../../common/widgets/app_card.dart';

/// Top3 贡献领奖台 — 经典 2-1-3 站位，支持点击成员
class ProfileContributionPodium extends StatelessWidget {
  const ProfileContributionPodium({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  final List<FamilyMemberContribution> members;
  final void Function(FamilyMemberContribution member)? onMemberTap;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    if (members.length == 1) {
      return AppCard(
        child: Center(
          child: _PodiumColumn(
            member: members[0],
            rank: 1,
            barHeight: 72,
            expanded: true,
            onTap: onMemberTap == null ? null : () => onMemberTap!(members[0]),
          ),
        ),
      );
    }

    if (members.length == 2) {
      return AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _PodiumColumn(
                member: members[0],
                rank: 1,
                barHeight: 80,
                onTap: onMemberTap == null ? null : () => onMemberTap!(members[0]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PodiumColumn(
                member: members[1],
                rank: 2,
                barHeight: 64,
                onTap: onMemberTap == null ? null : () => onMemberTap!(members[1]),
              ),
            ),
          ],
        ),
      );
    }

    final first = members[0];
    final second = members.length > 1 ? members[1] : null;
    final third = members.length > 2 ? members[2] : null;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            Expanded(
              child: _PodiumColumn(
                member: second,
                rank: 2,
                barHeight: 68,
                onTap: onMemberTap == null ? null : () => onMemberTap!(second),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: _PodiumColumn(
              member: first,
              rank: 1,
              barHeight: 92,
              onTap: onMemberTap == null ? null : () => onMemberTap!(first),
            ),
          ),
          if (third != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _PodiumColumn(
                member: third,
                rank: 3,
                barHeight: 56,
                onTap: onMemberTap == null ? null : () => onMemberTap!(third),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.member,
    required this.rank,
    required this.barHeight,
    this.expanded = false,
    this.onTap,
  });

  final FamilyMemberContribution member;
  final int rank;
  final double barHeight;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (barColor, medalIcon) = _rankStyle(rank);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                debugPrint('[ProfileContributionPodium] INFO: 点击 ${member.name}');
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: expanded ? 28 : 22,
              backgroundColor: barColor.withValues(alpha: 0.18),
              child: Icon(medalIcon, color: barColor, size: expanded ? 26 : 20),
            ),
            const SizedBox(height: 6),
            Text(
              member.name,
              style: TextStyle(
                fontSize: expanded ? 15 : 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '录入 ${member.recordCount}',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            Text(
              '消耗 ${member.consumeCount}',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    barColor.withValues(alpha: 0.55),
                    barColor.withValues(alpha: 0.25),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sm),
                ),
                border: Border.all(color: barColor.withValues(alpha: 0.35)),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData) _rankStyle(int rank) {
    return switch (rank) {
      1 => (AppColors.warning, Icons.emoji_events_outlined),
      2 => (AppColors.textSecondary, Icons.military_tech_outlined),
      3 => (const Color(0xFFCD7F32), Icons.workspace_premium_outlined),
      _ => (AppColors.primary, Icons.leaderboard_outlined),
    };
  }
}

/// 第 4 名及以后的列表行
class ProfileContributionRankList extends StatelessWidget {
  const ProfileContributionRankList({
    super.key,
    required this.members,
    this.startRank = 4,
    this.onMemberTap,
  });

  final List<FamilyMemberContribution> members;
  final int startRank;
  final void Function(FamilyMemberContribution member)? onMemberTap;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: List.generate(members.length, (i) {
          final m = members[i];
          final rank = m.rank ?? (startRank + i);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onMemberTap == null
                  ? null
                  : () {
                      debugPrint(
                        '[ProfileContributionRankList] INFO: 点击 ${m.name}',
                      );
                      onMemberTap!(m);
                    },
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: EdgeInsets.only(bottom: i < members.length - 1 ? 10 : 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.gray100,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '录入 ${m.recordCount}',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '消耗 ${m.consumeCount}',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    if (onMemberTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
