import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/user.dart';

/// 认证提供者类，用于管理用户认证状态和相关操作
class AuthProvider extends ChangeNotifier {
  /// 是否正在加载
  bool _isLoading = false;
  /// 是否已认证
  bool _isAuthenticated = false;
  /// 当前用户信息
  User? _user;
  /// 错误信息
  String? _errorMessage;

  /// 获取加载状态
  bool get isLoading => _isLoading;
  /// 获取认证状态
  bool get isAuthenticated => _isAuthenticated;
  /// 获取用户信息
  User? get user => _user;
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// API服务实例
  final ApiService _apiService = ApiService();
  /// 本地存储服务实例
  final LocalStorageService _localStorage = LocalStorageService();

  /// 初始化认证状态
  /// 从本地存储中读取用户信息，判断是否已登录
  Future<void> initAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _localStorage.getUser();
      if (userData != null) {
        _isAuthenticated = true;
        // 这里简化处理，实际应该从服务器获取最新用户信息
      }
    } catch (e) {
      _errorMessage = '初始化认证状态失败';
      print('Init auth error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 用户注册
  /// [username] 用户名
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回注册是否成功
  Future<bool> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.register(username, email, password);
      // 检查响应是否包含user和token字段
      if (response.containsKey('user') && response.containsKey('token')) {
        await _localStorage.saveUser({
          'id': response['user']['id'],
          'username': response['user']['username'],
          'email': response['user']['email'],
          'token': response['token']['access'], // 保存access token
        });
        _isAuthenticated = true;
        _user = User.fromJson(response['user']);
        return true;
      } else if (response['success'] == false) {
        _errorMessage = response['message'];
        return false;
      } else {
        _errorMessage = '注册失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '注册失败，请检查网络连接';
      print('Register error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 用户登录
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回登录是否成功
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.login(email, password);

      // 检查响应是否包含user和token字段
      if (response.containsKey('user') && response.containsKey('token')) {
        await _localStorage.saveUser({
          'id': response['user']['id'],
          'username': response['user']['username'],
          'email': response['user']['email'],
          'token': response['token']['access'], // 保存access token
        });
        _isAuthenticated = true;
        _user = User.fromJson(response['user']);
        return true;
      } else {
        _errorMessage = response['message'] ?? '登录失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败，请检查网络连接';
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 用户登出
  /// 清除本地存储的用户信息，重置认证状态
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _localStorage.clearUser();
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取用户信息
  /// 从服务器获取当前用户的详细信息
  Future<void> getUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getUserProfile();
      if (response['success']) {
        _user = User.fromJson(response['user']);
      }
    } catch (e) {
      print('Get user profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新用户信息
  /// [data] 要更新的用户信息数据
  /// 返回更新是否成功
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.updateUserProfile(data);
      if (response['success']) {
        _user = User.fromJson(response['user']);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '更新用户信息失败';
      print('Update user profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
