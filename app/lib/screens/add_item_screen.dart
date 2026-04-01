import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/providers/auth_provider.dart';

/// 添加物品屏幕类
class AddItemScreen extends StatefulWidget {
  /// 构造函数
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

/// 添加物品屏幕状态类
class _AddItemScreenState extends State<AddItemScreen> {
  /// 表单键，用于表单验证
  final _formKey = GlobalKey<FormState>();
  /// 物品名称输入控制器
  final _nameController = TextEditingController();
  /// 物品描述输入控制器
  final _descriptionController = TextEditingController();
  /// 物品数量输入控制器
  final _quantityController = TextEditingController();
  /// 物品单位输入控制器
  final _unitController = TextEditingController();
  /// 物品价格输入控制器
  final _priceController = TextEditingController();
  /// 过期日期
  DateTime? _expiryDate;
  /// 购买日期
  DateTime? _purchaseDate;
  /// 选中的分类ID
  int? _selectedCategoryId;
  /// 选中的位置ID
  int? _selectedLocationId;

  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// 保存物品方法
  /// 验证表单并调用ItemProvider的addItem方法添加物品
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final itemData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'location_id': _selectedLocationId,
        'quantity': int.parse(_quantityController.text),
        'unit': _unitController.text.trim(),
        'expiry_date': _expiryDate?.toIso8601String(),
        'purchase_date': _purchaseDate?.toIso8601String(),
        'price': _priceController.text.isNotEmpty ? double.parse(_priceController.text) : null,
        'family_id': familyProvider.selectedFamily!.id,
        'created_by': authProvider.user?.id,
      };

      final success = await itemProvider.addItem(itemData);
      if (success) {
        // 保存成功，返回上一页
        Navigator.pop(context);
      } else {
        // 保存失败，显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(itemProvider.errorMessage ?? '添加物品失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加物品'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 物品名称输入框
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '物品名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入物品名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 物品描述输入框
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 分类选择下拉框
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                hint: const Text('选择分类'),
                items: itemProvider.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择分类';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 位置选择下拉框
              DropdownButtonFormField<int>(
                value: _selectedLocationId,
                hint: const Text('选择位置'),
                items: itemProvider.locations.map((location) {
                  return DropdownMenuItem<int>(
                    value: location.id,
                    child: Text(location.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择位置';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 数量和单位输入框
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '数量',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入数量';
                        }
                        if (int.tryParse(value) == null) {
                          return '请输入有效的数量';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: '单位',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入单位';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 价格输入框
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '价格',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 购买日期选择按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _purchaseDate = pickedDate;
                          });
                        }
                      },
                      child: Text(_purchaseDate != null
                          ? '购买日期: ${_purchaseDate!.toString().split(' ')[0]}'
                          : '选择购买日期'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 过期日期选择按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _expiryDate = pickedDate;
                          });
                        }
                      },
                      child: Text(_expiryDate != null
                          ? '过期日期: ${_expiryDate!.toString().split(' ')[0]}'
                          : '选择过期日期'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 保存按钮
              ElevatedButton(
                onPressed: itemProvider.isLoading ? null : _saveItem,
                child: itemProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
