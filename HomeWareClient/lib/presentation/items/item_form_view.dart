import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/database_provider.dart';
import '../../core/auth/shop_role_guard.dart';
import '../../core/providers/family_role_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/location_picker.dart';
import '../common/widgets/app_date_picker.dart';
import '../common/widgets/quantity_stepper.dart';
import 'category_form_policy.dart';
import 'item_form_controller.dart';
import 'widgets/item_form_category_chips.dart';
import 'widgets/item_image_picker_section.dart';
import 'widgets/item_image_tile.dart';
import 'widgets/notes_magic_field.dart';

/// 添加/编辑物品共享表单 UI（Phase C：首屏 + 手风琴折叠）
class ItemFormView extends ConsumerStatefulWidget {
  final ItemFormController controller;
  final VoidCallback onChanged;
  final bool isEditMode;

  const ItemFormView({
    super.key,
    required this.controller,
    required this.onChanged,
    this.isEditMode = false,
  });

  @override
  ConsumerState<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends ConsumerState<ItemFormView> {
  ItemFormSection? _expandedSection;
  ItemFormSection? _primarySection;
  List<ItemFormSection>? _sectionOrder;

  ItemFormController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSectionStateFromCategory());
  }

  @override
  void didUpdateWidget(ItemFormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (c.selectedCategory == null && oldWidget.controller.selectedCategory != null) {
      setState(() {
        _expandedSection = null;
        _primarySection = null;
        _sectionOrder = null;
      });
    }
  }

  Future<void> _syncSectionStateFromCategory() async {
    final category = c.selectedCategory;
    if (category == null) return;
    final db = ref.read(databaseProvider);
    final top = await CategoryFormPolicy.resolveTopLevel(category, db);
    if (top == null || !mounted) return;
    setState(() {
      _sectionOrder = CategoryFormPolicy.sectionOrder(category, top);
      _primarySection = CategoryFormPolicy.primarySection(category, top);
    });
  }

  Future<void> _onCategorySelected(Category category) async {
    final db = ref.read(databaseProvider);
    final top = await CategoryFormPolicy.resolveTopLevel(category, db);
    if (top == null) return;

    CategoryFormPolicy.applyAlertDefaults(c, category, top);
    c.selectedCategory = category;

    final primary = CategoryFormPolicy.primarySection(category, top);
    debugPrint('[ItemFormView] INFO: 分类切换 ${category.name} → 主折叠 $primary');

    setState(() {
      _sectionOrder = CategoryFormPolicy.sectionOrder(category, top);
      _primarySection = primary;
      _expandedSection = primary;
    });
    widget.onChanged();
  }

  void _toggleSection(ItemFormSection section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Color _categoryAccentColor() {
    final hex = c.selectedCategory?.color?.replaceFirst('#', '') ?? '';
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return AppColors.primary;
  }

  Future<void> _selectDate(
    BuildContext context,
    String title,
    DateTime? initialDate,
    ValueChanged<DateTime?> onSelected,
  ) async {
    final picked = await AppDatePicker.show(
      context,
      title: title,
      initialDate: initialDate,
    );
    if (picked != null) {
      onSelected(picked);
      widget.onChanged();
    }
  }

  List<ItemFormSection> get _orderedSections {
    return _sectionOrder ??
        const [
          ItemFormSection.purchase,
          ItemFormSection.locationDetail,
          ItemFormSection.expiry,
          ItemFormSection.stock,
          ItemFormSection.more,
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFirstScreen(context),
          const SizedBox(height: 20),
          ..._orderedSections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAccordion(context, section),
              )),
        ],
      ),
    );
  }

  /// 首屏：名称、分类、数量/单位、位置、照片
  Widget _buildFirstScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: c.nameController,
          decoration: const InputDecoration(
            labelText: '物品名称 *',
            hintText: '请输入物品名称',
          ),
          validator: (value) => value?.isEmpty ?? true ? '请输入物品名称' : null,
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 16),
        Text(
          '分类 *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ItemFormCategoryChips(
          selectedCategory: c.selectedCategory,
          isEditMode: widget.isEditMode,
          onSelected: _onCategorySelected,
        ),
        if (c.selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '请选择分类',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                  ),
            ),
          ),
        const SizedBox(height: 16),
        _buildQuantityRow(context),
        if (c.usesPackageLikeUnit) ...[
          const SizedBox(height: 12),
          _buildPackageInlineRow(context),
        ],
        const SizedBox(height: 16),
        _buildLocationRow(context),
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

  Widget _buildQuantityRow(BuildContext context) {
    return Row(
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
                onChanged: (value) {
                  c.quantity = value;
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
            onChanged: (value) {
              if (value == null) return;
              c.setDisplayUnit(value);
              widget.onChanged();
            },
          ),
        ),
      ],
    );
  }

  /// 包装级单位选中时：每 X 含 n 个
  Widget _buildPackageInlineRow(BuildContext context) {
    final displayUnit = c.displayUnit;
    final innerUnits = AppConstants.units.where((u) => u != displayUnit).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.infoBannerBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.homeDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('每$displayUnit含', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 8),
              Expanded(
                child: QuantityStepper(
                  value: c.packageQuantity.toDouble(),
                  min: 1,
                  max: 9999,
                  step: 1,
                  unit: c.unit,
                  onChanged: (value) {
                    c.packageQuantity = value.toInt().clamp(1, 9999);
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<String>(
                  value: innerUnits.contains(c.unit) ? c.unit : innerUnits.first,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: innerUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      c.unit = value;
                      widget.onChanged();
                    }
                  },
                ),
              ),
            ],
          ),
          if (c.packageQuantity > 0) ...[
            const SizedBox(height: 6),
            Text(
              '共 ${(c.quantity * c.packageQuantity).toStringAsFixed(0)} ${c.unit}'
              '（${c.quantity.toStringAsFixed(0)} $displayUnit × ${c.packageQuantity} ${c.unit}）',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return InkWell(
      onTap: () => LocationPicker.show(
        context,
        selectedLocation: c.selectedLocation,
        onSelected: (location) {
          c.selectedLocation = location;
          widget.onChanged();
        },
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '放在哪？',
          suffixIcon: CandyIcon(Icons.chevron_right),
        ),
        child: Text(
          c.selectedLocation?.fullPath ?? '未选择',
          style: TextStyle(
            color: c.selectedLocation != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAccordion(BuildContext context, ItemFormSection section) {
    final expanded = _expandedSection == section;
    final isPrimary = _primarySection == section && c.selectedCategory != null;
    final accent = isPrimary ? _categoryAccentColor() : AppColors.border;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection(section),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isPrimary ? accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  CandyIcon(
                    expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CategoryFormPolicy.sectionTitle(section),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (!expanded)
                          Text(
                            CategoryFormPolicy.sectionSummary(section, c),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildSectionContent(context, section),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, ItemFormSection section) {
    switch (section) {
      case ItemFormSection.expiry:
        return _buildExpiryContent(context);
      case ItemFormSection.stock:
        return _buildStockContent(context);
      case ItemFormSection.purchase:
        return _buildPurchaseContent(context);
      case ItemFormSection.locationDetail:
        return _buildLocationDetailContent(context);
      case ItemFormSection.more:
        return _buildMoreContent(context);
    }
  }

  Widget _buildExpiryContent(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectDate(
            context,
            '选择生产日期',
            c.productionDate,
            (date) => c.onProductionDateChanged(date),
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '生产日期（可选）',
                suffixIcon: CandyIcon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.productionDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.productionDate!)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
            widget.onChanged();
          },
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(
            context,
            '选择过期日期',
            c.expiryDate,
            (date) => c.expiryDate = date,
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '过期日期（可选）',
                suffixIcon: CandyIcon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.expiryDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.expiryDate!)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: c.expiryAlertDays,
          decoration: const InputDecoration(labelText: '过期提前提醒'),
          items: AppConstants.expiryAlertDays
              .map((d) => DropdownMenuItem(value: d, child: Text('$d 天')))
              .toList(),
          onChanged: (value) {
            c.expiryAlertDays = value ?? 3;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildStockContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('库存预警数量', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        QuantityStepper(
          value: c.safetyStock,
          min: 0,
          max: 9999,
          step: 1,
          unit: c.unit,
          onChanged: (value) {
            c.safetyStock = value;
            widget.onChanged();
          },
        ),
        if (c.packageUnit != null &&
            c.packageQuantity > 1 &&
            c.safetyStock > 0 &&
            c.safetyStock >= c.packageQuantity) ...[
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
    );
  }

  Widget _buildPurchaseContent(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    final role = ref.watch(familyRoleProvider);
    final canEditPrice = ShopRoleGuard.canEditPrice(skin, role);

    return Column(
      children: [
        if (widget.isEditMode && c.editCurrentQuantity != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '当前剩余：${c.editCurrentQuantity!.toStringAsFixed(0)} ${c.unit}'
              '（编辑购买信息不会自动改剩余量）',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        TextFormField(
          controller: c.brandController,
          decoration: const InputDecoration(
            labelText: '品牌（可选）',
            hintText: '请输入品牌',
          ),
          onChanged: (_) => widget.onChanged(),
        ),
        if (canEditPrice) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: c.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: skin.purchasePriceFieldLabel,
              hintText: '请输入单价',
              prefixText: '¥ ',
            ),
            onChanged: (_) => widget.onChanged(),
          ),
        ],
        if (skin.showSalePrice && canEditPrice) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: c.salePriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: skin.salePriceFieldLabel,
              hintText: '例如：3.50',
              prefixText: '¥ ',
            ),
            onChanged: (_) => widget.onChanged(),
          ),
        ],
        if (skin.showSupplier && canEditPrice) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: c.supplierController,
            decoration: InputDecoration(
              labelText: skin.supplierFieldLabel,
              hintText: '例如：某某批发',
            ),
            onChanged: (_) => widget.onChanged(),
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(
            context,
            '选择购买日期',
            c.purchaseDate,
            (date) => c.purchaseDate = date,
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '购买日期（可选）',
                suffixIcon: CandyIcon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: c.purchaseDate != null
                    ? DateFormat('yyyy-MM-dd').format(c.purchaseDate!)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: c.purchaseChannel,
          decoration: const InputDecoration(labelText: '购买渠道（可选）'),
          items: AppConstants.purchaseChannels
              .map((ch) => DropdownMenuItem(value: ch, child: Text(ch)))
              .toList(),
          onChanged: (value) {
            c.purchaseChannel = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildLocationDetailContent(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: c.containerName,
          decoration: const InputDecoration(
            labelText: '容器（可选）',
            hintText: '如：蓝色收纳箱、药品盒、工具箱',
          ),
          onChanged: (v) {
            c.containerName = v.isEmpty ? null : v.trim();
            widget.onChanged();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '位置参考照片',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            _LocationPhotoButton(
              onPhotoTaken: (path) {
                c.locationImagePaths = [...c.locationImagePaths, path];
                widget.onChanged();
              },
            ),
          ],
        ),
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
                          c.locationImagePaths = List.from(c.locationImagePaths)
                            ..removeAt(i);
                          widget.onChanged();
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const CandyIcon(Icons.close, size: 14, color: Colors.white),
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

  Widget _buildMoreContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotesMagicField(
          controller: c,
          onChanged: widget.onChanged,
          maxLines: 4,
          labelText: '备注（可选）',
          hintText: '添加备注信息（可选）',
        ),
        if (!c.usesPackageLikeUnit) ...[
          const SizedBox(height: 16),
          Text(
            '按包装录入（可选）',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
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
                  onChanged: (value) {
                    c.packageUnit = value;
                    if (value == null) c.packageQuantity = 1;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (c.packageUnit != null)
                Expanded(
                  child: QuantityStepper(
                    value: c.packageQuantity.toDouble(),
                    min: 1,
                    max: 9999,
                    step: 1,
                    unit: c.unit,
                    onChanged: (value) {
                      c.packageQuantity = value.toInt();
                      widget.onChanged();
                    },
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 位置参考照片：拍照或相册
class _LocationPhotoButton extends StatelessWidget {
  final ValueChanged<String> onPhotoTaken;

  const _LocationPhotoButton({required this.onPhotoTaken});

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CandyIcon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const CandyIcon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
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
      debugPrint('[ItemFormView] ERROR: 位置照片获取失败 $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取图片失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _pickImage(context),
      icon: const CandyIcon(Icons.add_a_photo_outlined, size: 18),
      label: const Text('添加'),
    );
  }
}
