import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/models/contribution_stats.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_progress_bar.dart';
import '../../common/widgets/app_section_header.dart';

/// 个人贡献 Bento 卡 — 录入/消耗双指标 + 贡献度进度
class ProfileContributionCard extends StatelessWidget {
  const ProfileContributionCard({
    super.key,
    required this.stats,
    this.loading = false,
    this.networkError = false,
    this.onRetry,
  });

  final UserContributionStats? stats;
  final bool loading;
  final bool networkError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (networkError) {
      return AppCard(
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined, size: 36, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('贡献数据加载失败', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }

    if (stats == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(title: '我的贡献'),
            const SizedBox(height: 8),
            Text(
              '加入家庭后即可记录你的录入与消耗贡献',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final s = stats!;
    final contribution = s.contributionPercent.clamp(0, 100);
    final rank = s.ranking;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppSectionHeader(title: '我的贡献 · 本月'),
              ),
              if (rank != null && rank > 0) _RankMedal(rank: rank),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: '录入',
                  value: '${s.recordCount}',
                  unit: '件',
                  color: AppColors.success,
                  icon: Icons.add_box_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: '消耗记录',
                  value: '${s.consumeCount}',
                  unit: '次',
                  color: AppColors.info,
                  icon: Icons.trending_down_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '家庭贡献占比',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '$contribution%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AppProgressBar(
              value: contribution / 100,
              height: 10,
              colorMode: ColorMode.fixed,
              fixedColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 家庭贡献排名奖牌
class _RankMedal extends StatelessWidget {
  const _RankMedal({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (rank) {
      1 => ('冠军', AppColors.warning, Icons.emoji_events_outlined),
      2 => ('亚军', AppColors.textSecondary, Icons.military_tech_outlined),
      3 => ('季军', const Color(0xFFCD7F32), Icons.workspace_premium_outlined),
      _ => ('第$rank名', AppColors.primary, Icons.leaderboard_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
