import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/item_detail_provider.dart';
import '../../core/services/consumption_prediction_service.dart';
import '../../core/services/item_service.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_progress_bar.dart';
import '../common/widgets/app_tag.dart';
import '../common/widgets/location_picker.dart';
import 'widgets/usage_dialog.dart';
import 'widgets/item_image_tile.dart';

/// 物品详情页（对齐 doc/原型图.md §四、Phase 2 任务4）
class ItemDetailPage extends ConsumerStatefulWidget {
  final int id;

  const ItemDetailPage({super.key, required this.id});

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  void _refresh() {
    ref.invalidate(itemDetailProvider(widget.id));
    ref.invalidate(allItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(itemDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('物品详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/items/${widget.id}/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuAction(value, detailAsync.valueOrNull),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'move', child: Text('移动位置')),
              const PopupMenuItem(value: 'expired', child: Text('标记过期')),
              const PopupMenuItem(value: 'discard', child: Text('丢弃')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('[ItemDetailPage] ERROR: 加载失败 $e');
          return AppEmptyState(
            icon: '⚠️',
            title: '加载失败',
            subtitle: e.toString(),
            actionLabel: '重试',
            onAction: _refresh,
          );
        },
        data: (data) {
          if (data == null) {
            return AppEmptyState(
              icon: '📦',
              title: '物品不存在',
              subtitle: '该物品可能已被删除',
              actionLabel: '返回',
              onAction: () => context.pop(),
            );
          }
          return _buildBody(context, data);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ItemDetailData data) {
    final item = data.item;
    final purchaseQty = item.purchaseQuantity.toDouble().clamp(1, double.infinity);
    final remainingRatio = (item.currentQuantity / purchaseQty).clamp(0.0, 1.0);
    final usedPercent = ((1 - remainingRatio) * 100).round();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _buildImageSection(data),
                const SizedBox(height: 16),
                _buildTitleSection(context, data),
                const SizedBox(height: 20),
                _buildSectionLabel('状态总览'),
                const SizedBox(height: 12),
                _buildMetricsRow(item),
                const SizedBox(height: 16),
                AppProgressBar(value: remainingRatio, height: 8),
                const SizedBox(height: 8),
                Text(
                  '已使用约 $usedPercent%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _predictionText(item),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                _buildSectionLabel('详细信息'),
                const SizedBox(height: 8),
                _buildDetailList(context, data),
                const SizedBox(height: 24),
                _buildSectionLabel('使用记录'),
                const SizedBox(height: 12),
                _buildUsageTimeline(context, data),
              ],
            ),
          ),
        ),
        _buildBottomBar(context, item),
      ],
    );
  }

  Widget _buildImageSection(ItemDetailData data) {
    final categoryIcon = data.category?.icon ?? '📦';
    final imageUrls = data.imageUrls;

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrls.isNotEmpty
          ? PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                ),
                child: Image.network(
                  imageUrls[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          : _placeholderIcon(categoryIcon),
    );
  }

  Widget _placeholderIcon(String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            '暂无图片',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, ItemDetailData data) {
    final item = data.item;
    final title = item.specification != null && item.specification!.isNotEmpty
        ? '${item.name} ${item.specification}'
        : item.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AppTag(label: data.categoryLabel, size: TagSize.small),
            if (item.brand != null && item.brand!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                '品牌：${item.brand}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
        if (item.status != 0) ...[
          const SizedBox(height: 8),
          AppTag(
            label: _statusLabel(item.status),
            variant: item.status == 1
                ? TagVariant.info
                : item.status == 2
                    ? TagVariant.warning
                    : TagVariant.danger,
            size: TagSize.small,
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsRow(Item item) {
    return Row(
      children: [
        Expanded(child: _metricCard('剩余数量', _quantityText(item), _stockColor(item))),
        const SizedBox(width: 8),
        Expanded(child: _metricCard('过期倒计时', _expiryText(item), _expiryColor(item))),
        const SizedBox(width: 8),
        Expanded(child: _metricCard('消耗速率', _consumptionText(item), AppColors.textPrimary)),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(BuildContext context, ItemDetailData data) {
    final item = data.item;
    final priceLine = item.purchasePrice != null
        ? '¥${item.purchasePrice!.toStringAsFixed(1)} × ${item.purchaseQuantity} = ¥${(item.purchasePrice! * item.purchaseQuantity).toStringAsFixed(1)}'
        : '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          _buildLocationRow(context, data),
          _detailRow('💰', '购买价格', priceLine),
          _detailRow('🛒', '购买渠道', item.purchaseChannel ?? '—'),
          _detailRow('📅', '购买日期', _formatDate(item.purchaseDate)),
          _detailRow('📅', '生产日期', _formatDate(item.productionDate)),
          _detailRow('⏰', '到期日期', _formatDate(item.expiryDate)),
          _detailRow('🔔', '提醒设置', _alertSettingsText(item)),
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, ItemDetailData data) {
    final locationPhotos = data.locationImageUrls;

    return Column(
      children: [
        _detailRow('📍', '存放位置', data.locationPath ?? '未设置'),
        if (locationPhotos.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: locationPhotos.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    // 全屏预览
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.network(
                            locationPhotos[i],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ItemImageTile(
                      source: locationPhotos[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTimeline(BuildContext context, ItemDetailData data) {
    final records = data.recentRecords;
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('暂无使用记录', style: TextStyle(color: AppColors.textHint)),
      );
    }

    return Column(
      children: [
        ...records.asMap().entries.map((e) {
          return _usageRecordRow(
            context,
            e.value,
            isLast: e.key == records.length - 1,
          );
        }),
        TextButton(
          onPressed: () {
            context.push(
              '/items/${widget.id}/records?name=${Uri.encodeComponent(data.item.name)}',
            );
          },
          child: const Text('查看全部记录 →'),
        ),
      ],
    );
  }

  Widget _usageRecordRow(
    BuildContext context,
    UsageRecord record, {
    required bool isLast,
  }) {
    final dateStr = DateFormat('MM-dd').format(record.createdAt);
    final desc = _usageDesc(record);
    final operator = record.operatorName ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$dateStr  $desc${operator.isNotEmpty ? '  $operator' : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Item item) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: '使用1件',
              variant: ButtonVariant.secondary,
              size: ButtonSize.medium40,
              onPressed: item.status == 0 && item.currentQuantity > 0
                  ? () => _onUseOne(item)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: '已用完',
              variant: ButtonVariant.outline,
              size: ButtonSize.medium40,
              onPressed: item.status == 0 ? () => _onMarkFinished(item) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: '再次购买',
              size: ButtonSize.medium40,
              onPressed: () => _onRepurchase(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // —— 操作 ——

  Future<void> _onUseOne(Item item) async {
    await showUsageDialog(
      context: context,
      ref: ref,
      item: item,
      onCompleted: () {
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已记录使用')),
          );
        }
      },
    );
  }

  Future<void> _onMarkFinished(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('标记已用完？'),
        content: Text('将「${item.name}」剩余数量清零'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final db = ref.read(databaseProvider);
    await db.updateItem(item.copyWith(
      currentQuantity: 0,
      status: 1,
      updatedAt: DateTime.now(),
    ));
    await db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: item.id,
        type: 1,
        quantity: item.currentQuantity,
        remainingQuantity: 0,
      ),
    );
    await ConsumptionPredictionService(db).onItemUsed(item.id);

    // 同步到服务端
    ItemService().updateItem(
      itemId: item.id,
      body: {'status': 1, 'current_quantity': 0},
    );

    // 通知事件总线：物品状态已变更
    ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);

    debugPrint('[ItemDetailPage] INFO: 标记已用完 id=${item.id}');
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${item.name}」已标记为用完')),
      );
    }
  }

  Future<void> _onRepurchase(Item item) async {
    final db = ref.read(databaseProvider);
    await db.insertShoppingListItem(
      ShoppingListCompanion.insert(
        name: item.name,
        relatedItemId: Value(item.id),
        quantity: Value(item.purchaseQuantity.toDouble()),
        unit: Value(item.unit),
        estimatedPrice:
            item.purchasePrice != null ? Value(item.purchasePrice!) : const Value.absent(),
        isAutoGenerated: const Value(true),
      ),
    );
    debugPrint('[ItemDetailPage] INFO: 加入购物清单 id=${item.id}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${item.name}」已加入购物清单')),
      );
    }
  }

  void _onMenuAction(String action, ItemDetailData? data) {
    if (data == null) return;
    final item = data.item;
    switch (action) {
      case 'move':
        _onMoveLocation(item);
        break;
      case 'expired':
        _onMarkExpired(item);
        break;
      case 'discard':
        _onDiscard(item);
        break;
      case 'delete':
        _onDelete(item);
        break;
    }
  }

  Future<void> _onMoveLocation(Item item) async {
    Location? current;
    if (item.locationId != null) {
      current = await ref.read(databaseProvider).getLocationById(item.locationId!);
    }
    if (!mounted) return;

    LocationPicker.show(
      context,
      selectedLocation: current,
      onSelected: (location) async {
        final db = ref.read(databaseProvider);
        await db.updateItem(item.copyWith(
          locationId: Value(location.id),
          updatedAt: DateTime.now(),
        ));
        await db.insertUsageRecord(
          UsageRecordsCompanion.insert(
            itemId: item.id,
            type: 3,
            quantity: 0,
            remainingQuantity: item.currentQuantity,
            notes: Value('移至 ${location.fullPath}'),
          ),
        );

        // 同步到服务端
        ItemService().updateItem(
          itemId: item.id,
          body: {'location_id': location.id},
        );

        // 通知事件总线：物品位置已变更
        ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);

        debugPrint('[ItemDetailPage] INFO: 移动位置 id=${item.id} -> ${location.fullPath}');
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已移至 ${location.fullPath}')),
          );
        }
      },
    );
  }

  Future<void> _onMarkExpired(Item item) async {
    final db = ref.read(databaseProvider);
    await db.updateItem(item.copyWith(status: 2, updatedAt: DateTime.now()));
    await db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: item.id,
        type: 2,
        quantity: item.currentQuantity,
        remainingQuantity: item.currentQuantity,
        notes: Value('标记过期'),
      ),
    );

    // 同步到服务端
    ItemService().updateItem(itemId: item.id, body: {'status': 2});

    // 通知事件总线：物品状态已变更
    ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);

    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${item.name}」已标记为过期')),
      );
    }
  }

  Future<void> _onDiscard(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认丢弃？'),
        content: Text('将丢弃「${item.name}」'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('丢弃', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final db = ref.read(databaseProvider);
    await db.updateItem(item.copyWith(status: 3, updatedAt: DateTime.now()));
    await db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: item.id,
        type: 2,
        quantity: item.currentQuantity,
        remainingQuantity: 0,
      ),
    );

    // 同步到服务端
    ItemService().updateItem(itemId: item.id, body: {'status': 3});

    // 通知事件总线：物品已丢弃
    ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: item.id);

    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${item.name}」已丢弃')),
      );
    }
  }

  Future<void> _onDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除物品？'),
        content: Text('确定删除「${item.name}」？此操作不可恢复'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(databaseProvider).deleteItem(item.id);

    // 同步到服务端
    ItemService().deleteItem(itemId: item.id);

    // 通知事件总线：物品已删除
    ref.read(itemEventBusProvider.notifier).notifyDeleted(itemId: item.id);

    debugPrint('[ItemDetailPage] INFO: 删除物品 id=${item.id}');
    ref.invalidate(allItemsProvider);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${item.name}」已删除')),
      );
    }
  }

  // —— 文案 / 颜色 ——

  String _quantityText(Item item) {
    return '${item.currentQuantity.toStringAsFixed(0)} / ${item.purchaseQuantity} ${item.unit}';
  }

  Color _stockColor(Item item) {
    if (item.currentQuantity <= 0) return AppColors.danger;
    if (item.currentQuantity <= item.safetyStock) return AppColors.warning;
    return AppColors.success;
  }

  String _expiryText(Item item) {
    if (item.expiryDate == null) return '无限制';
    final days = item.expiryDate!.difference(DateTime.now()).inDays;
    if (days < 0) return '已过期';
    return '$days 天';
  }

  Color _expiryColor(Item item) {
    if (item.expiryDate == null) return AppColors.textSecondary;
    final days = item.expiryDate!.difference(DateTime.now()).inDays;
    if (days < 0) return AppColors.danger;
    if (days <= 3) return AppColors.danger;
    if (days <= 7) return AppColors.warning;
    return AppColors.success;
  }

  String _consumptionText(Item item) {
    if (item.avgDailyConsumption != null && item.avgDailyConsumption! > 0) {
      final weekly = item.avgDailyConsumption! * 7;
      final formatted =
          weekly == weekly.roundToDouble() ? weekly.toInt() : weekly.toStringAsFixed(1);
      return '$formatted${item.unit}/周';
    }
    return '暂无数据';
  }

  String _predictionText(Item item) {
    if (item.predictedEmptyDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(item.predictedEmptyDate!);
      final days = item.predictedEmptyDate!.difference(DateTime.now()).inDays;
      if (days >= 0) {
        return '预计用完时间：$dateStr（约 $days 天后）';
      }
    }
    return '预计用完时间：暂无预测数据';
  }

  String _alertSettingsText(Item item) {
    final parts = <String>[];
    if (item.expiryDate != null) {
      parts.add('到期前${item.expiryAlertDays}天');
    }
    if (item.stockAlert) {
      parts.add('剩余${item.safetyStock.toStringAsFixed(0)}${item.unit}时');
    }
    return parts.isEmpty ? '未设置' : parts.join(' / ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return '已用完';
      case 2:
        return '已过期';
      case 3:
        return '已丢弃';
      default:
        return '使用中';
    }
  }

  String _usageDesc(UsageRecord record) {
    final qty = record.quantity.toStringAsFixed(
      record.quantity == record.quantity.roundToDouble() ? 0 : 1,
    );
    final remain = record.remainingQuantity.toStringAsFixed(
      record.remainingQuantity == record.remainingQuantity.roundToDouble() ? 0 : 1,
    );
    switch (record.type) {
      case 0:
        return '入库 $qty  剩余$remain';
      case 1:
        return '使用 $qty  剩余$remain';
      case 2:
        return '丢弃 $qty';
      case 3:
        return '移动位置';
      case 4:
        return '调整';
      default:
        return '操作';
    }
  }
}
