import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:home_stock/core/icons/candy_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/guanguan_panel_models.dart';
import '../../../core/config/space_skin_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/assistant_mascot.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../providers/guanguan_panel_provider.dart';

/// 管管今日面板 — 可折叠（P1-A）
class GuanguanPanelCard extends ConsumerWidget {
  const GuanguanPanelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    final panelAsync = ref.watch(guanguanPanelProvider);
    final collapsed = ref.watch(guanguanPanelCollapsedProvider);

    return panelAsync.when(
      data: (data) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Material(
          color: AppColors.white,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    ref.read(guanguanPanelCollapsedProvider.notifier).toggle(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      CandyIcon(
                        Icons.emoji_emotions_outlined,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AssistantMascot.name}今日面板',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _summaryLine(data),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CandyIcon(
                        collapsed
                            ? Icons.expand_more
                            : Icons.expand_less,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
              if (!collapsed) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProficiencyRow(proficiency: data.proficiency),
                      if (data.collaborationQuip != null) ...[
                        const SizedBox(height: 10),
                        _QuipLine(text: data.collaborationQuip!),
                      ],
                      const SizedBox(height: 12),
                      _TasksSection(
                        tasks: data.tasks,
                        allClear: data.allClear,
                        noTaskHint: skin.panelNoTaskHint,
                      ),
                      if (data.idleInsight != null) ...[
                        const SizedBox(height: 10),
                        _InsightLine(text: data.idleInsight!),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) {
        debugPrint('[GuanguanPanelCard] ERROR: $e');
        return const SizedBox.shrink();
      },
    );
  }

  String _summaryLine(GuanguanPanelData data) {
    final taskPart = data.allClear
        ? '今日无待办'
        : '待办 ${data.tasks.length} 件';
    return '$taskPart · ${data.proficiency.spaceName} Lv.${data.proficiency.level}';
  }
}

class _ProficiencyRow extends StatelessWidget {
  const _ProficiencyRow({required this.proficiency});

  final SpaceProficiency proficiency;

  @override
  Widget build(BuildContext context) {
    final progress = (proficiency.recentActions % 5) / 5.0;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${proficiency.spaceName}熟练度 Lv.${proficiency.level}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress == 0 && proficiency.recentActions > 0
                      ? 1
                      : progress,
                  minHeight: 6,
                  backgroundColor: AppColors.gray100,
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '7日 ${proficiency.recentActions} 次',
          style: TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({
    required this.tasks,
    required this.allClear,
    required this.noTaskHint,
  });

  final List<GuanguanTask> tasks;
  final bool allClear;
  final String noTaskHint;

  @override
  Widget build(BuildContext context) {
    if (allClear) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Text(
          '今天没有待办，保持得不错～',
          style: TextStyle(fontSize: 13, color: AppColors.success),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Text(
        noTaskHint,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日任务',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...tasks.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _TaskTile(task: t),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final GuanguanTask task;

  @override
  Widget build(BuildContext context) {
    final icon = switch (task.kind) {
      GuanguanTaskKind.expiry => CandyIcons.schedule,
      GuanguanTaskKind.lowStock => CandyIcons.inventory,
      GuanguanTaskKind.other => CandyIcons.taskAlt,
    };

    return Material(
      color: AppColors.gray100.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: () {
          debugPrint('[GuanguanPanelCard] INFO: 打开物品 ${task.itemId}');
          context.push('/items/${task.itemId}');
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CandyIcon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      task.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              CandyIcon(Icons.chevron_right, size: 18, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuipLine extends StatelessWidget {
  const _QuipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CandyIcon(Icons.people_outline, size: 16, color: AppColors.accentSky),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CandyIcon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}
