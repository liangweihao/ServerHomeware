import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_list_entrance.dart';
import '../common/widgets/warm_scaffold.dart';

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

    return WarmScaffold(
      title: '$itemName · 使用记录',
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (result) {
          final (item, records) = result;
          if (records.isEmpty) {
            return const Center(child: Text('暂无使用记录'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              return AppListEntrance(
                index: index,
                child: _TimelineTile(
                  record: records[index],
                  isLast: index == records.length - 1,
                  item: item,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final _allUsageRecordsProvider =
    FutureProvider.family<(Item, List<UsageRecord>), int>((ref, itemId) async {
  final db = ref.watch(databaseProvider);
  final item = (await db.getItemById(itemId))!;
  final records = await db.getUsageRecordsByItem(itemId, limit: 500);
  return (item, records);
});

class _TimelineTile extends StatelessWidget {
  final UsageRecord record;
  final bool isLast;
  final Item item;

  const _TimelineTile({
    required this.record,
    required this.isLast,
    required this.item,
  });

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
                  decoration: BoxDecoration(
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
    final qty = _formatQuantity(record.quantity, item);
    final remain = _formatQuantity(record.remainingQuantity, item);
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

  /// 格式化数量，按最小单位显示，有包装时追加换算
  String _formatQuantity(double quantity, Item item) {
    final numStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    final base = '$numStr${item.unit}';
    // 如果有包装单位，追加包装换算
    if (item.packageUnit != null &&
        item.packageUnit!.isNotEmpty &&
        item.packageQuantity > 1) {
      final packages = quantity ~/ item.packageQuantity;
      final pieces = (quantity % item.packageQuantity).round();
      if (packages > 0 && pieces > 0) {
        return '$base ($packages ${item.packageUnit} $pieces ${item.unit})';
      } else if (packages > 0) {
        return '$base ($packages ${item.packageUnit})';
      }
    }
    return base;
  }
}
