import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './auth_service.dart';

/// 贡献度服务
class ContributionService {
  static const _baseUrl = 'http://192.168.1.104:8000/api/v1';
  static const _keyToken = 'auth_token';

  /// 获取用户贡献数据
  /// 调用服务端相关接口获取用户贡献信息
  Future<ApiResponse<Map<String, dynamic>>> getUserContribution({
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

      _log('INFO: 调用获取贡献度接口');
      final response = await http.get(
        Uri.parse('$_baseUrl/contributions/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取贡献度失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取贡献度失败: $e',
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
      
      // 打印完整的响应 JSON 日志
      _log('RESPONSE: ${json.encode(jsonData)}');

      if (code != 200) {
        _log('WARN: 接口返回错误 - code: $code, message: $message');
      }

      return ApiResponse<Map<String, dynamic>>(
        code: code,
        message: message,
        data: jsonData['data'],
      );
    } catch (e) {
      _log('ERROR: 响应解析失败 - $e, body: ${response.body}');
      return ApiResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: '解析错误: $e',
      );
    }
  }

  /// 日志记录
  void _log(String message) {
    print('[ContributionService] $message');
  }
}