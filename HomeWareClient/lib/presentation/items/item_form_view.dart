import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/location_picker.dart';
import '../common/widgets/quantity_stepper.dart';
import 'item_form_controller.dart';
import 'widgets/item_image_picker_section.dart';
import 'widgets/item_image_tile.dart';

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
        // 包装单位（可选）：如 3盒 × 10片
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: c.packageQuantity > 1 ? c.packageQuantity.toString() : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '一包多少个（可选）',
                  hintText: '如 10',
                ),
                onChanged: (v) {
                  c.packageQuantity = int.tryParse(v) ?? 1;
                  if (c.packageQuantity < 1) c.packageQuantity = 1;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: c.packageUnit,
                decoration: const InputDecoration(labelText: '包装单位'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('无')),
                  DropdownMenuItem(value: '盒', child: Text('盒')),
                  DropdownMenuItem(value: '箱', child: Text('箱')),
                  DropdownMenuItem(value: '提', child: Text('提')),
                  DropdownMenuItem(value: '板', child: Text('板')),
                  DropdownMenuItem(value: '袋', child: Text('袋')),
                  DropdownMenuItem(value: '包', child: Text('包')),
                  DropdownMenuItem(value: '瓶', child: Text('瓶')),
                ],
                onChanged: (v) {
                  c.packageUnit = v;
                  onChanged();
                },
              ),
            ),
          ],
        ),
        // 总量提示
        if (c.packageUnit != null && c.packageQuantity > 1) ...[
          const SizedBox(height: 8),
          Text(
            '共 ${(c.quantity * c.packageQuantity).toStringAsFixed(0)} ${c.unit}'
                '（${c.quantity.toStringAsFixed(0)} ${c.packageUnit} × ${c.packageQuantity} ${c.unit}）',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
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
        // 容器（收纳箱/药盒等）
        TextFormField(
          initialValue: c.containerName,
          decoration: const InputDecoration(
            labelText: '容器（可选）',
            hintText: '如：蓝色收纳箱、药品盒、工具箱',
          ),
          onChanged: (v) {
            c.containerName = v.isEmpty ? null : v.trim();
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 位置选择
            Expanded(
              child: GestureDetector(
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
            ),
            const SizedBox(width: 12),
            // 拍照记录位置
            _LocationPhotoButton(
              onPhotoTaken: (path) {
                c.locationImagePaths = [...c.locationImagePaths, path];
                onChanged();
              },
            ),
          ],
        ),
        // 位置照片预览
        if (c.locationImagePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: c.locationImagePaths.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ItemImageTile(
                        source: c.locationImagePaths[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          c.locationImagePaths = List.from(c.locationImagePaths)..removeAt(i);
                          onChanged();
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            // 库存预警：显示基础单位 + 包装换算
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '库存预警数量',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                QuantityStepper(
                  value: c.safetyStock,
                  min: 0,
                  max: 9999,
                  step: 1,
                  unit: c.unit,
                  onChanged: (value) {
                    c.safetyStock = value;
                    onChanged();
                  },
                ),
                // 包装换算提示
                if (c.packageUnit != null && c.packageQuantity > 1 &&
                    c.safetyStock > 0 && c.safetyStock >= c.packageQuantity) ...[
                  const SizedBox(height: 4),
                  Text(
                    '≈ ${(c.safetyStock / c.packageQuantity).toStringAsFixed(1)} ${c.packageUnit}'
                    '（${c.packageQuantity} ${c.unit}/${c.packageUnit}）',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
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

/// 位置拍照按钮 — 拍照记录物品存放位置，方便日后查找
class _LocationPhotoButton extends StatelessWidget {
  final ValueChanged<String> onPhotoTaken;

  const _LocationPhotoButton({required this.onPhotoTaken});

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (file == null) return;

      final path = await ItemImageStorage.persistPickedImage(file);
      if (path != null) {
        onPhotoTaken(path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('位置照片已添加'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('拍照失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '拍照记录存放位置',
      child: Material(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _takePhoto(context),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
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
