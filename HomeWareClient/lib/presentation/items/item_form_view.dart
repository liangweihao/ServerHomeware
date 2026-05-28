import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/location_picker.dart';
import '../common/widgets/quantity_stepper.dart';
import 'item_form_controller.dart';
import 'widgets/item_image_picker_section.dart';

/// 添加/编辑物品共享表单 UI
class ItemFormView extends StatelessWidget {
  final ItemFormController controller;
  final VoidCallback onChanged;
  final bool isEditMode;

  const ItemFormView({
    super.key,
    required this.controller,
    required this.onChanged,
    this.isEditMode = false,
  });

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    ValueChanged<DateTime?> onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemImagePickerSection(
            imagePaths: c.imagePaths,
            onChanged: (paths) {
              c.imagePaths = paths;
              onChanged();
            },
          ),
          const SizedBox(height: 24),
          _buildBasicSection(context),
          const SizedBox(height: 24),
          _buildPurchaseSection(context),
          const SizedBox(height: 24),
          _buildExpirySection(context),
          const SizedBox(height: 24),
          _buildLocationSection(context),
          const SizedBox(height: 24),
          _buildAlertSection(context),
          const SizedBox(height: 24),
          _buildNotesSection(context),
        ],
      ),
    );
  }

  Widget _buildBasicSection(BuildContext context) {
    final c = controller;
    return _Section(
      title: '基本信息',
      children: [
        TextFormField(
          controller: c.nameController,
          decoration: const InputDecoration(
            labelText: '物品名称 *',
            hintText: '请输入物品名称',
          ),
          validator: (value) => value?.isEmpty ?? true ? '请输入物品名称' : null,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => CategorySelector.show(
            context,
            selectedCategory: c.selectedCategory,
            onSelected: (category) {
              c.selectedCategory = category;
              onChanged();
            },
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '分类 *',
                hintText: '请选择分类',
                suffixIcon: const Icon(Icons.chevron_right),
                prefixIcon: c.selectedCategory?.icon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(
                          c.selectedCategory?.icon ?? '',
                          style: const TextStyle(fontSize: 24),
                        ),
                      )
                    : null,
              ),
              controller: TextEditingController(text: c.selectedCategory?.name),
              style: TextStyle(
                color: c.selectedCategory != null ? null : AppColors.textSecondary,
              ),
              validator: (_) => c.selectedCategory == null ? '请选择分类' : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: c.brandController,
          decoration: const InputDecoration(
            labelText: '品牌（可选）',
            hintText: '请输入品牌',
          ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(BuildContext context) {
    final c = controller;
    return _Section(
      title: '购买信息',
      children: [
        if (isEditMode && c.editCurrentQuantity != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '当前剩余：${c.editCurrentQuantity!.toStringAsFixed(0)} ${c.unit}（编辑购买信息不会自动改剩余量）',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditMode ? '购买数量' : '数量',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    value: c.quantity,
                    min: 0.1,
                    max: 9999,
                    step: 1,
                    unit: c.unit,
                    onChanged: (value) {
                      c.quantity = value;
                      onChanged();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: c.unit,
                decoration: const InputDecoration(labelText: '单位'),
                items: AppConstants.units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  c.unit = value ?? '件';
                  onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: c.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: '单价（可选）',
            hintText: '请输入单价',
            prefixText: '¥ ',
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(
            context,
            c.purchaseDate,
            (date) => c.purchaseDate = date,
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '购买日期（可选）',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.purchaseDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.purchaseDate!)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: c.purchaseChannel,
          decoration: const InputDecoration(labelText: '购买渠道（可选）'),
          items: AppConstants.purchaseChannels
              .map((ch) => DropdownMenuItem(value: ch, child: Text(ch)))
              .toList(),
          onChanged: (value) {
            c.purchaseChannel = value;
            onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildExpirySection(BuildContext context) {
    final c = controller;
    return _Section(
      title: '时效信息',
      children: [
        GestureDetector(
          onTap: () => _selectDate(
            context,
            c.productionDate,
            (date) => c.onProductionDateChanged(date),
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '生产日期（可选）',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.productionDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.productionDate!)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: c.shelfLifeDays == null
              ? null
              : AppConstants.shelfLifeOptions.entries
                  .firstWhere((e) => e.value == c.shelfLifeDays)
                  .key,
          decoration: const InputDecoration(labelText: '保质期（可选）'),
          items: AppConstants.shelfLifeOptions.keys
              .map((key) => DropdownMenuItem(value: key, child: Text(key)))
              .toList(),
          onChanged: (key) {
            c.onShelfLifeChanged(key);
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(
            context,
            c.expiryDate,
            (date) => c.expiryDate = date,
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '过期日期（可选）',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.expiryDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.expiryDate!)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final c = controller;
    return _Section(
      title: '存放位置',
      children: [
        GestureDetector(
          onTap: () => LocationPicker.show(
            context,
            selectedLocation: c.selectedLocation,
            onSelected: (location) {
              c.selectedLocation = location;
              onChanged();
            },
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '存放位置（可选）',
                suffixIcon: Icon(Icons.chevron_right),
              ),
              controller: TextEditingController(text: c.selectedLocation?.fullPath),
              style: TextStyle(
                color: c.selectedLocation != null ? null : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection(BuildContext context) {
    final c = controller;
    return _Section(
      title: '提醒设置',
      children: [
        DropdownButtonFormField<int>(
          value: c.expiryAlertDays,
          decoration: const InputDecoration(labelText: '过期提前提醒'),
          items: AppConstants.expiryAlertDays
              .map((d) => DropdownMenuItem(value: d, child: Text('$d 天')))
              .toList(),
          onChanged: (value) {
            c.expiryAlertDays = value ?? 3;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('库存预警数量', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            QuantityStepper(
              value: c.safetyStock,
              min: 0,
              max: 9999,
              step: 1,
              onChanged: (value) {
                c.safetyStock = value;
                onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return _Section(
      title: '备注',
      children: [
        TextFormField(
          controller: controller.notesController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: '添加备注信息（可选）'),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
