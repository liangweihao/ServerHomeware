import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_env.dart';
import 'api_service.dart';
import '../exceptions/auth_exception.dart';

/// 图片上传服务（对接 POST /api/v1/upload/image）
class UploadService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const _keyToken = 'auth_token';

  /// 上传单张图片，返回服务端 URL（如 /uploads/1/xxx.webp）
  Future<ApiResponse<String>> uploadImage(String filePath) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse(code: 401, message: '未登录');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _log('ERROR: 文件不存在 $filePath');
        return ApiResponse(code: 400, message: '图片文件不存在');
      }

      _log('INFO: 上传图片 $filePath');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: p.basename(filePath),
          contentType: MediaType.parse(_contentTypeForPath(filePath)),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _parseUrlResponse(response);
    } catch (e) {
      _log('ERROR: 上传失败 - $e');
      return ApiResponse(code: 500, message: '上传失败: $e');
    }
  }

  /// 批量上传本地图片，返回 URL 列表（顺序与输入一致，失败项跳过）
  Future<List<String>> uploadImages(List<String> localPaths) async {
    final urls = <String>[];
    for (final path in localPaths) {
      if (ItemImageRefs.isRemotePath(path)) {
        urls.add(path);
        continue;
      }
      final result = await uploadImage(path);
      if (result.code == 200 && result.data != null) {
        urls.add(result.data!);
      } else {
        _log('WARN: 单张上传失败 path=$path msg=${result.message}');
      }
    }
    return urls;
  }

  ApiResponse<String> _parseUrlResponse(http.Response response) {
    try {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message']?.toString() ?? 'success';
      _log('RESPONSE: ${json.encode(jsonData)}');

      if (code != 200) {
        if (code == 401 || code == 403) {
          if (shouldTriggerSessionLogout(code, message)) {
            ApiService.handleAuthError(code, message);
          }
        }
        return ApiResponse(code: code, message: message);
      }

      final data = jsonData['data'];
      final url = data is Map ? data['url']?.toString() : null;
      if (url == null || url.isEmpty) {
        return ApiResponse(code: 500, message: '响应缺少 url');
      }
      return ApiResponse(code: 200, message: message, data: url);
    } catch (e) {
      _log('ERROR: 解析响应失败 - $e');
      return ApiResponse(code: response.statusCode, message: '解析错误: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  void _log(String message) {
    debugPrint('[UploadService] $message');
  }

  /// 按扩展名设置 multipart Content-Type（Android 默认常为 octet-stream）
  static String _contentTypeForPath(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

/// 物品图片路径判断（本地 / 服务端）
class ItemImageRefs {
  static bool isRemotePath(String path) {
    return path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('/uploads/');
  }

  static bool isLocalFile(String path) {
    return !isRemotePath(path) && File(path).existsSync();
  }
}
