import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../providers/family_contribution_provider.dart';

/// 分享海报模板 — 固定尺寸，用于离屏渲染截图
class ProfilePodiumSharePoster extends StatelessWidget {
  const ProfilePodiumSharePoster({
    super.key,
    required this.members,
    this.monthLabel,
  });

  final List<FamilyMemberContribution> members;
  final String? monthLabel;

  static const posterWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final label = monthLabel ??
        DateFormat('yyyy年M月').format(DateTime.now());
    final display = members.take(5).toList();

    return Container(
      width: posterWidth,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PosterHeader(monthLabel: label),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  if (display.length >= 3) _TopThreeRow(members: display.take(3).toList()),
                  if (display.length < 3)
                    ...display.map((m) => _RankRow(member: m, rank: display.indexOf(m) + 1)),
                  if (display.length > 3) ...[
                    const SizedBox(height: 12),
                    ...List.generate(display.length - 3, (i) {
                      final m = display[i + 3];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RankRow(member: m, rank: i + 4),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const _PosterFooter(),
          ],
        ),
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.warning.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'HomeStock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '家庭协作排行榜',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthLabel · 录入与消耗贡献',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopThreeRow extends StatelessWidget {
  const _TopThreeRow({required this.members});

  final List<FamilyMemberContribution> members;

  @override
  Widget build(BuildContext context) {
    final first = members.isNotEmpty ? members[0] : null;
    final second = members.length > 1 ? members[1] : null;
    final third = members.length > 2 ? members[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          Expanded(child: _MiniPodium(member: second, rank: 2, height: 56)),
        const SizedBox(width: 8),
        if (first != null)
          Expanded(child: _MiniPodium(member: first, rank: 1, height: 72)),
        const SizedBox(width: 8),
        if (third != null)
          Expanded(child: _MiniPodium(member: third, rank: 3, height: 48)),
      ],
    );
  }
}

class _MiniPodium extends StatelessWidget {
  const _MiniPodium({
    required this.member,
    required this.rank,
    required this.height,
  });

  final FamilyMemberContribution member;
  final int rank;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => AppColors.warning,
      2 => AppColors.textSecondary,
      3 => const Color(0xFFCD7F32),
      _ => AppColors.primary,
    };

    return Column(
      children: [
        Text(
          member.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '录${member.recordCount} 耗${member.consumeCount}',
          style: TextStyle(fontSize: 9, color: AppColors.textHint),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.7),
                color.withValues(alpha: 0.35),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.member, required this.rank});

  final FamilyMemberContribution member;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            '录入 ${member.recordCount}',
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
          const SizedBox(width: 6),
          Text(
            '消耗 ${member.consumeCount}',
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _PosterFooter extends StatelessWidget {
  const _PosterFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.homeDivider)),
        color: AppColors.gray100.withValues(alpha: 0.5),
      ),
      child: Text(
        '家庭物品管家 · 一起打理家的库存',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textHint,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
