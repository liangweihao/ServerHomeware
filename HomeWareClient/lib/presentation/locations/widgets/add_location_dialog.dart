import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/item_image_storage.dart';
import '../../common/widgets/app_button.dart';

class AddLocationDialog extends StatefulWidget {
  final String? parentName;
  final void Function(String name, String icon, String? imagePath) onConfirm;

  const AddLocationDialog({
    super.key,
    this.parentName,
    required this.onConfirm,
  });

  static void show(
    BuildContext context, {
    String? parentName,
    required void Function(String name, String icon, String? imagePath) onConfirm,
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
  String? _locationImagePath; // 位置说明照片本地路径

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

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (file == null) return;
      final path = await ItemImageStorage.persistPickedImage(file);
      if (path != null) {
        setState(() => _locationImagePath = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('拍照失败')),
        );
      }
    }
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入位置名称')),
      );
      return;
    }
    widget.onConfirm(name, _selectedIcon, _locationImagePath);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parentName != null ? '添加子位置' : '添加位置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '位置名称',
                hintText: '如：衣柜上层',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // 拍照说明位置
            Row(
              children: [
                Expanded(
                  child: Text(
                    '位置照片（方便日后找东西）',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildPhotoButton(context),
              ],
            ),
            if (_locationImagePath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_locationImagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
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

  Widget _buildPhotoButton(BuildContext context) {
    return Material(
      color: AppColors.gray100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _takePhoto,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            _locationImagePath != null ? Icons.check_circle : Icons.add_a_photo_outlined,
            color: _locationImagePath != null ? AppColors.success : AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
