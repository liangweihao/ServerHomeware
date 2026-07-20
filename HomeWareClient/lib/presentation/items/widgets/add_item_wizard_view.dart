import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/auth/shop_role_guard.dart';
import '../../../core/providers/family_role_provider.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../category_form_policy.dart';
import '../item_form_controller.dart';
import 'item_form_category_chips.dart';
import 'item_image_picker_section.dart';
import 'item_location_photo_section.dart';
import 'notes_magic_field.dart';
import '../../common/widgets/location_picker.dart';
import '../../common/widgets/app_date_picker.dart';
import '../../common/widgets/quantity_stepper.dart';

/// 添加入库分步向导 — 借鉴闲鱼发布结构，≤4 步
enum AddItemWizardStep {
  category,
  basic,
  location,
  expiry,
}

/// 路由 query `step` → 向导步骤
AddItemWizardStep? addItemWizardStepFromQuery(String? query) {
  switch (query) {
    case 'category':
      return AddItemWizardStep.category;
    case 'basic':
      return AddItemWizardStep.basic;
    case 'location':
      return AddItemWizardStep.location;
    case 'expiry':
      return AddItemWizardStep.expiry;
    default:
      return null;
  }
}

/// 分步入库 UI（与 [ItemFormController] 共享状态）
class AddItemWizardView extends ConsumerStatefulWidget {
  const AddItemWizardView({
    super.key,
    required this.controller,
    required this.currentStep,
    required this.onChanged,
    this.completedThroughStep,
    this.isEditMode = false,
  });

  final ItemFormController controller;
  final AddItemWizardStep currentStep;
  final VoidCallback onChanged;
  /// 扫码预填时，该步骤及之前步骤在指示器中显示为已完成
  final AddItemWizardStep? completedThroughStep;
  /// 编辑模式 — 隐藏扫码、展示剩余量与安全库存
  final bool isEditMode;

  @override
  ConsumerState<AddItemWizardView> createState() => _AddItemWizardViewState();
}

class _AddItemWizardViewState extends ConsumerState<AddItemWizardView> {
  ItemFormController get c => widget.controller;

  Future<void> _onCategorySelected(Category category) async {
    final db = ref.read(databaseProvider);
    final top = await CategoryFormPolicy.resolveTopLevel(category, db);
    if (top == null) return;
    CategoryFormPolicy.applyAlertDefaults(c, category, top);
    c.selectedCategory = category;
    debugPrint('[AddItemWizard] INFO: 选择分类 ${category.name}');
    widget.onChanged();
  }

  Future<void> _pickDate(
    BuildContext context,
    String title,
    DateTime? initial,
    ValueChanged<DateTime?> onSelected,
  ) async {
    final picked = await AppDatePicker.show(
      context,
      title: title,
      initialDate: initial,
    );
    if (picked != null) {
      onSelected(picked);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(context),
          const SizedBox(height: 20),
          switch (widget.currentStep) {
            AddItemWizardStep.category => _buildCategoryStep(context),
            AddItemWizardStep.basic => _buildBasicStep(context),
            AddItemWizardStep.location => _buildLocationStep(context),
            AddItemWizardStep.expiry => _buildExpiryStep(context),
          },
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    const labels = ['分类', '信息', '位置', '时效'];
    final index = widget.currentStep.index;
    final utility = AppColors.isUtilityStyle;

    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepDone = i ~/ 2 < index ||
              (widget.completedThroughStep != null &&
                  i ~/ 2 <= widget.completedThroughStep!.index);
          return Expanded(
            child: Container(
              height: 2,
              color: stepDone
                  ? (utility ? AppColors.gray400 : AppColors.primary)
                  : AppColors.homeDivider,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final active = stepIndex == index;
        final done = stepIndex < index ||
            (widget.completedThroughStep != null &&
                stepIndex <= widget.completedThroughStep!.index);

        Color circleBg;
        Color circleBorder;
        Color labelColor;
        Color numberColor;

        if (utility) {
          if (active) {
            circleBg = AppColors.white;
            circleBorder = AppColors.primary;
            numberColor = AppColors.primary;
            labelColor = AppColors.textPrimary;
          } else if (done) {
            circleBg = AppColors.gray100;
            circleBorder = AppColors.success;
            numberColor = AppColors.success;
            labelColor = AppColors.textSecondary;
          } else {
            circleBg = AppColors.gray100;
            circleBorder = AppColors.gray300;
            numberColor = AppColors.textHint;
            labelColor = AppColors.textHint;
          }
        } else {
          circleBg = active || done ? AppColors.primary : AppColors.gray200;
          circleBorder = active || done ? AppColors.primary : AppColors.gray200;
          numberColor = active || done ? Colors.white : AppColors.textHint;
          labelColor = active ? AppColors.primaryDark : AppColors.textHint;
        }

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
                border: Border.all(color: circleBorder, width: active ? 2 : 1),
              ),
              alignment: Alignment.center,
              child: Text(
                done && !active ? '✓' : '${stepIndex + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: numberColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[stepIndex],
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: labelColor,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Step1：扫码入口 + 分类（编辑模式仅改分类）
  Widget _buildCategoryStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEditMode ? '确认或修改分类' : '先选分类，或扫码快速录入',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        if (!widget.isEditMode) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              debugPrint('[AddItemWizard] INFO: 跳转扫码录入');
              context.go('/items/scan');
            },
            icon: const CandyIcon(Icons.qr_code_scanner_outlined),
            label: const Text('扫码录入'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
        SizedBox(height: widget.isEditMode ? 12 : 20),
        Text('选择分类 *', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ItemFormCategoryChips(
          selectedCategory: c.selectedCategory,
          onSelected: _onCategorySelected,
        ),
        if (c.selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '请选择分类后继续',
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
      ],
    );
  }

  /// Step2：名称 + 数量（编辑模式展示剩余量只读）
  Widget _buildBasicStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isEditMode && c.editCurrentQuantity != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '当前剩余 ${c.editCurrentQuantity!.toStringAsFixed(0)} ${c.unit}'
              ' · 修改购买信息不会自动改变剩余量',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (c.barcode != null && c.barcode!.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: CandyIcon(Icons.qr_code, size: 16, color: AppColors.textSecondary),
              label: Text('条码 ${c.barcode}', style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.infoBannerBackground,
              side: const BorderSide(color: AppColors.divider),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // 扫码/跳过 Step1 时在此补选分类
        if (c.selectedCategory == null) ...[
          Text('选择分类 *', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ItemFormCategoryChips(
            selectedCategory: c.selectedCategory,
            onSelected: _onCategorySelected,
          ),
          const SizedBox(height: 16),
        ] else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(
                '分类：${c.selectedCategory!.name}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const CandyIcon(Icons.edit_outlined, size: 16),
              onDeleted: () {
                c.selectedCategory = null;
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: c.nameController,
          decoration: const InputDecoration(
            labelText: '物品名称 *',
            hintText: '例如：全脂牛奶',
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? '请输入物品名称' : null,
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditMode ? '购买数量' : '数量',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    value: c.quantity,
                    min: 1,
                    max: 9999,
                    step: 1,
                    unit: c.displayUnit,
                    onChanged: (v) {
                      c.quantity = v;
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: c.displayUnit,
                decoration: const InputDecoration(labelText: '单位'),
                items: AppConstants.units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  c.setDisplayUnit(v);
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: c.brandController,
          decoration: const InputDecoration(
            labelText: '品牌（可选）',
            hintText: '例如：蒙牛',
          ),
          onChanged: (_) => widget.onChanged(),
        ),
        if (ShopRoleGuard.canEditPrice(
          ref.watch(spaceSkinProvider),
          ref.watch(familyRoleProvider),
        )) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: c.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: ref.watch(spaceSkinProvider).purchasePriceFieldLabel,
              hintText: '例如：12.50',
              prefixText: '¥ ',
            ),
            onChanged: (_) => widget.onChanged(),
          ),
          if (ref.watch(spaceSkinProvider).showSalePrice) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: c.salePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: ref.watch(spaceSkinProvider).salePriceFieldLabel,
                hintText: '例如：3.50',
                prefixText: '¥ ',
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ],
          if (ref.watch(spaceSkinProvider).showSupplier) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: c.supplierController,
              decoration: InputDecoration(
                labelText: ref.watch(spaceSkinProvider).supplierFieldLabel,
                hintText: '例如：某某批发',
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ],
        ],
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CandyIcon(Icons.shopping_bag_outlined, color: AppColors.textSecondary),
          title: Text(
            c.purchaseDate != null
                ? '购买日期：${AppDatePicker.formatDisplay(c.purchaseDate!)}'
                : '选择购买日期（可选）',
          ),
          trailing: const CandyIcon(Icons.chevron_right),
          onTap: () => _pickDate(context, '选择购买日期', c.purchaseDate, (d) {
            c.purchaseDate = d;
          }),
        ),
        if (c.purchaseDate != null)
          TextButton.icon(
            onPressed: () {
              c.purchaseDate = null;
              widget.onChanged();
            },
            icon: const CandyIcon(Icons.clear, size: 18),
            label: const Text('清除购买日期'),
          ),
        const SizedBox(height: 16),
        NotesMagicField(
          controller: c,
          onChanged: widget.onChanged,
        ),
        const SizedBox(height: 16),
        ItemImagePickerSection(
          compact: true,
          imagePaths: c.imagePaths,
          onChanged: (paths) {
            c.imagePaths = paths;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  /// Step3：存放位置
  Widget _buildLocationStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '物品放在哪里？',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '选好位置，家人更容易找到',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CandyIcon(Icons.place_outlined, color: AppColors.textSecondary),
          title: Text(
            c.selectedLocation?.fullPath.replaceAll('/', ' › ') ?? '点击选择位置',
            style: TextStyle(
              color: c.selectedLocation != null
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
          trailing: const CandyIcon(Icons.chevron_right),
          onTap: () {
            LocationPicker.show(
              context,
              selectedLocation: c.selectedLocation,
              onSelected: (loc) {
                c.selectedLocation = loc;
                widget.onChanged();
              },
            );
          },
        ),
        if (c.selectedLocation != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              c.selectedLocation = null;
              widget.onChanged();
            },
            icon: const CandyIcon(Icons.clear, size: 18),
            label: const Text('清除位置'),
          ),
        ],
        const SizedBox(height: 20),
        TextFormField(
          initialValue: c.containerName,
          decoration: const InputDecoration(
            labelText: '容器（可选）',
            hintText: '如：蓝色收纳箱、药品盒',
          ),
          onChanged: (v) {
            c.containerName = v.isEmpty ? null : v.trim();
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        ItemLocationPhotoSection(
          imagePaths: c.locationImagePaths,
          onChanged: (paths) {
            c.locationImagePaths = paths;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  /// Step4：过期与提醒（可跳过）
  Widget _buildExpiryStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置保质期（可跳过）',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '有过期日的物品会出现在临期提醒中',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CandyIcon(Icons.event_outlined, color: AppColors.textSecondary),
          title: Text(
            c.expiryDate != null
                ? '过期日：${AppDatePicker.formatDisplay(c.expiryDate!)}'
                : '选择过期日期',
          ),
          trailing: const CandyIcon(Icons.chevron_right),
          onTap: () => _pickDate(context, '选择过期日期', c.expiryDate, (d) {
            c.expiryDate = d;
          }),
        ),
        if (c.expiryDate != null)
          TextButton.icon(
            onPressed: () {
              c.expiryDate = null;
              widget.onChanged();
            },
            icon: const CandyIcon(Icons.clear, size: 18),
            label: const Text('清除过期日'),
          ),
        const SizedBox(height: 16),
        if (widget.isEditMode) ...[
          Text('安全库存', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          QuantityStepper(
            value: c.safetyStock,
            min: 0,
            max: 9999,
            step: 1,
            unit: c.unit,
            onChanged: (v) {
              c.safetyStock = v;
              widget.onChanged();
            },
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                '提前 ${c.expiryAlertDays} 天提醒',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            QuantityStepper(
              value: c.expiryAlertDays.toDouble(),
              min: 1,
              max: 30,
              step: 1,
              unit: '天',
              onChanged: (v) {
                c.expiryAlertDays = v.round();
                widget.onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('预计使用天数（可选）', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(
          '填写后自动估算日均消耗与预计用完日',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        QuantityStepper(
          value: (c.estimatedUseDays ?? 0).toDouble(),
          min: 0,
          max: 365,
          step: 1,
          unit: '天',
          onChanged: (v) {
            c.estimatedUseDays = v <= 0 ? null : v.round();
            debugPrint(
              '[AddItemWizard] INFO: 预计使用天数 ${c.estimatedUseDays}',
            );
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
