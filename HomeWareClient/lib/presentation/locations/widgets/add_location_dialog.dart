import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../common/widgets/app_button.dart';

class AddLocationDialog extends StatefulWidget {
  final String? parentName;
  final ValueChanged<(String, String)> onConfirm;

  const AddLocationDialog({
    super.key,
    this.parentName,
    required this.onConfirm,
  });

  static void show(
    BuildContext context, {
    String? parentName,
    required ValueChanged<(String, String)> onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddLocationDialog(
        parentName: parentName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  final _nameController = TextEditingController();
  String _selectedIcon = '🏠';

  final List<String> _icons = [
    '🏠', '🍳', '🛁', '🛋️', '🛏️', '☀️', '📦', '🗄️',
    '💊', '📺', '👕', '🍎', '🧹', '🧴', '🖥️', '📚',
    '🪞', '🚿', '🚽', '❄️', '🔥', '🌿', '💡', '🎮',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入位置名称')),
      );
      return;
    }
    widget.onConfirm((name, _selectedIcon));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parentName != null ? '添加子位置' : '添加空间'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '位置名称',
                hintText: '请输入位置名称',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Text(
              '选择图标',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.primary) : null,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        AppButton(
          label: '确认',
          onPressed: _confirm,
          variant: ButtonVariant.primary,
        ),
      ],
    );
  }
}
