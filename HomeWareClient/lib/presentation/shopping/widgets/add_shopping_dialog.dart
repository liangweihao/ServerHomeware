import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/shopping_provider.dart';
import '../../common/widgets/app_button.dart';

class AddShoppingDialog extends StatefulWidget {
  final Function(String name, double quantity, String unit, double? estimatedPrice) onConfirm;

  const AddShoppingDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String name, double quantity, String unit, double? estimatedPrice) onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddShoppingDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<AddShoppingDialog> createState() => _AddShoppingDialogState();
}

class _AddShoppingDialogState extends State<AddShoppingDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _unit = '件';

  final List<String> _units = ['件', '个', '瓶', '盒', '袋', '箱', 'kg', 'g', 'L', 'ml'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入物品名称')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 1;
    final price = _priceController.text.isNotEmpty
        ? double.tryParse(_priceController.text)
        : null;

    widget.onConfirm(name, quantity, _unit, price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加购物项',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // 名称输入
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '物品名称',
                hintText: '请输入物品名称',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // 数量和单位
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: '数量',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(
                      labelText: '单位',
                    ),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _unit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 预估价格
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '预估价格（可选）',
                hintText: '¥0.00',
                prefixText: '¥',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 24),

            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: '取消',
                  variant: ButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: '添加',
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
