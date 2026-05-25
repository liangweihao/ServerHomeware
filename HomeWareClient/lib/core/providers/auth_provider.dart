import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

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

  /// 登录 - 密码方式
  Future<void> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authService.loginWithPassword(
        phone: phone,
        password: password,
      );
      
      await _saveUserInfo(user, 'token_${DateTime.now().millisecondsSinceEpoch}');
      await _markFirstLaunchComplete();
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
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

  /// 注册
  Future<void> register({
    required String phone,
    required String password,
    required String code,
  }) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authService.register(
        phone: phone,
        password: password,
        code: code,
      );
      
      await _saveUserInfo(user, 'token_${DateTime.now().millisecondsSinceEpoch}');
      await _markFirstLaunchComplete();
      
      state = const AsyncData(AuthState.needCompleteProfile);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 创建家庭
  Future<void> createFamily({
    required String name,
  }) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authService.createFamily(
        familyName: name,
      );
      
      await _saveFamilyInfo(user);
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 加入家庭
  Future<void> joinFamily({
    required String code,
  }) async {
    state = const AsyncLoading();
    
    try {
      final user = await _authService.joinFamily(
        code: code,
      );
      
      await _saveFamilyInfo(user);
      
      state = const AsyncData(AuthState.authenticated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _clearUserInfo();
    state = const AsyncData(AuthState.unauthenticated);
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

  /// 保存家庭信息
  Future<void> _saveFamilyInfo(User user) async {
    if (user.familyId != null) {
      await _prefs?.setString(_keyFamilyId, user.familyId!);
    }
    if (user.familyRole != null) {
      await _prefs?.setString(_keyFamilyRole, user.familyRole!);
    }
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
  final authState = ref.watch(authProvider);
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.currentUser;
});
