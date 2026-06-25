import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/item_detail_provider.dart';
import '../../core/services/item_service.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/cartoon_scaffold.dart';
import 'item_form_controller.dart';
import 'item_form_view.dart';

/// 编辑物品页（复用添加表单，预填本地数据）
class EditItemPage extends ConsumerStatefulWidget {
  final int id;

  const EditItemPage({super.key, required this.id});

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  late final ItemFormController _form;
  bool _isLoading = true;
  bool _isSaving = false;
  Item? _originalItem;

  @override
  void initState() {
    super.initState();
    _form = ItemFormController();
    _loadItem();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      await db.ensureInitialized();
      final item = await db.getItemById(widget.id);
      if (item == null) {
        debugPrint('[EditItemPage] WARN: 物品不存在 id=${widget.id}');
        setState(() => _isLoading = false);
        return;
      }

      final category = await db.getCategoryById(item.categoryId);
      Location? location;
      if (item.locationId != null) {
        location = await db.getLocationById(item.locationId!);
      }

      _originalItem = item;
      _form.loadFromItem(item: item, category: category, location: location);
      debugPrint('[EditItemPage] INFO: 预填物品 ${item.name}');
    } catch (e) {
      debugPrint('[EditItemPage] ERROR: 加载失败 $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _notifyFormChanged() => setState(() {});

  Future<void> _save() async {
    if (_isSaving || _originalItem == null) return;
    if (!_form.validate()) {
      if (_form.selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择分类')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = _form.buildUpdateApiBody();
      debugPrint('[EditItemPage] INFO: 更新物品 id=${widget.id}');

      final itemService = ItemService();
      final apiResult = await itemService.updateItem(
        itemId: widget.id,
        body: body,
      );
      if (apiResult.code != 200) {
        debugPrint('[EditItemPage] WARN: 服务端更新失败 - ${apiResult.message}，仍写本地');
      }

      final updated = _form.applyToExistingItem(_originalItem!);
      final db = ref.read(databaseProvider);
      await db.updateItem(updated);

      // 通知事件总线：物品已更新
      ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: widget.id);

      ref.invalidate(itemDetailProvider(widget.id));
      ref.invalidate(allItemsProvider);
      ref.invalidate(itemByIdProvider(widget.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('[EditItemPage] ERROR: 保存异常 $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_originalItem == null) {
      return CartoonScaffold(
        title: '编辑物品',
        titleEmoji: '✏️',
        body: AppEmptyState(
          icon: '📦',
          title: '物品不存在',
          subtitle: '无法编辑已删除的物品',
          actionLabel: '返回',
          onAction: () => context.pop(),
        ),
      );
    }

    return CartoonScaffold(
      title: '编辑物品',
      titleEmoji: '✏️',
      actions: [
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
      body: ColoredBox(
        color: AppColors.gray50,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ItemFormView(
                    controller: _form,
                    onChanged: _notifyFormChanged,
                    isEditMode: true,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    label: '保存修改',
                    onPressed: _isSaving ? null : _save,
                    isFullWidth: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
