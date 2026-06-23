import 'dart:async';
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

  /// 是否正在刷新 token（防止并发重复刷新）
  static bool _isRefreshing = false;

  /// 并发刷新等待（多个 401 共享同一次 refresh 结果）
  static Completer<bool>? _refreshCompleter;

  /// 获取 token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 获取 refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
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

  /// 尝试用 refresh token 刷新 access token
  /// 返回 true 表示刷新成功，false 表示 refresh token 也过期
  static Future<bool> tryRefreshToken() async {
    // 已有刷新进行中，等待结果
    if (_isRefreshing && _refreshCompleter != null) {
      _log('INFO: 等待进行中的 Token 刷新...');
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _log('WARN: 无 refresh_token，无法续期');
        _refreshCompleter!.complete(false);
        return false;
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['code'] == 200 && data['data'] != null) {
        final newAccess = data['data']['access_token'] ?? '';
        final newRefresh = data['data']['refresh_token'] ?? '';
        if (newAccess.isNotEmpty) {
          await saveToken(newAccess, refreshToken: newRefresh.isNotEmpty ? newRefresh : null);
          _log('INFO: Token 自动刷新成功');
          _refreshCompleter!.complete(true);
          return true;
        }
      }
      _log('WARN: refresh 接口返回失败 - ${data['message']}');
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      _log('WARN: Token 刷新失败 - $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
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

  /// 执行单次 HTTP 请求
  static Future<http.Response> _sendHttp({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'PUT':
        return http.put(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// 发送 HTTP 请求（401 时自动 refresh 并重试，含 GET）
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

    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      var response = await _sendHttp(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
      );
      var jsonData = json.decode(response.body) as Map<String, dynamic>;

      // 401 时尝试 refresh 并重试（GET/POST/PUT/DELETE 均适用）
      if (jsonData['code'] == 401 && requireAuth) {
        _log('INFO: 收到 401，尝试刷新 token...');
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          final newToken = await getToken();
          if (newToken != null && newToken.isNotEmpty) {
            headers['Authorization'] = 'Bearer $newToken';
            response = await _sendHttp(
              method: method,
              uri: uri,
              headers: headers,
              body: body,
            );
            jsonData = json.decode(response.body) as Map<String, dynamic>;
            if (jsonData['code'] != 401) {
              return jsonData;
            }
          }
        }
        _log('INFO: Token 刷新失败，需要重新登录');
        handleAuthError(401, '会话已过期，请重新登录');
      }

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
