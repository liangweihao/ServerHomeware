import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_env.dart';
import '../exceptions/auth_exception.dart';

/// 登录请求模型
class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}

/// 登录响应模型
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: json['user'] ?? {},
    );
  }
}

/// 统一响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200;
  
  /// 检查是否为认证错误
  bool get isAuthError => code == 401 || code == 403;
}

/// API 服务基类
class ApiService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  
  /// 认证错误处理回调
  static void Function()? onAuthError;

  /// 设置认证错误处理回调
  static void setAuthErrorCallback(void Function() callback) {
    onAuthError = callback;
  }

  /// 获取 token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 保存 token
  static Future<void> saveToken(String token, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  /// 清除 token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
  }

  /// 处理认证错误（仅 token 失效等会话问题，不含「未加入家庭」等业务 401）
  static void handleAuthError(int code, String message) {
    if (!shouldTriggerSessionLogout(code, message)) {
      _log('SKIP SESSION LOGOUT: code=$code, message=$message');
      return;
    }
    _log('AUTH ERROR: code=$code, message=$message');
    onAuthError?.call();
  }

  /// 日志记录
  static void _log(String message) {
    print('[ApiService] $message');
  }

  /// 发送 HTTP 请求
  static Future<Map<String, dynamic>> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // 如果需要认证，添加 token
    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // 解析响应
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      throw Exception('请求失败: $e');
    }
  }

  /// GET 请求
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = true,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      requireAuth: requireAuth,
    );
  }

  /// POST 请求
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      requireAuth: requireAuth,
    );
  }

  /// PUT 请求
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      requireAuth: requireAuth,
    );
  }

  /// DELETE 请求
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      requireAuth: requireAuth,
    );
  }
}
