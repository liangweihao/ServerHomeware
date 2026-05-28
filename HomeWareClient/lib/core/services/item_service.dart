import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import '../config/app_env.dart';
import '../exceptions/auth_exception.dart';

/// 物品信息服务
class ItemService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const _keyToken = 'auth_token';

  /// 创建物品
  /// 调用服务端 POST /api/v1/items 接口
  Future<ApiResponse<Map<String, dynamic>>> createItem({
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 POST /api/v1/items');
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 创建物品失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '创建物品失败: $e',
      );
    }
  }

  /// 更新物品
  /// 调用服务端 PUT /api/v1/items/{id} 接口
  Future<ApiResponse<Map<String, dynamic>>> updateItem({
    required int itemId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 PUT /api/v1/items/$itemId');
      final response = await http.put(
        Uri.parse('$_baseUrl/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 更新物品失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '更新物品失败: $e',
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message'] ?? 'success';

      _log('RESPONSE: ${json.encode(jsonData)}');

      if (code != 200) {
        _log('WARN: 接口返回错误 - code: $code, message: $message');

        if (code == 401 || code == 403) {
          if (shouldTriggerSessionLogout(code, message)) {
            _log('WARN: Token无效或已过期，触发认证错误处理');
            ApiService.handleAuthError(code, message);
          } else {
            _log('INFO: 业务态 401/403，不退出登录 - $message');
          }
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        code: code,
        message: message,
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      _log('ERROR: 响应解析失败 - $e, body: ${response.body}');
      return ApiResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: '解析错误: $e',
      );
    }
  }

  void _log(String message) {
    print('[ItemService] $message');
  }
}
