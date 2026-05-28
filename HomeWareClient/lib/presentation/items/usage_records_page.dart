import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';

/// 物品全部使用记录页
class UsageRecordsPage extends ConsumerWidget {
  final int itemId;
  final String itemName;

  const UsageRecordsPage({
    super.key,
    required this.itemId,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_allUsageRecordsProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: Text('$itemName · 使用记录')),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('暂无使用记录'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              return _TimelineTile(
                record: records[index],
                isLast: index == records.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}

final _allUsageRecordsProvider =
    FutureProvider.family<List<UsageRecord>, int>((ref, itemId) async {
  final db = ref.watch(databaseProvider);
  return db.getUsageRecordsByItem(itemId, limit: 500);
});

class _TimelineTile extends StatelessWidget {
  final UsageRecord record;
  final bool isLast;

  const _TimelineTile({required this.record, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MM-dd HH:mm').format(record.createdAt);
    final desc = _recordDescription(record);
    final operator = record.operatorName;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                  if (operator != null && operator.isNotEmpty)
                    Text(
                      operator,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _recordDescription(UsageRecord record) {
    final qty = record.quantity.toStringAsFixed(
      record.quantity == record.quantity.roundToDouble() ? 0 : 1,
    );
    final remain = record.remainingQuantity.toStringAsFixed(
      record.remainingQuantity ==
              record.remainingQuantity.roundToDouble()
          ? 0
          : 1,
    );
    switch (record.type) {
      case 0:
        return '入库 $qty，剩余 $remain';
      case 1:
        return '使用 $qty，剩余 $remain';
      case 2:
        return '丢弃 $qty';
      case 3:
        return '移动位置';
      case 4:
        return '调整数量';
      default:
        return '操作 $qty';
    }
  }
}
