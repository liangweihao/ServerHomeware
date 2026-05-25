import 'dart:math';

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
  Future<User> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_delay);
    
    // 模拟验证失败（手机号密码格式不对时）
    if (phone.length != 11 || !phone.startsWith('1')) {
      throw Exception('请输入正确的手机号');
    }
    if (password.length < 8) {
      throw Exception('密码错误');
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
  Future<User> register({
    required String phone,
    required String password,
    required String code,
  }) async {
    await Future.delayed(_delay);
    
    // 模拟验证
    if (phone.length != 11 || !phone.startsWith('1')) {
      throw Exception('请输入正确的手机号');
    }
    if (password.length < 6) {
      throw Exception('密码需要至少6位');
    }
    if (code != '123456') {
      throw Exception('验证码错误');
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
