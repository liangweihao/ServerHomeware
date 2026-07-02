import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/providers/alert_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/consumption_prediction_service.dart';
import '../../../core/services/item_service.dart';
import '../../../core/services/usage_record_sync_service.dart';
import '../../../core/utils/item_api_id.dart';
import '../../../core/utils/usage_operator_helper.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/quantity_stepper.dart';

/// 记录使用弹窗（对应 Phase 2 UsageDialog）
Future<void> showUsageDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Item item,
  required VoidCallback onCompleted,
}) async {
  final members = await ref.read(databaseProvider).getFamilyMembers();
  final defaultOperator = resolveUsageOperatorName(ref);
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _UsageDialogContent(
      item: item,
      members: members,
      initialOperatorName: defaultOperator,
      onConfirm: (quantity, operatorName, markAllUsed) async {
        await applyItemUsage(
          ref: ref,
          item: item,
          quantity: markAllUsed ? item.currentQuantity : quantity,
          operatorName: operatorName,
          markAllUsed: markAllUsed,
        );
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        onCompleted();
      },
    ),
  );
}

/// 记录物品消耗 — 写本地、同步服务端、刷新提醒
Future<void> applyItemUsage({
  required WidgetRef ref,
  required Item item,
  required double quantity,
  String? operatorName,
  required bool markAllUsed,
}) async {
  final db = ref.read(databaseProvider);
  final useQty = markAllUsed ? item.currentQuantity : quantity;
  if (useQty <= 0) return;

  final operator = operatorName ?? resolveUsageOperatorName(ref);
  final newRemaining =
      (item.currentQuantity - useQty).clamp(0.0, double.infinity);
  final newStatus = newRemaining <= 0 ? 1 : item.status;

  await db.updateItem(item.copyWith(
    currentQuantity: newRemaining,
    status: newStatus,
    updatedAt: DateTime.now(),
  ));

  final sync = UsageRecordSyncService(db);
  await sync.recordAndSync(
    itemId: item.id,
    type: 1,
    quantity: useQty,
    remainingQuantity: newRemaining,
    operatorName: operator,
  );

  ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);
  invalidateAlertProviders(ref);

  await ConsumptionPredictionService(db).onItemUsed(item.id);

  debugPrint(
    '[UsageAction] INFO: 记录使用 itemId=${item.id} qty=$useQty operator=$operator remaining=$newRemaining',
  );
}

/// 标记物品已丢弃 — 提醒中心/详情快捷丢弃共用
Future<bool> recordItemDiscard({
  required WidgetRef ref,
  required Item item,
  String? operatorName,
}) async {
  final db = ref.read(databaseProvider);
  final operator = operatorName ?? resolveUsageOperatorName(ref);

  await db.updateItem(item.copyWith(
    status: 3,
    updatedAt: DateTime.now(),
  ));

  final sync = UsageRecordSyncService(db);
  await sync.recordAndSync(
    itemId: item.id,
    type: 2,
    quantity: item.currentQuantity,
    remainingQuantity: 0,
    operatorName: operator,
    notes: '已丢弃',
  );

  ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);
  invalidateAlertProviders(ref);

  try {
    await ItemService().updateItem(itemId: item.serverApiId, body: {'status': 3});
  } catch (e) {
    debugPrint('[UsageAction] WARN: 同步丢弃到服务端失败: $e');
  }

  debugPrint(
    '[UsageAction] INFO: 丢弃 itemId=${item.id} operator=$operator',
  );
  return true;
}

/// 一键记消耗 — 默认使用 1 件，无弹窗
Future<bool> recordQuickUsage({
  required WidgetRef ref,
  required Item item,
  double quantity = 1,
}) async {
  if (item.status != 0 || item.currentQuantity <= 0) return false;
  final useQty = quantity.clamp(1, item.currentQuantity).toDouble();
  await applyItemUsage(
    ref: ref,
    item: item,
    quantity: useQty,
    operatorName: resolveUsageOperatorName(ref),
    markAllUsed: false,
  );
  return true;
}

class _UsageDialogContent extends StatefulWidget {
  final Item item;
  final List<FamilyMember> members;
  final String? initialOperatorName;
  final Future<void> Function(double quantity, String? operator, bool markAllUsed)
      onConfirm;

  const _UsageDialogContent({
    required this.item,
    required this.members,
    this.initialOperatorName,
    required this.onConfirm,
  });

  @override
  State<_UsageDialogContent> createState() => _UsageDialogContentState();
}

class _UsageDialogContentState extends State<_UsageDialogContent> {
  double _quantity = 1;
  late String? _operatorName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _operatorName = widget.initialOperatorName;
  }

  double get _remainingAfter =>
      (widget.item.currentQuantity - _quantity).clamp(0.0, double.infinity);

  bool get _lowStockWarning =>
      _remainingAfter > 0 && _remainingAfter <= widget.item.safetyStock;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('记录使用'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前剩余：${widget.item.currentQuantity.toStringAsFixed(0)} ${widget.item.unit}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '本次使用数量',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Center(
              child: QuantityStepper(
                value: _quantity,
                min: 1,
                max: widget.item.currentQuantity,
                unit: widget.item.unit,
                onChanged: (v) => setState(() => _quantity = v),
              ),
            ),
            if (widget.members.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '操作人',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.members.map((m) {
                  final selected = _operatorName == m.name;
                  return ChoiceChip(
                    label: Text(m.name),
                    selected: selected,
                    onSelected: (_) => setState(() => _operatorName = m.name),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '使用后剩余：${_remainingAfter.toStringAsFixed(0)} ${widget.item.unit}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_lowStockWarning) ...[
              const SizedBox(height: 8),
              const Text(
                '⚠️ 使用后库存将低于安全库存',
                style: TextStyle(color: AppColors.warning, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        AppButton(
          label: '全部用完',
          variant: ButtonVariant.outline,
          size: ButtonSize.small32,
          onPressed: _submitting
              ? null
              : () async {
                  setState(() => _submitting = true);
                  try {
                    await widget.onConfirm(_quantity, _operatorName, true);
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
        ),
        AppButton(
          label: '确认使用',
          size: ButtonSize.small32,
          isLoading: _submitting,
          onPressed: _submitting
              ? null
              : () async {
                  setState(() => _submitting = true);
                  try {
                    await widget.onConfirm(_quantity, _operatorName, false);
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
        ),
      ],
    );
  }
}
