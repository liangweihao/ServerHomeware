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

  static const locPrefix = '__loc__:';
  static const _locPrefix = '__loc__:';

  /// 路径列表 → JSON 字符串（简单编码，不处理前缀）
  static String encodePaths(List<String> paths) {
    return jsonEncode(paths);
  }

  /// 路径列表 → JSON 字符串写入数据库（物品图片 + 位置照片）
  static String encodeAllImages({
    required List<String> itemPaths,
    required List<String> locationPaths,
  }) {
    final all = <String>[
      ...itemPaths,
      for (final p in locationPaths) '$_locPrefix$p',
    ];
    return jsonEncode(all);
  }

  /// 数据库 JSON → 全部原始路径
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

  /// 数据库 JSON → 物品图片路径（不含位置照片）
  static List<String> decodeItemImages(String? jsonStr) {
    return decodeAllPaths(jsonStr)
        .where((p) => !p.startsWith(_locPrefix))
        .toList();
  }

  /// 数据库 JSON → 位置照片路径（去掉 __loc__: 前缀）
  static List<String> decodeLocationImages(String? jsonStr) {
    return decodeAllPaths(jsonStr)
        .where((p) => p.startsWith(_locPrefix))
        .map((p) => p.substring(_locPrefix.length))
        .toList();
  }

  /// 用于展示的 URL：本地文件优先，远程 URL 按较新优先（列表末尾较新）
  /// 只返回物品图片，不含位置照片；自动过滤历史失效批次
  static List<String> resolveDisplaySources(String? jsonStr) {
    final paths = decodeItemImages(jsonStr);
    final newestDate = _newestUploadDateFromPaths(paths);
    final filtered = newestDate == null
        ? paths
        : paths.where((p) => _extractUploadDate(p) == newestDate).toList();

    final local = <String>[];
    final remote = <String>[];

    for (final path in filtered) {
      if (ItemImageRefs.isRemotePath(path)) {
        remote.add(AppEnv.resolveUploadUrl(path));
      } else if (File(path).existsSync()) {
        local.add(path);
      }
    }

    return [...local, ...remote.reversed];
  }

  static String? _newestUploadDateFromPaths(List<String> paths) {
    String? newest;
    for (final path in paths) {
      final d = _extractUploadDate(path);
      if (d != null && (newest == null || d.compareTo(newest) > 0)) {
        newest = d;
      }
    }
    return newest;
  }

  /// 位置照片 → 可展示的 URL 列表（过滤历史失效批次）
  static List<String> resolveLocationDisplaySources(String? jsonStr) {
    final paths = decodeLocationImages(jsonStr);
    final newestDate = _newestUploadDateFromPaths(paths);
    final filtered = newestDate == null
        ? paths
        : paths.where((p) => _extractUploadDate(p) == newestDate).toList();

    return filtered.map((path) {
      if (ItemImageRefs.isRemotePath(path)) {
        return AppEnv.resolveUploadUrl(path);
      }
      if (File(path).existsSync()) return path;
      return null;
    }).whereType<String>().toList();
  }

  /// 从服务端详情 images 字段解析 URL（物品图 + 位置图分离，过滤历史失效批次）
  static ServerImageParseResult parseServerImages(List<dynamic>? images) {
    if (images == null || images.isEmpty) {
      return const ServerImageParseResult([], [], []);
    }

    final entries = <Map<String, dynamic>>[];
    for (final raw in images) {
      if (raw is Map) {
        entries.add(Map<String, dynamic>.from(raw));
      }
    }
    entries.sort((a, b) {
      final idA = a['id'] is int ? a['id'] as int : int.tryParse('${a['id']}') ?? 0;
      final idB = b['id'] is int ? b['id'] as int : int.tryParse('${b['id']}') ?? 0;
      return idB.compareTo(idA);
    });

    // 只保留最新日期批次（文件名中 YYYYMMDD），规避 DB 孤儿记录指向已删除文件
    final newestDate = _newestUploadDate(entries);
    final filtered = newestDate == null
        ? entries
        : entries.where((e) {
            final url = e['url']?.toString() ?? '';
            return url.contains('/$newestDate\_');
          }).toList();

    if (filtered.length < entries.length) {
      debugPrint('[ItemImageStorage] INFO: 过滤历史图片批次 '
          '${entries.length} → ${filtered.length}（保留 $newestDate）');
    }

    final itemUrls = <String>[];
    final locationUrls = <String>[];
    final storagePaths = <String>[];

    for (final entry in filtered) {
      final url = entry['url']?.toString();
      if (url == null || url.isEmpty) continue;
      storagePaths.add(url);

      if (url.startsWith(_locPrefix)) {
        final stripped = url.substring(_locPrefix.length);
        locationUrls.add(AppEnv.resolveUploadUrl(stripped));
      } else {
        itemUrls.add(AppEnv.resolveUploadUrl(url));
      }
    }

    return ServerImageParseResult(itemUrls, locationUrls, storagePaths);
  }

  /// 从 URL 中提取上传日期前缀（如 20260622）
  static String? extractUploadDate(String url) {
    final clean = url.startsWith(_locPrefix) ? url.substring(_locPrefix.length) : url;
    final match = RegExp(r'/(\d{8})_').firstMatch(clean);
    return match?.group(1);
  }

  static String? _extractUploadDate(String url) => extractUploadDate(url);

  static String? _newestUploadDate(List<Map<String, dynamic>> entries) {
    String? newest;
    for (final entry in entries) {
      final url = entry['url']?.toString();
      if (url == null) continue;
      final d = _extractUploadDate(url);
      if (d != null && (newest == null || d.compareTo(newest) > 0)) {
        newest = d;
      }
    }
    return newest;
  }

  /// 从服务端详情 images 字段解析物品图片 URL（不含位置照片）
  static List<String> urlsFromServerImages(List<dynamic>? images) {
    return parseServerImages(images).itemUrls;
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

/// 服务端 images 字段解析结果（物品图与位置图分离）
class ServerImageParseResult {
  final List<String> itemUrls;
  final List<String> locationUrls;
  /// 原始存储路径（含 __loc__: 前缀），用于写入本地 DB
  final List<String> storagePaths;

  const ServerImageParseResult(
    this.itemUrls,
    this.locationUrls,
    this.storagePaths,
  );
}
