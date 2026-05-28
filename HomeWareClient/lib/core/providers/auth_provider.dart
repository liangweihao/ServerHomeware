import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/family_service.dart';
import '../services/api_service.dart';
import '../exceptions/auth_exception.dart';
import '../config/app_env.dart';

/// 认证状态枚举
enum AuthState {
  unauthenticated,
  authenticated,
  firstLaunch,
  needCompleteProfile,
}

/// 认证 Provider
class AuthNotifier extends AsyncNotifier<AuthState> {
  final AuthService _authService = AuthService();
  SharedPreferences? _prefs;
  
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserNickname = 'user_nickname';
  static const String _keyFamilyId = 'family_id';
  static const String _keyFamilyRole = 'family_role';
  static const String _keyFirstLaunch = 'first_launch';

  @override
  Future<AuthState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return await _checkAuthState();
  }

  /// 检查认证状态
  Future<AuthState> _checkAuthState() async {
    final isFirstLaunch = _prefs?.getBool(_keyFirstLaunch) ?? true;
    
    if (isFirstLaunch) {
      return AuthState.firstLaunch;
    }
    
    final token = _prefs?.getString(_keyToken);
    final userId = _prefs?.getString(_keyUserId);
    
    if (token != null && userId != null) {
      return AuthState.authenticated;
    }
    
    return AuthState.unauthenticated;
  }

  /// 登录 - 密码方式（调用真实 API）
  Future<void> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    
    try {
      _log('INFO: 开始登录 - 手机号: $phone');
      
      // 调用真实的登录 API
      final response = await _callLoginApi(phone: phone, password: password);
      
      if (response['code'] != 200) {
        final message = response['message'] ?? '登录失败';
        _log('ERROR: 登录失败 - $message');
        throw Exception(message);
      }
      
      final data = response['data'];
      if (data == null) {
        throw Exception('登录失败');
      }
      
      final userMap = data['user'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String?;
      
      // 将服务端返回的 int 类型 id 转换为 String
      if (userMap['id'] is int) {
        userMap['id'] = userMap['id'].toString();
      }
      
      // 保存用户信息
      final user = User.fromJson(userMap);
      await _saveUserInfo(user, accessToken);
      
      // 同时保存 token（供其他服务使用）
      await ApiService.saveToken(accessToken, refreshToken: refreshToken);
      
      await _markFirstLaunchComplete();
      
      _log('INFO: 登录成功 - 用户ID: ${user.id}');
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      _log('ERROR: 登录异常 - $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 调用真实的登录 API
  Future<Map<String, dynamic>> _callLoginApi({
    required String phone,
    required String password,
  }) async {
    final url = AppEnv.uri('/auth/login');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'password': password,
      }),
    );
    
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    _log('RESPONSE: ${json.encode(responseData)}');
    return responseData;
  }

  /// 更新用户信息
  Future<void> updateProfile({
    String? nickname,
    String? avatar,
    String? familyNickname,
  }) async {
    try {
      final userId = _prefs?.getString(_keyUserId);
      if (userId == null) {
        throw Exception('用户未登录');
      }
      
      final response = await _authService.updateProfile(
        userId: userId,
        nickname: nickname,
        avatar: avatar,
        familyNickname: familyNickname,
      );
      
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
      
      final data = response.data;
      if (data == null) {
        throw Exception('更新失败');
      }
      
      final userMap = data['user'] as Map<String, dynamic>;
      
      // 将服务端返回的 int 类型 id 转换为 String
      if (userMap['id'] is int) {
        userMap['id'] = userMap['id'].toString();
      }
      
      final user = User.fromJson(userMap);
      
      // 更新本地存储的用户信息
      await _saveUserInfo(user, _prefs?.getString(_keyToken) ?? '');
    } catch (e) {
      rethrow;
    }
  }

  /// 登录 - 验证码方式
  Future<void> loginWithVerifyCode({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authService.loginWithVerifyCode(
        phone: phone,
        code: code,
      );
      
      await _saveUserInfo(user, 'token_${DateTime.now().millisecondsSinceEpoch}');
      await _markFirstLaunchComplete();
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 注册（调用真实 API）
  Future<void> register({
    required String phone,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncLoading();
    
    try {
      _log('INFO: 开始注册 - 手机号: $phone, 昵称: $nickname');
      
      // 调用真实的注册 API
      final response = await _callRegisterApi(
        phone: phone,
        password: password,
        nickname: nickname,
      );
      
      if (response['code'] != 200) {
        final message = response['message'] ?? '注册失败';
        _log('ERROR: 注册失败 - $message');
        throw Exception(message);
      }
      
      final data = response['data'];
      if (data == null) {
        throw Exception('注册失败');
      }
      
      final userMap = data['user'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String?;
      
      // 将服务端返回的 int 类型 id 转换为 String
      if (userMap['id'] is int) {
        userMap['id'] = userMap['id'].toString();
      }
      
      // 保存用户信息
      final user = User.fromJson(userMap);
      await _saveUserInfo(user, accessToken);
      
      // 同时保存 token
      await ApiService.saveToken(accessToken, refreshToken: refreshToken);
      
      await _markFirstLaunchComplete();
      
      _log('INFO: 注册成功 - 用户ID: ${user.id}');
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      _log('ERROR: 注册异常 - $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 调用真实的注册 API
  Future<Map<String, dynamic>> _callRegisterApi({
    required String phone,
    required String password,
    required String nickname,
  }) async {
    final url = AppEnv.uri('/auth/register');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'password': password,
        'nickname': nickname,
      }),
    );
    
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    _log('RESPONSE: ${json.encode(responseData)}');
    return responseData;
  }

  /// 创建家庭
  /// POST /api/v1/families
  /// 逻辑：创建家庭 → 生成8位邀请码 → 创建family_member记录(role=owner) → 更新用户current_family_id
  Future<void> createFamily({
    required String name,
  }) async {
    state = const AsyncLoading();
    
    try {
      final familyService = FamilyService();
      
      _log('INFO: 开始创建家庭 - $name');
      
      final response = await familyService.createFamily(
        name: name,
      );
      
      if (!response.isSuccess) {
        _log('ERROR: 创建家庭失败 - ${response.message}');
        
        if (shouldTriggerSessionLogout(response.code, response.message)) {
          _log('WARN: Token无效，自动退出登录');
          await logout();
          throw AuthException(
            message: response.message,
            type: getAuthExceptionType(response.code),
          );
        }
        
        throw Exception(response.message);
      }
      
      final data = response.data;
      if (data == null) {
        throw Exception('创建家庭失败');
      }

      await _saveFamilyFromApiData(data, role: 'owner');

      _log('INFO: 创建家庭成功 - familyId: ${data['id']}');
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      _log('ERROR: 创建家庭异常 - $e');
      if (e is! AuthException) {
        state = AsyncError(e, StackTrace.current);
      }
      rethrow;
    }
  }

  /// 加入家庭
  /// POST /api/v1/families/join
  /// 逻辑：查找邀请码对应的家庭 → 检查用户是否已在该家庭 → 创建family_member(role=member) → 更新用户current_family_id
  Future<void> joinFamily({
    required String code,
  }) async {
    state = const AsyncLoading();
    
    try {
      final familyService = FamilyService();
      
      _log('INFO: 开始加入家庭 - 邀请码: $code');
      
      final response = await familyService.joinFamily(
        inviteCode: code,
      );
      
      if (!response.isSuccess) {
        _log('ERROR: 加入家庭失败 - ${response.message}');
        
        if (shouldTriggerSessionLogout(response.code, response.message)) {
          _log('WARN: Token无效，自动退出登录');
          await logout();
          throw AuthException(
            message: response.message,
            type: getAuthExceptionType(response.code),
          );
        }
        
        throw Exception(response.message);
      }
      
      final data = response.data;
      if (data == null) {
        throw Exception('加入家庭失败');
      }

      await _saveFamilyFromApiData(data, role: 'member');

      _log('INFO: 加入家庭成功 - familyId: ${data['id']}');
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      _log('ERROR: 加入家庭异常 - $e');
      if (e is! AuthException) {
        state = AsyncError(e, StackTrace.current);
      }
      rethrow;
    }
  }

  /// 退出登录
  /// 清除本地存储的所有用户信息和token，更新认证状态为unauthenticated
  Future<void> logout() async {
    _log('INFO: 用户退出登录');
    await _clearUserInfo();
    // 同时清除ApiService中的token
    await ApiService.clearToken();
    state = const AsyncData(AuthState.unauthenticated);
    _log('INFO: 退出登录完成，状态已更新为unauthenticated');
  }

  /// 完成首次启动标记
  Future<void> _markFirstLaunchComplete() async {
    await _prefs?.setBool(_keyFirstLaunch, false);
  }

  /// 保存用户信息
  Future<void> _saveUserInfo(User user, String token) async {
    await _prefs?.setString(_keyToken, token);
    await _prefs?.setString(_keyUserId, user.id);
    await _prefs?.setString(_keyUserPhone, user.phone);
    if (user.nickname != null) {
      await _prefs?.setString(_keyUserNickname, user.nickname!);
    }
    if (user.familyId != null) {
      await _prefs?.setString(_keyFamilyId, user.familyId!);
    }
    if (user.familyRole != null) {
      await _prefs?.setString(_keyFamilyRole, user.familyRole!);
    }
  }

  /// 保存家庭信息（登录响应中的 user 字段）
  Future<void> _saveFamilyInfo(User user) async {
    if (user.familyId != null) {
      await _prefs?.setString(_keyFamilyId, user.familyId!);
    }
    if (user.familyRole != null) {
      await _prefs?.setString(_keyFamilyRole, user.familyRole!);
    }
  }

  /// 根据创建/加入家庭接口返回的 FamilyResponse 更新本地缓存
  Future<void> _saveFamilyFromApiData(
    Map<String, dynamic> familyData, {
    required String role,
  }) async {
    final familyId = familyData['id'];
    if (familyId == null) {
      _log('WARN: 家庭数据缺少 id，跳过本地 family 缓存');
      return;
    }
    await _prefs?.setString(_keyFamilyId, familyId.toString());
    await _prefs?.setString(_keyFamilyRole, role);
    _log('INFO: 已更新本地家庭 - familyId: $familyId, role: $role');
  }

  /// 清除用户信息
  Future<void> _clearUserInfo() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyUserPhone);
    await _prefs?.remove(_keyUserNickname);
    await _prefs?.remove(_keyFamilyId);
    await _prefs?.remove(_keyFamilyRole);
  }

  /// 日志记录
  void _log(String message) {
    print('[AuthNotifier] $message');
  }

  /// 获取当前用户信息
  User? get currentUser {
    final userId = _prefs?.getString(_keyUserId);
    final phone = _prefs?.getString(_keyUserPhone);
    if (userId == null || phone == null) return null;
    
    return User(
      id: userId,
      phone: phone,
      nickname: _prefs?.getString(_keyUserNickname),
      familyId: _prefs?.getString(_keyFamilyId),
      familyRole: _prefs?.getString(_keyFamilyRole),
    );
  }

  /// 发送验证码
  Future<void> sendVerifyCode({
    required String phone,
    String purpose = 'login',
  }) async {
    await _authService.sendVerifyCode(phone: phone, purpose: purpose);
  }

  /// 重置密码
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _authService.resetPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }
}

/// 认证 Provider
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// 当前用户 Provider
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authProvider);
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.currentUser;
});
