import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/item_image_storage.dart';
import 'item_image_tile.dart';

/// 物品表单图片区（添加/编辑共用）
/// [compact] 为 true 时首屏单行入口 + 底部 sheet 管理缩略图
class ItemImagePickerSection extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;
  final int maxImages;
  final bool compact;

  const ItemImagePickerSection({
    super.key,
    required this.imagePaths,
    required this.onChanged,
    this.maxImages = ItemImageStorage.maxImages,
    this.compact = false,
  });

  Future<void> _pickImage(BuildContext context) async {
    if (imagePaths.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多添加 $maxImages 张图片')),
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
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      final path = await ItemImageStorage.persistPickedImage(file);
      if (path == null) return;

      onChanged([...imagePaths, path]);
    } catch (e) {
      debugPrint('[ItemImagePicker] ERROR: 选择图片失败 $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    final path = imagePaths[index];
    final next = List<String>.from(imagePaths)..removeAt(index);
    onChanged(next);
    ItemImageStorage.deleteFile(path);
  }

  Future<void> _showManageSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '物品照片',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${imagePaths.length}/$maxImages',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (imagePaths.length < maxImages)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  await _pickImage(context);
                                  setSheetState(() {});
                                },
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray100,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CandyIcon(Icons.add_a_photo_outlined,
                                          color: AppColors.primary),
                                      const SizedBox(height: 4),
                                      Text('+ 添加',
                                          style: TextStyle(
                                              fontSize: 12, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ...imagePaths.asMap().entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                    child: ItemImageTile(
                                      source: e.value,
                                      width: 88,
                                      height: 88,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () {
                                        _removeImage(e.key);
                                        setSheetState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.danger,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const CandyIcon(Icons.close,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      final label = imagePaths.isEmpty
          ? '+ 添加照片'
          : '已 ${imagePaths.length} 张';
      return OutlinedButton.icon(
        onPressed: () {
          if (imagePaths.isEmpty) {
            _pickImage(context);
          } else {
            _showManageSheet(context);
          }
        },
        icon: const CandyIcon(Icons.add_a_photo_outlined, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '物品照片（可选）',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (imagePaths.length < maxImages)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _pickImage(context),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CandyIcon(Icons.add_a_photo_outlined, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text('+ 添加',
                              style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ...imagePaths.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: ItemImageTile(
                          source: e.value,
                          width: 88,
                          height: 88,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeImage(e.key),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: const CandyIcon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
