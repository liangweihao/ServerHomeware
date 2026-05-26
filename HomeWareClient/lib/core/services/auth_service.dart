import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Token 模型类
class Token {
  final String accessToken;
  final String refreshToken;

  Token({
    required this.accessToken,
    required this.refreshToken,
  });

  Token copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return Token(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

/// 统一响应模型类
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }

  bool get isSuccess => code == 200;
}

/// 用户信息模型
class User {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatar;
  final String? familyId;
  final String? familyRole;
  
  User({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatar,
    this.familyId,
    this.familyRole,
  });

  User copyWith({
    String? id,
    String? phone,
    String? nickname,
    String? avatar,
    String? familyId,
    String? familyRole,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      familyId: familyId ?? this.familyId,
      familyRole: familyRole ?? this.familyRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'family_id': familyId,
      'family_role': familyRole,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      familyId: json['family_id'],
      familyRole: json['family_role'],
    );
  }
}

/// 家庭信息模型
class Family {
  final String id;
  final String name;
  final String inviteCode;
  final int memberCount;
  final int itemCount;
  final List<FamilyMember> members;
  final DateTime createdAt;

  Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
    required this.itemCount,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'member_count': memberCount,
      'item_count': itemCount,
      'members': members.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'],
      name: json['name'],
      inviteCode: json['invite_code'],
      memberCount: json['member_count'],
      itemCount: json['item_count'],
      members: (json['members'] as List).map((m) => FamilyMember.fromJson(m)).toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 家庭成员模型
class FamilyMember {
  final String id;
  final String userId;
  final String nickname;
  final String phone;
  final String role;
  final DateTime joinedAt;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.phone,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'phone': phone,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      userId: json['user_id'],
      nickname: json['nickname'],
      phone: json['phone'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}

/// 认证服务
class AuthService {
  static const _baseUrl = 'http://192.168.1.104:8000/api/v1';
  static const _keyToken = 'auth_token';
  static const _delay = Duration(seconds: 1);
  
  /// 从 SharedPreferences 获取 token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 日志记录
  void _log(String message) {
    print('[AuthService] $message');
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

  /// 生成随机用户 ID
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// 密码登录
  /// POST /api/v1/auth/login
  /// Request: {phone, password}
  /// Response: {code, message, data: {user, access_token, refresh_token}}
  /// 逻辑：验证手机号密码 → 更新last_login_at → 返回token
  Future<ApiResponse<Map<String, dynamic>>> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_delay);
    
    if (phone.length != 11 || !phone.startsWith('1')) {
      return ApiResponse<Map<String, dynamic>>(
        code: 400,
        message: '请输入正确的手机号',
        data: null,
      );
    }
    if (password.length < 8) {
      return ApiResponse<Map<String, dynamic>>(
        code: 401,
        message: '密码错误',
        data: null,
      );
    }
    
    final userId = _generateId();
    final familyId = _generateId();
    final nickname = '用户${phone.substring(7)}';
    final avatarColorIndex = phone.hashCode.abs() % avatarColors.length;
    
    final user = User(
      id: userId,
      phone: phone,
      nickname: nickname,
      avatar: 'avatar_$avatarColorIndex',
      familyId: familyId,
      familyRole: 'admin',
    );
    
    final token = Token(
      accessToken: 'access_${_generateId()}',
      refreshToken: 'refresh_${_generateId()}',
    );
    
    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'user': user.toJson(),
        'access_token': token.accessToken,
        'refresh_token': token.refreshToken,
      },
    );
  }



  /// 更新用户信息
  /// PUT /api/v1/users/me
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String userId,
    String? nickname,
    String? avatar,
    String? familyNickname,
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

      _log('INFO: 调用 PUT /api/v1/users/me');
      
      // 构造请求体
      final Map<String, dynamic> body = {};
      if (nickname != null) body['nickname'] = nickname;
      if (avatar != null) body['avatar_url'] = avatar;

      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 更新用户信息失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '更新用户信息失败: $e',
      );
    }
  }

  /// 预设头像颜色列表（10种渐变色组合）
  static const List<List<int>> avatarColors = [
    [0xFF667eea, 0xFF764ba2],
    [0xFFf093fb, 0xFFf5576c],
    [0xFF4facfe, 0xFF00f2fe],
    [0xFF43e97b, 0xFF38f9d7],
    [0xFFfa709a, 0xFFfee140],
    [0xFF30cfd0, 0xFF330867],
    [0xFFa8edea, 0xFFfed6e3],
    [0xFFffecd2, 0xFFfcb69f],
    [0xFFff9a9e, 0xFFfecfef],
    [0xFFa18cd1, 0xFFfbc2eb],
  ];

  /// 根据用户标识获取头像颜色索引
  static int getAvatarColorIndex(String? identifier) {
    if (identifier == null || identifier.isEmpty) {
      return 0;
    }
    return identifier.hashCode.abs() % avatarColors.length;
  }

  /// 获取头像颜色对
  static List<int> getAvatarColors(int index) {
    return avatarColors[index.abs() % avatarColors.length];
  }

  /// 发送验证码
  Future<void> sendVerifyCode({
    required String phone,
    String purpose = 'login',
  }) async {
    await Future.delayed(_delay);
    
    if (phone.length != 11 || !phone.startsWith('1')) {
      throw Exception('请输入正确的手机号');
    }
    
    return;
  }

  /// 验证码登录
  Future<User> loginWithVerifyCode({
    required String phone,
    required String code,
  }) async {
    await Future.delayed(_delay);
    
    if (code.length != 6) {
      throw Exception('验证码格式不正确');
    }
    
    if (code != '123456') {
      throw Exception('验证码错误，请重试');
    }
    
    return User(
      id: _generateId(),
      phone: phone,
      nickname: '用户${phone.substring(7)}',
      familyId: null,
      familyRole: null,
    );
  }

  /// 注册
  /// POST /api/v1/auth/register
  /// Request: {phone, password, nickname}
  /// Response: {code, message, data: {user, access_token, refresh_token}}
  /// 逻辑：检查手机号唯一 → 创建用户 → 自动创建默认家庭 → 返回token
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String phone,
    required String password,
    required String nickname,
  }) async {
    await Future.delayed(_delay);
    
    if (phone.length != 11 || !phone.startsWith('1')) {
      return ApiResponse<Map<String, dynamic>>(
        code: 400,
        message: '请输入正确的手机号',
        data: null,
      );
    }
    if (password.length < 6) {
      return ApiResponse<Map<String, dynamic>>(
        code: 400,
        message: '密码需要至少6位',
        data: null,
      );
    }
    if (nickname.isEmpty || nickname.length > 50) {
      return ApiResponse<Map<String, dynamic>>(
        code: 400,
        message: '昵称长度需要1-50个字符',
        data: null,
      );
    }
    
    final userId = _generateId();
    final familyId = _generateId();
    
    final user = User(
      id: userId,
      phone: phone,
      nickname: nickname,
      familyId: familyId,
      familyRole: 'admin',
    );
    
    final token = Token(
      accessToken: 'access_${_generateId()}',
      refreshToken: 'refresh_${_generateId()}',
    );
    
    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'user': user.toJson(),
        'access_token': token.accessToken,
        'refresh_token': token.refreshToken,
      },
    );
  }

  /// 重置密码
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(_delay);
    
    if (code != '123456') {
      throw Exception('验证码错误');
    }
    if (newPassword.length < 8) {
      throw Exception('密码需要8位以上');
    }
    
    return;
  }
}
