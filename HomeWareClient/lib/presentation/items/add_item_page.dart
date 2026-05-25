import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/location_picker.dart';
import '../common/widgets/quantity_stepper.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();

  Category? _selectedCategory;
  Location? _selectedLocation;
  DateTime? _purchaseDate = DateTime.now(); // 默认今天
  DateTime? _productionDate;
  DateTime? _expiryDate;
  int? _shelfLifeDays;
  double _quantity = 1;
  String _unit = '件';
  String? _purchaseChannel;
  int _expiryAlertDays = 3;
  double _safetyStock = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    await _saveItem();
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _saveAndContinue() async {
    await _saveItem();
    if (mounted) {
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功！继续添加下一个')),
      );
    }
  }

  Future<void> _saveItem() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final categoryId = _selectedCategory?.id ?? 0;
    final locationId = _selectedLocation?.id;
    
    final itemId = await db.insertItem(
      ItemsCompanion.insert(
        name: _nameController.text,
        brand: _brandController.text.isEmpty ? const Value.absent() : Value(_brandController.text),
        categoryId: categoryId,
        locationId: locationId != null ? Value(locationId) : const Value.absent(),
        purchasePrice: _priceController.text.isEmpty ? const Value.absent() : Value(double.tryParse(_priceController.text)),
        purchaseQuantity: Value(_quantity.toInt()),
        currentQuantity: Value(_quantity),
        unit: Value(_unit),
        safetyStock: Value(_safetyStock),
        purchaseDate: _purchaseDate != null ? Value(_purchaseDate!) : const Value.absent(),
        purchaseChannel: _purchaseChannel != null ? Value(_purchaseChannel!) : const Value.absent(),
        productionDate: _productionDate != null ? Value(_productionDate!) : const Value.absent(),
        expiryDate: _expiryDate != null ? Value(_expiryDate!) : const Value.absent(),
        shelfLifeDays: _shelfLifeDays != null ? Value(_shelfLifeDays!) : const Value.absent(),
        expiryAlertDays: Value(_expiryAlertDays),
        notes: _notesController.text.isEmpty ? const Value.absent() : Value(_notesController.text),
      ),
    );

    await db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: itemId,
        type: 0,
        quantity: _quantity,
        remainingQuantity: _quantity,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _brandController.clear();
    _notesController.clear();
    _priceController.clear();
    setState(() {
      _quantity = 1;
      _safetyStock = 1;
      _purchaseDate = DateTime.now();
      _productionDate = null;
      _expiryDate = null;
      _shelfLifeDays = null;
    });
  }

  void _onShelfLifeChanged(String? shelfLifeKey) {
    if (shelfLifeKey == null) {
      setState(() {
        _shelfLifeDays = null;
        _expiryDate = null;
      });
      return;
    }

    final days = AppConstants.shelfLifeOptions[shelfLifeKey];
    setState(() {
      _shelfLifeDays = days;
      if (_productionDate != null && days != null) {
        _expiryDate = _productionDate!.add(Duration(days: days));
      }
    });
  }

  void _onProductionDateChanged(DateTime? date) {
    setState(() {
      _productionDate = date;
      if (_productionDate != null && _shelfLifeDays != null) {
        _expiryDate = _productionDate!.add(Duration(days: _shelfLifeDays!));
      }
    });
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加物品'),
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicSection(),
                      const SizedBox(height: 24),
                      _buildPurchaseSection(),
                      const SizedBox(height: 24),
                      _buildExpirySection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildAlertSection(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicSection() {
    return _Section(
      title: '基本信息',
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '物品名称 *',
            hintText: '请输入物品名称',
          ),
          validator: (value) => value?.isEmpty ?? true ? '请输入物品名称' : null,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => CategorySelector.show(
            context,
            selectedCategory: _selectedCategory,
            onSelected: (category) => setState(() => _selectedCategory = category),
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '分类 *',
                hintText: '请选择分类',
                suffixIcon: const Icon(Icons.chevron_right),
                prefixIcon: _selectedCategory?.icon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(_selectedCategory?.icon ?? '', style: const TextStyle(fontSize: 24)),
                      )
                    : null,
              ),
              controller: TextEditingController(text: _selectedCategory?.name),
              style: TextStyle(color: _selectedCategory != null ? null : AppColors.textSecondary),
              validator: (value) => _selectedCategory == null ? '请选择分类' : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _brandController,
          decoration: const InputDecoration(
            labelText: '品牌（可选）',
            hintText: '请输入品牌',
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection() {
    return _Section(
      title: '购买信息',
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('数量', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    value: _quantity,
                    min: 0.1,
                    max: 9999,
                    step: 1,
                    unit: _unit,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: '单位'),
                items: AppConstants.units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: (value) => setState(() => _unit = value ?? '件'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: '单价（可选）',
            hintText: '请输入单价',
            prefixText: '¥ ',
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context, _purchaseDate, (date) => setState(() => _purchaseDate = date)),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '购买日期（可选）',
                hintText: '请选择购买日期',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: _purchaseDate != null ? DateFormat('yyyy-MM-dd').format(_purchaseDate ?? DateTime.now()) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _purchaseChannel,
          decoration: const InputDecoration(
            labelText: '购买渠道（可选）',
            hintText: '请选择购买渠道',
          ),
          items: AppConstants.purchaseChannels.map((channel) => DropdownMenuItem(value: channel, child: Text(channel))).toList(),
          onChanged: (value) => setState(() => _purchaseChannel = value),
        ),
      ],
    );
  }

  Widget _buildExpirySection() {
    return _Section(
      title: '时效信息',
      children: [
        GestureDetector(
          onTap: () => _selectDate(context, _productionDate, _onProductionDateChanged),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '生产日期（可选）',
                hintText: '请选择生产日期',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: _productionDate != null ? DateFormat('yyyy-MM-dd').format(_productionDate ?? DateTime.now()) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _shelfLifeDays == null
              ? null
              : AppConstants.shelfLifeOptions.entries.firstWhere((e) => e.value == _shelfLifeDays).key,
          decoration: const InputDecoration(
            labelText: '保质期（可选）',
            hintText: '请选择保质期',
          ),
          items: AppConstants.shelfLifeOptions.keys
              .map((key) => DropdownMenuItem(value: key, child: Text(key)))
              .toList(),
          onChanged: _onShelfLifeChanged,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context, _expiryDate, (date) => setState(() => _expiryDate = date)),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '过期日期（可选）',
                hintText: '请选择过期日期',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: _expiryDate != null ? DateFormat('yyyy-MM-dd').format(_expiryDate ?? DateTime.now()) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _Section(
      title: '存放位置',
      children: [
        GestureDetector(
          onTap: () => LocationPicker.show(
            context,
            selectedLocation: _selectedLocation,
            onSelected: (location) => setState(() => _selectedLocation = location),
          ),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '存放位置（可选）',
                hintText: '请选择存放位置',
                suffixIcon: Icon(Icons.chevron_right),
              ),
              controller: TextEditingController(text: _selectedLocation?.fullPath),
              style: TextStyle(color: _selectedLocation != null ? null : AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection() {
    return _Section(
      title: '提醒设置',
      children: [
        DropdownButtonFormField<int>(
          value: _expiryAlertDays,
          decoration: const InputDecoration(
            labelText: '过期提前提醒',
            hintText: '选择提前天数',
          ),
          items: AppConstants.expiryAlertDays
              .map((days) => DropdownMenuItem(value: days, child: Text('$days 天')))
              .toList(),
          onChanged: (value) => setState(() => _expiryAlertDays = value ?? 3),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('库存预警数量', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            QuantityStepper(
              value: _safetyStock,
              min: 0,
              max: 9999,
              step: 1,
              onChanged: (value) => setState(() => _safetyStock = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _Section(
      title: '备注',
      children: [
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '添加备注信息（可选）',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: '保存入库',
                onPressed: _saveAndExit,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: '保存并继续',
                variant: ButtonVariant.secondary,
                onPressed: _saveAndContinue,
                isFullWidth: true,
              ),
            ),
          ],
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
