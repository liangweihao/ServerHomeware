import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/item_detail_provider.dart';
import '../../core/services/item_service.dart';
import '../../core/utils/item_api_id.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/warm_scaffold.dart';
import '../home/providers/home_sections_provider.dart';
import 'item_form_controller.dart';
import 'widgets/add_item_wizard_view.dart';

/// 编辑物品页 — 与添加入库相同的 4 步向导 + 预填数据
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
  AddItemWizardStep _currentStep = AddItemWizardStep.category;

  static const _steps = AddItemWizardStep.values;

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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case AddItemWizardStep.category:
        if (_form.selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择分类')),
          );
          return false;
        }
        return true;
      case AddItemWizardStep.basic:
        if (_form.nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入物品名称')),
          );
          return false;
        }
        return true;
      case AddItemWizardStep.location:
      case AddItemWizardStep.expiry:
        return true;
    }
  }

  void _goNextStep() {
    if (!_validateCurrentStep()) return;
    final idx = _currentStep.index;
    if (idx < _steps.length - 1) {
      setState(() => _currentStep = _steps[idx + 1]);
      debugPrint('[EditItemPage] INFO: 进入步骤 ${_currentStep.name}');
    }
  }

  void _goPrevStep() {
    final idx = _currentStep.index;
    if (idx > 0) {
      setState(() => _currentStep = _steps[idx - 1]);
    }
  }

  bool _validateAllStepsForSave() {
    if (_form.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      setState(() => _currentStep = AddItemWizardStep.category);
      return false;
    }
    if (_form.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入物品名称')),
      );
      setState(() => _currentStep = AddItemWizardStep.basic);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_isSaving || _originalItem == null) return;
    if (!_validateAllStepsForSave()) return;

    setState(() => _isSaving = true);

    try {
      final body = _form.buildUpdateApiBody();
      debugPrint('[EditItemPage] INFO: 更新物品 id=${widget.id}');

      final itemService = ItemService();
      final apiItemId = _originalItem!.serverApiId;
      final apiResult = await itemService.updateItem(
        itemId: apiItemId,
        body: body,
      );
      if (apiResult.code != 200) {
        debugPrint('[EditItemPage] WARN: 服务端更新失败 - ${apiResult.message}，仍写本地');
      }

      final updated = _form.applyToExistingItem(_originalItem!);
      final db = ref.read(databaseProvider);
      await db.updateItem(updated);

      ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: widget.id);
      ref.invalidate(itemDetailProvider(widget.id));
      ref.invalidate(allItemsProvider);
      ref.invalidate(itemByIdProvider(widget.id));
      ref.invalidate(homeSectionsProvider);

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
      return WarmScaffold(
        title: '编辑物品',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_originalItem == null) {
      return WarmScaffold(
        title: '编辑物品',
        body: AppEmptyState(
          icon: '📦',
          title: '物品不存在',
          subtitle: '无法编辑已删除的物品',
          actionLabel: '返回',
          onAction: () => context.pop(),
        ),
      );
    }

    final isLastStep = _currentStep == AddItemWizardStep.expiry;
    final isFirstStep = _currentStep == AddItemWizardStep.category;

    return WarmScaffold(
      title: '编辑物品',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AppCard(
                  child: AddItemWizardView(
                    controller: _form,
                    currentStep: _currentStep,
                    onChanged: _notifyFormChanged,
                    isEditMode: true,
                  ),
                ),
              ),
            ),
            _buildWizardNav(isFirstStep, isLastStep),
          ],
        ),
      ),
    );
  }

  /// 与添加入库一致的底部导航 — 末步仅「保存修改」
  Widget _buildWizardNav(bool isFirstStep, bool isLastStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: AppButton(
                label: '上一步',
                variant: ButtonVariant.outline,
                onPressed: _isSaving ? null : _goPrevStep,
                isFullWidth: true,
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: isLastStep ? '保存修改' : '下一步',
              onPressed: _isSaving
                  ? null
                  : () {
                      if (isLastStep) {
                        _save();
                      } else {
                        _goNextStep();
                      }
                    },
              isFullWidth: true,
              isLoading: _isSaving && isLastStep,
            ),
          ),
        ],
      ),
    );
  }
}
