import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/upload_service.dart';

/// 物品图片展示（本地 file / 网络 URL）
class ItemImageTile extends StatelessWidget {
  final String source;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ItemImageTile({
    super.key,
    required this.source,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    Widget image;

    if (ItemImageRefs.isRemotePath(source) ||
        source.startsWith('http://') ||
        source.startsWith('https://')) {
      image = Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _errorBox(),
      );
    } else {
      image = Image.file(
        File(source),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _errorBox(),
      );
    }

    return ClipRRect(borderRadius: radius, child: image);
  }

  Widget _errorBox() {
    return Container(
      width: width,
      height: height,
      color: AppColors.gray100,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.textHint),
    );
  }
}
