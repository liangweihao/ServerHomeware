import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import '../config/app_env.dart';
import '../exceptions/auth_exception.dart';

/// 家庭信息服务
class FamilyService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
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

  /// 创建家庭
  /// 调用服务端 POST /api/v1/families 接口
  /// Request: {name}
  /// 逻辑：创建家庭 → 生成8位邀请码 → 创建family_member记录(role=owner) → 更新用户current_family_id
  Future<ApiResponse<Map<String, dynamic>>> createFamily({
    required String name,
    String spaceType = 'home',
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

      _log('INFO: 调用 POST /api/v1/families space_type=$spaceType');
      final response = await http.post(
        Uri.parse('$_baseUrl/families'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'space_type': spaceType,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 创建家庭失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '创建家庭失败: $e',
      );
    }
  }

  /// 获取用户所有家庭列表
  /// 调用服务端 GET /api/v1/families 接口
  Future<ApiResponse<List<dynamic>>> getUserFamilies() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<List<dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 GET /api/v1/families');
      final response = await http.get(
        Uri.parse('$_baseUrl/families'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleListResponse(response);
    } catch (e) {
      _log('ERROR: 获取家庭列表失败 - $e');
      return ApiResponse<List<dynamic>>(
        code: 500,
        message: '获取家庭列表失败: $e',
      );
    }
  }

  /// 切换当前家庭
  /// 调用服务端 POST /api/v1/families/{familyId}/switch 接口
  Future<ApiResponse<Map<String, dynamic>>> switchFamily({
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

      _log('INFO: 调用 POST /api/v1/families/$familyId/switch');
      final response = await http.post(
        Uri.parse('$_baseUrl/families/$familyId/switch'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 切换家庭失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '切换家庭失败: $e',
      );
    }
  }

  /// 更新家庭信息
  /// 调用服务端 PUT /api/v1/families/{familyId} 接口（owner/admin）
  Future<ApiResponse<Map<String, dynamic>>> updateFamily({
    required String familyId,
    required String name,
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

      _log('INFO: 调用 PUT /api/v1/families/$familyId');
      final response = await http.put(
        Uri.parse('$_baseUrl/families/$familyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name}),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 更新家庭失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '更新家庭失败: $e',
      );
    }
  }

  /// 删除家庭
  /// 调用服务端 DELETE /api/v1/families/{familyId} 接口
  /// Request: {confirm_name}
  /// 逻辑：验证家庭名称是否匹配 → 删除家庭及其所有成员和相关数据
  Future<ApiResponse<Map<String, dynamic>>> deleteFamily({
    required String familyId,
    required String confirmName,
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

      _log('INFO: 调用 DELETE /api/v1/families/$familyId, confirmName: $confirmName');
      final response = await http.delete(
        Uri.parse('$_baseUrl/families/$familyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'confirm_name': confirmName,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 删除家庭失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '删除家庭失败: $e',
      );
    }
  }

  /// 加入家庭
  /// 调用服务端 POST /api/v1/families/join 接口
  /// Request: {invite_code}
  /// 逻辑：查找邀请码对应的家庭 → 检查用户是否已在该家庭 → 创建family_member(role=member) → 更新用户current_family_id
  Future<ApiResponse<Map<String, dynamic>>> joinFamily({
    required String inviteCode,
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

      _log('INFO: 调用 POST /api/v1/families/join');
      final response = await http.post(
        Uri.parse('$_baseUrl/families/join'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'invite_code': inviteCode,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 加入家庭失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '加入家庭失败: $e',
      );
    }
  }

  /// 更新成员角色 — PUT /api/v1/families/{familyId}/members/{userId}
  Future<ApiResponse<Map<String, dynamic>>> updateMemberRole({
    required int familyId,
    required int userId,
    required String role,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(code: 401, message: '未登录');
      }

      _log('INFO: 更新成员角色 family=$familyId user=$userId role=$role');
      final response = await http.put(
        Uri.parse('$_baseUrl/families/$familyId/members/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'role': role}),
      );
      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 更新成员角色失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '更新成员角色失败: $e',
      );
    }
  }

  /// 从 SharedPreferences 获取 token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 处理 HTTP 响应 (返回 Map)
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message'] ?? 'success';
      
      // 打印完整的响应 JSON 日志
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

  /// 处理 HTTP 响应 (返回 List)
  ApiResponse<List<dynamic>> _handleListResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message'] ?? 'success';
      
      // 打印完整的响应 JSON 日志
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

      return ApiResponse<List<dynamic>>(
        code: code,
        message: message,
        data: List<dynamic>.from(jsonData['data'] ?? []),
      );
    } catch (e) {
      _log('ERROR: 响应解析失败 - $e, body: ${response.body}');
      return ApiResponse<List<dynamic>>(
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