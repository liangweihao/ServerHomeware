import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './auth_service.dart';

/// 家庭信息服务
class FamilyService {
  static const _baseUrl = 'http://localhost:8080/api/v1';
  static const _keyToken = 'auth_token';

  /// 获取当前家庭信息
  /// 调用服务端 GET /api/v1/families/current 接口
  /// 响应：家庭基础信息 + 成员列表 + 邀请码 + 统计数据
  Future<ApiResponse<Map<String, dynamic>>> getCurrentFamily({
    required String userId,
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

      _log('INFO: 调用 GET /api/v1/families/current');
      final response = await http.get(
        Uri.parse('$_baseUrl/families/current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取家庭信息失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取家庭信息失败: $e',
      );
    }
  }

  /// 获取邀请码
  /// 调用服务端 GET /api/v1/families/current/invite-code 接口
  Future<ApiResponse<Map<String, dynamic>>> getInviteCode({
    required String familyId,
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

      _log('INFO: 调用 GET /api/v1/families/current/invite-code');
      final response = await http.get(
        Uri.parse('$_baseUrl/families/current/invite-code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取邀请码失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取邀请码失败: $e',
      );
    }
  }

  /// 刷新邀请码
  /// 调用服务端 POST /api/v1/families/current/refresh-invite-code 接口
  Future<ApiResponse<Map<String, dynamic>>> refreshInviteCode({
    required String familyId,
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

      _log('INFO: 调用 POST /api/v1/families/current/refresh-invite-code');
      final response = await http.post(
        Uri.parse('$_baseUrl/families/current/refresh-invite-code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 刷新邀请码失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '刷新邀请码失败: $e',
      );
    }
  }

  /// 从 SharedPreferences 获取 token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 处理 HTTP 响应
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message'] ?? 'success';

      if (code != 200) {
        _log('WARN: 接口返回错误 - code: $code, message: $message');
      }

      return ApiResponse<Map<String, dynamic>>(
        code: code,
        message: message,
        data: jsonData['data'],
      );
    } catch (e) {
      _log('ERROR: 响应解析失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: '解析错误: $e',
      );
    }
  }

  /// 日志记录
  void _log(String message) {
    print('[FamilyService] $message');
  }
}