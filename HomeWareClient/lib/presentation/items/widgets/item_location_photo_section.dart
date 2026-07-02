import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/item_image_storage.dart';
import 'item_image_tile.dart';

/// 位置参考照片区（添加入库向导 / 表单共用）
class ItemLocationPhotoSection extends StatelessWidget {
  const ItemLocationPhotoSection({
    super.key,
    required this.imagePaths,
    required this.onChanged,
    this.maxImages = 4,
  });

  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;
  final int maxImages;

  Future<void> _pickImage(BuildContext context) async {
    if (imagePaths.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多添加 $maxImages 张位置参考照片')),
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
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
      if (path == null) return;

      debugPrint('[ItemLocationPhoto] INFO: 添加位置参考照片');
      onChanged([...imagePaths, path]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('位置照片已添加'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('[ItemLocationPhoto] ERROR: 位置照片获取失败 $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取图片失败')),
        );
      }
    }
  }

  void _removeAt(int index) {
    final path = imagePaths[index];
    final next = List<String>.from(imagePaths)..removeAt(index);
    onChanged(next);
    ItemImageStorage.deleteFile(path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '位置参考照片（可选）',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('添加'),
            ),
          ],
        ),
        if (imagePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ItemImageTile(
                        source: imagePaths[i],
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removeAt(i),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
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
}
