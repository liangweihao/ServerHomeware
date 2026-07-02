import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/inventory_task_provider.dart';
import '../../core/services/inventory_reminder_prefs.dart';
import '../../core/services/notification_scheduler.dart';
import '../../data/database/app_database.dart';
import 'inventory_task_storage.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_progress_bar.dart';
import '../common/widgets/warm_scaffold.dart';

/// 盘点任务页 — Epic E3（含子空间物品、进度条、报告明细）
class InventoryTaskPage extends ConsumerWidget {
  const InventoryTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(inventoryTaskProvider);

    if (session.completed) {
      return _ReportView(
        session: session,
        onDone: () {
          ref.read(inventoryTaskProvider.notifier).reset();
          context.pop();
        },
      );
    }

    if (session.locationId == null) {
      return _LocationPicker(
        onSelected: (id, name) {
          ref.read(inventoryTaskProvider.notifier).startForLocation(id, name);
        },
      );
    }

    return _ChecklistView(session: session);
  }
}

/// 选择盘点空间
class _LocationPicker extends ConsumerStatefulWidget {
  const _LocationPicker({required this.onSelected});

  final void Function(int id, String name) onSelected;

  @override
  ConsumerState<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<_LocationPicker> {
  late Future<List<InventoryHistoryEntry>> _historyFuture;
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _historyFuture = InventoryTaskStorage.load();
    _loadReminderPref();
  }

  Future<void> _loadReminderPref() async {
    final enabled = await InventoryReminderPrefs.isEnabled();
    if (mounted) setState(() => _reminderEnabled = enabled);
  }

  Future<void> _toggleReminder(bool value) async {
    await InventoryReminderPrefs.setEnabled(value);
    final scheduler = NotificationScheduler();
    if (value) {
      final day = await InventoryReminderPrefs.dayOfMonth();
      await scheduler.scheduleInventoryReminder(dayOfMonth: day);
    } else {
      await scheduler.cancelInventoryReminder();
    }
    if (mounted) setState(() => _reminderEnabled = value);
    debugPrint('[InventoryTaskPage] INFO: 盘点提醒 enabled=$value');
  }

  void _reloadHistory() {
    setState(() {
      _historyFuture = InventoryTaskStorage.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(inventoryLocationOptionsProvider);

    return WarmScaffold(
      title: '盘点任务',
      body: locationsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return const Center(
              child: Text('暂无空间，请先在位置管理中添加'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('每月盘点提醒'),
                subtitle: const Text('每月 1 日上午 10 点本地通知'),
                value: _reminderEnabled,
                onChanged: _toggleReminder,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '选择要盘点的空间（含子位置物品）',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    final loc = opt.location;
                    return ListTile(
                      tileColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.homeDivider),
                      ),
                      leading: Text(
                        loc.icon ?? '📍',
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(loc.name),
                      subtitle: Text(
                        '${loc.fullPath} · ${opt.itemCount} 件使用中',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => widget.onSelected(loc.id, loc.name),
                    );
                  },
                ),
              ),
              FutureBuilder<List<InventoryHistoryEntry>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  final history = snapshot.data ?? [];
                  if (history.isEmpty) return const SizedBox.shrink();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border(top: BorderSide(color: AppColors.homeDivider)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '最近盘点',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _reloadHistory,
                              child: const Text('刷新'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...history.take(3).map((entry) {
                          final date = entry.completedAt;
                          final dateStr =
                              '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                          final alert = entry.expiredAlertCount > 0 ||
                                  entry.expiringAlertCount > 0
                              ? ' · 过期${entry.expiredAlertCount} 临期${entry.expiringAlertCount}'
                              : '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '$dateStr · ${entry.locationName} · '
                              '确认${entry.confirmedCount} 修正${entry.adjustedCount}$alert',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

/// 逐项核对清单
class _ChecklistView extends ConsumerWidget {
  const _ChecklistView({required this.session});

  final InventorySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(inventoryTaskProvider.notifier);

    return WarmScaffold(
      title: '盘点 · ${session.locationName}',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '进度 ${session.doneCount}/${session.totalCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      session.totalCount == 0
                          ? '该空间及子位置暂无物品'
                          : '逐项确认或修正',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (session.totalCount > 0) ...[
                  const SizedBox(height: 8),
                  AppProgressBar(
                    value: session.progress,
                    height: 8,
                    colorMode: ColorMode.fixed,
                    fixedColor: AppColors.primary,
                  ),
                ],
                if (session.expiredAlertCount > 0 ||
                    session.expiringAlertCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ 含过期 ${session.expiredAlertCount} 件、临期 ${session.expiringAlertCount} 件',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: session.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('该空间及子位置暂无使用中物品'),
                        const SizedBox(height: 12),
                        AppButton(
                          label: '确认空空间',
                          onPressed: () => notifier.completeEmptyLocation(),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.read(inventoryTaskProvider.notifier).reset(),
                          child: const Text('重新选择空间'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: session.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = session.items[index];
                      final status = session.statusByItemId[item.id] ??
                          InventoryCheckStatus.pending;
                      return _InventoryItemRow(
                        item: item,
                        status: status,
                        adjustedQty: session.adjustedQtyByItemId[item.id],
                        onConfirm: () => notifier.confirmItem(item.id),
                        onSkip: () => notifier.skipItem(item.id),
                        onAdjust: (qty) => notifier.adjustItem(item.id, qty),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemRow extends StatelessWidget {
  const _InventoryItemRow({
    required this.item,
    required this.status,
    this.adjustedQty,
    required this.onConfirm,
    required this.onSkip,
    required this.onAdjust,
  });

  final Item item;
  final InventoryCheckStatus status;
  final double? adjustedQty;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;
  final void Function(double qty) onAdjust;

  String? _expiryHint() {
    final expiry = item.expiryDate;
    if (expiry == null) return null;
    final today = DateTime.now();
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    if (expiryDay.isBefore(todayDay)) return '已过期';
    final days = expiryDay.difference(todayDay).inDays;
    if (days <= 7) return '临期 $days 天';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = status != InventoryCheckStatus.pending;
    final expiryHint = _expiryHint();
    final statusLabel = switch (status) {
      InventoryCheckStatus.confirmed => '已确认',
      InventoryCheckStatus.adjusted =>
        '已修正为 ${adjustedQty?.toStringAsFixed(0) ?? ''}',
      InventoryCheckStatus.skipped => '已跳过',
      InventoryCheckStatus.pending => '待核对',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.homeDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '账面 ${item.currentQuantity} ${item.unit} · $statusLabel',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (expiryHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                expiryHint,
                style: TextStyle(
                  fontSize: 12,
                  color: expiryHint.startsWith('已过期')
                      ? AppColors.danger
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!isDone) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onConfirm,
                  child: const Text('确认'),
                ),
                OutlinedButton(
                  onPressed: () => _showAdjustDialog(context),
                  child: const Text('修正'),
                ),
                TextButton(onPressed: onSkip, child: const Text('跳过')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAdjustDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: item.currentQuantity.toString(),
    );
    final qty = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修正剩余量'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '实际剩余 (${item.unit})',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null && v >= 0) Navigator.pop(ctx, v);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (qty != null) onAdjust(qty);
  }
}

/// 盘点报告
class _ReportView extends StatelessWidget {
  const _ReportView({required this.session, required this.onDone});

  final InventorySession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      title: '盘点报告',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.locationName ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _ReportRow(label: '核对总数', value: '${session.totalCount}'),
            _ReportRow(label: '确认无误', value: '${session.confirmedCount}'),
            _ReportRow(label: '数量修正', value: '${session.adjustedCount}'),
            _ReportRow(label: '跳过', value: '${session.skippedCount}'),
            if (session.expiredAlertCount > 0)
              _ReportRow(
                label: '发现过期',
                value: '${session.expiredAlertCount}',
                valueColor: AppColors.danger,
              ),
            if (session.expiringAlertCount > 0)
              _ReportRow(
                label: '发现临期',
                value: '${session.expiringAlertCount}',
                valueColor: AppColors.warning,
              ),
            if (session.adjustmentRecords.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '修正明细',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...session.adjustmentRecords.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${r.itemName}：${r.oldQty.toStringAsFixed(0)} → '
                    '${r.newQty.toStringAsFixed(0)} ${r.unit}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
            const Spacer(),
            AppButton(label: '完成', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
