import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../providers/quick_consume_provider.dart';
import 'usage_dialog.dart';

/// 记消耗快捷弹层 — 选物品 + 一键用 1 件
class QuickConsumeSheet {
  QuickConsumeSheet._();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    debugPrint('[QuickConsumeSheet] INFO: 打开记消耗');
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _QuickConsumeBody(parentRef: ref),
    );
  }
}

class _QuickConsumeBody extends ConsumerStatefulWidget {
  const _QuickConsumeBody({required this.parentRef});

  final WidgetRef parentRef;

  @override
  ConsumerState<_QuickConsumeBody> createState() => _QuickConsumeBodyState();
}

class _QuickConsumeBodyState extends ConsumerState<_QuickConsumeBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(quickConsumeItemsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '记消耗',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点「用1件」快速记录，点行可改数量',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '搜索物品名称',
                        prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.gray100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                  data: (items) {
                    final filtered = _query.isEmpty
                        ? items
                        : items
                            .where(
                              (i) => i.name
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()),
                            )
                            .toList();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          _query.isEmpty ? '暂无可消耗物品' : '未找到「$_query」',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _ConsumeTile(
                          item: filtered[index],
                          ref: widget.parentRef,
                          onChanged: () {
                            ref.invalidate(quickConsumeItemsProvider);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConsumeTile extends StatefulWidget {
  const _ConsumeTile({
    required this.item,
    required this.ref,
    required this.onChanged,
  });

  final Item item;
  final WidgetRef ref;
  final VoidCallback onChanged;

  @override
  State<_ConsumeTile> createState() => _ConsumeTileState();
}

class _ConsumeTileState extends State<_ConsumeTile> {
  bool _busy = false;

  Future<void> _quickUseOne() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await recordQuickUsage(ref: widget.ref, item: widget.item);
      if (!mounted) return;
      if (ok) {
        widget.onChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已记录使用 1 ${widget.item.unit}「${widget.item.name}」')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return ListTile(
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '剩余 ${item.currentQuantity.toStringAsFixed(0)} ${item.unit}',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      onTap: _busy
          ? null
          : () async {
              await showUsageDialog(
                context: context,
                ref: widget.ref,
                item: item,
                onCompleted: widget.onChanged,
              );
            },
      trailing: TextButton(
        onPressed: _busy ? null : _quickUseOne,
        child: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('用1件'),
      ),
    );
  }
}
