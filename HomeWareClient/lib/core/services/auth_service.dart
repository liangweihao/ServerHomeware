import 'dart:convert';
import 'dart:math';

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

/// 认证服务（模拟 API）
class AuthService {
  static const _delay = Duration(seconds: 1);
  static const _verifyDelay = Duration(milliseconds: 800);
  
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
    
    // 模拟验证失败（手机号密码格式不对时）
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
    
    // 模拟成功：创建用户并自动创建默认家庭
    final userId = _generateId();
    final familyId = _generateId();
    final nickname = '用户${phone.substring(7)}';
    
    // 自动分配默认头像
    final avatarColorIndex = phone.hashCode.abs() % avatarColors.length;
    
    final user = User(
      id: userId,
      phone: phone,
      nickname: nickname,
      avatar: 'avatar_$avatarColorIndex', // 存储头像颜色索引
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

  /// 获取当前用户信息
  /// GET /api/v1/users/me
  /// 从请求 Header 提取 JWT → 解析 → 查数据库获取用户
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser({
    required String userId,
  }) async {
    await Future.delayed(_delay);
    
    // 模拟用户不存在
    if (userId.isEmpty) {
      return ApiResponse<Map<String, dynamic>>(
        code: 404,
        message: '用户不存在',
        data: null,
      );
    }
    
    // 模拟成功（这里应该是从数据库获取，这里用模拟数据）
    final user = User(
      id: userId,
      phone: '13800000000',
      nickname: '用户0000',
      avatar: 'avatar_0',
      familyId: _generateId(),
      familyRole: 'admin',
    );
    
    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'user': user.toJson(),
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
    await Future.delayed(_delay);
    
    // 模拟用户不存在
    if (userId.isEmpty) {
      return ApiResponse<Map<String, dynamic>>(
        code: 404,
        message: '用户不存在',
        data: null,
      );
    }
    
    // 模拟成功
    final user = User(
      id: userId,
      phone: '13800000000',
      nickname: nickname ?? '用户',
      avatar: avatar ?? 'avatar_0',
      familyId: _generateId(),
      familyRole: 'admin',
    );
    
    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'user': user.toJson(),
      },
    );
  }

  /// 预设头像颜色列表（10种渐变色组合）
  static const List<List<int>> avatarColors = [
    [0xFF667eea, 0xFF764ba2], // 紫蓝渐变
    [0xFFf093fb, 0xFFf5576c], // 粉红渐变
    [0xFF4facfe, 0xFF00f2fe], // 蓝色渐变
    [0xFF43e97b, 0xFF38f9d7], // 绿蓝渐变
    [0xFFfa709a, 0xFFfee140], // 橙粉渐变
    [0xFF30cfd0, 0xFF330867], // 深蓝渐变
    [0xFFa8edea, 0xFFfed6e3], // 浅粉渐变
    [0xFFffecd2, 0xFFfcb69f], // 暖橙渐变
    [0xFFff9a9e, 0xFFfecfef], // 玫红渐变
    [0xFFa18cd1, 0xFFfbc2eb], // 紫粉渐变
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
    
    // 模拟验证手机号
    if (phone.length != 11 || !phone.startsWith('1')) {
      throw Exception('请输入正确的手机号');
    }
    
    // 模拟发送成功
    return;
  }

  /// 验证码登录
  Future<User> loginWithVerifyCode({
    required String phone,
    required String code,
  }) async {
    await Future.delayed(_delay);
    
    // 模拟验证失败
    if (code.length != 6) {
      throw Exception('验证码格式不正确');
    }
    
    // 模拟验证码错误
    if (code != '123456') {
      throw Exception('验证码错误，请重试');
    }
    
    // 模拟成功
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
    
    // 模拟验证
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
    
    // 模拟成功：创建用户并自动创建默认家庭
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

  /// 创建家庭
  Future<User> createFamily({
    required String familyName,
  }) async {
    await Future.delayed(_delay);
    
    if (familyName.length < 2 || familyName.length > 15) {
      throw Exception('家庭名称需要2-15个字符');
    }
    
    // 模拟成功，返回更新的用户信息
    return User(
      id: _generateId(),
      phone: '13800000000',
      nickname: '用户',
      familyId: _generateId(),
      familyRole: 'admin',
    );
  }

  /// 加入家庭
  Future<User> joinFamily({
    required String code,
  }) async {
    await Future.delayed(_delay);
    
    if (code.isEmpty) {
      throw Exception('请输入邀请码');
    }
    
    // 模拟邀请码无效
    if (code != '12345678') {
      throw Exception('邀请码无效，请确认后重试');
    }
    
    // 模拟成功
    return User(
      id: _generateId(),
      phone: '13800000000',
      nickname: '用户',
      familyId: _generateId(),
      familyRole: 'member',
    );
  }
}
