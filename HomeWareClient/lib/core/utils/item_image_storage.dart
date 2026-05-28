import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
/// 物品图片本地存储（paths 序列化为 items.images JSON 数组）
class ItemImageStorage {
  static const _subdir = 'item_images';
  static const maxImages = 5;

  /// 将相册/相机文件复制到应用目录并返回本地路径
  static Future<String?> persistPickedImage(XFile file) async {
    try {
      final dir = await _imageDir();
      final ext = p.extension(file.path);
      final safeExt = ext.isNotEmpty ? ext : '.jpg';
      final dest = File(
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}$safeExt'),
      );
      await File(file.path).copy(dest.path);
      debugPrint('[ItemImageStorage] INFO: 保存图片 ${dest.path}');
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

  /// 数据库 JSON → 本地路径列表（过滤已删除文件）
  static List<String> decodePaths(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      return decoded
          .map((e) => e.toString())
          .where((path) => path.isNotEmpty && File(path).existsSync())
          .toList();
    } catch (e) {
      debugPrint('[ItemImageStorage] WARN: 解析图片 JSON 失败 $e');
      return [];
    }
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
