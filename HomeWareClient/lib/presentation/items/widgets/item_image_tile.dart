import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import '../../../core/config/app_env.dart';
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
  /// 网络/本地加载失败时回调（用于缩略图依次尝试备选图片）
  final VoidCallback? onError;

  const ItemImageTile({
    super.key,
    required this.source,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    Widget image;

    if (ItemImageRefs.isRemotePath(source) ||
        source.startsWith('http://') ||
        source.startsWith('https://')) {
      // 将相对路径（/uploads/...）转为完整 URL
      final url = AppEnv.resolveUploadUrl(source);
      image = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: (width is double && width != double.infinity) ? width.toInt() : 720,
        cacheHeight: (height is double && height != double.infinity) ? height.toInt() : null,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return child;
        },
        errorBuilder: (_, error, stack) {
          debugPrint('[ItemImageTile] ERROR: 加载失败 $url — $error');
          onError?.call();
          return _errorBox();
        },
      );
    } else {
      image = Image.file(
        File(source),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          onError?.call();
          return _errorBox();
        },
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
