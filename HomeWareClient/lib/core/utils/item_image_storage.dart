import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../config/app_env.dart';
import '../services/upload_service.dart';

/// 物品图片本地存储（paths 序列化为 items.images JSON 数组）
class ItemImageStorage {
  static const _subdir = 'item_images';
  static const maxImages = 5;

  /// 客户端压缩参数（与服务端保持一致，减少上传流量和存储空间）
  static const int compressMaxWidth = 720;
  static const int compressQuality = 80;

  /// 将相册/相机文件压缩后复制到应用目录并返回本地路径
  static Future<String?> persistPickedImage(XFile file) async {
    try {
      final dir = await _imageDir();

      // 使用 flutter_image_compress 压缩图片
      // 缩放到最大宽度 720px，质量 80%，格式保持与原文件一致
      final compressed = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: compressMaxWidth,
        minHeight: compressMaxWidth, // 同时限制长宽，避免竖长图
        quality: compressQuality,
        format: CompressFormat.jpeg, // 统一转为 JPEG，兼容性最好
      );

      if (compressed == null) {
        debugPrint('[ItemImageStorage] WARN: 压缩失败，使用原图');
        // 压缩失败时降级：直接复制原文件
        final ext = p.extension(file.path);
        final safeExt = ext.isNotEmpty ? ext : '.jpg';
        final dest = File(
          p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}$safeExt'),
        );
        await File(file.path).copy(dest.path);
        debugPrint('[ItemImageStorage] INFO: 保存原图 ${dest.path}');
        return dest.path;
      }

      final dest = File(
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg'),
      );
      await dest.writeAsBytes(compressed);
      debugPrint(
        '[ItemImageStorage] INFO: 压缩保存 ${dest.path} '
        '(${compressed.length} bytes)',
      );
      return dest.path;
    } catch (e) {
      debugPrint('[ItemImageStorage] ERROR: 保存图片失败 $e');
      return null;
    }
  }

  static Future<Directory> _imageDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _subdir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 路径列表 → JSON 字符串写入数据库
  static String encodePaths(List<String> paths) {
    return jsonEncode(paths);
  }

  /// 数据库 JSON → 全部路径（含服务端 URL）
  static List<String> decodeAllPaths(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      return decoded.map((e) => e.toString()).where((p) => p.isNotEmpty).toList();
    } catch (e) {
      debugPrint('[ItemImageStorage] WARN: 解析图片 JSON 失败 $e');
      return [];
    }
  }

  /// 数据库 JSON → 本地路径列表（过滤已删除文件）
  static List<String> decodePaths(String? jsonStr) {
    return decodeAllPaths(jsonStr)
        .where((path) => ItemImageRefs.isLocalFile(path))
        .toList();
  }

  /// 用于展示的 URL：远程路径转完整 URL，本地转 file path
  static List<String> resolveDisplaySources(String? jsonStr) {
    return decodeAllPaths(jsonStr).map((path) {
      if (ItemImageRefs.isRemotePath(path)) {
        return AppEnv.resolveUploadUrl(path);
      }
      if (File(path).existsSync()) return path;
      return null;
    }).whereType<String>().toList();
  }

  /// 从服务端详情 images 字段解析 URL
  static List<String> urlsFromServerImages(List<dynamic>? images) {
    if (images == null || images.isEmpty) return [];
    final urls = <String>[];
    for (final raw in images) {
      if (raw is Map) {
        final url = raw['url']?.toString();
        if (url != null && url.isNotEmpty) {
          urls.add(AppEnv.resolveUploadUrl(url));
        }
      }
    }
    return urls;
  }

  /// 删除本地图片文件（可选，移除缩略图时调用）
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[ItemImageStorage] WARN: 删除图片失败 $path $e');
    }
  }
}
