import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_env.dart';
import '../exceptions/auth_exception.dart';
import 'api_service.dart';
class AlertService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const _keyToken = 'auth_token';

  /// 获取已过期物品列表 GET /api/v1/alerts/expired
  Future<ApiResponse<List<Map<String, dynamic>>>> getExpiredItems() async {
    return _getList('/alerts/expired');
  }

  /// 获取即将过期物品列表 GET /api/v1/alerts/expiring
  Future<ApiResponse<List<Map<String, dynamic>>>> getExpiringItems({
    int days = 7,
  }) async {
    return _getList('/alerts/expiring?days=$days');
  }

  /// 获取库存不足物品列表 GET /api/v1/alerts/low-stock
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowStockItems() async {
    return _getList('/alerts/low-stock');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> _getList(String path) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse(code: 401, message: '未登录');
      }

      final uri = Uri.parse('$_baseUrl$path');
      _log('INFO: 调用 GET $uri');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleListResponse(response);
    } catch (e) {
      _log('ERROR: 请求失败 $path - $e');
      return ApiResponse(code: 500, message: '请求失败: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  ApiResponse<List<Map<String, dynamic>>> _handleListResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 404) {
        _log('WARN: 接口不存在 HTTP 404 - ${response.request?.url}');
        return ApiResponse(code: 404, message: '接口不存在');
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        return ApiResponse(
          code: response.statusCode,
          message: '空响应',
        );
      }

      final decoded = json.decode(body);
      if (decoded is! Map<String, dynamic>) {
        return ApiResponse(
          code: response.statusCode,
          message: '响应格式错误',
        );
      }

      final jsonData = decoded;
      final code = jsonData['code'] as int? ?? response.statusCode;
      final message = jsonData['message']?.toString() ??
          jsonData['detail']?.toString() ??
          'success';

      if (code != 200) {
        _log('WARN: 接口错误 code=$code message=$message');
        if (code == 401 || code == 403) {
          if (shouldTriggerSessionLogout(code, message)) {
            ApiService.handleAuthError(code, message);
          }
        }
        return ApiResponse(code: code, message: message);
      }

      final raw = jsonData['data'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) list.add(item);
        }
      }

      _log('INFO: 返回 ${list.length} 条');
      return ApiResponse(code: 200, message: message, data: list);
    } catch (e) {
      _log('ERROR: 解析失败 - $e');
      return ApiResponse(code: 500, message: '解析错误: $e');
    }
  }

  void _log(String message) {
    print('[AlertService] $message');
  }
}
