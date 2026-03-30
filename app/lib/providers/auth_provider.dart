import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/user.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  // 初始化认证状态
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

  // 注册
  Future<bool> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.register(username, email, password);
      if (response['success']) {
        await _localStorage.saveUser({
          'id': response['user']['id'],
          'username': response['user']['username'],
          'email': response['user']['email'],
          'token': response['token'],
        });
        _isAuthenticated = true;
        _user = User.fromJson(response['user']);
        return true;
      } else {
        _errorMessage = response['message'];
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

  // 登录
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.login(email, password);
      if (response['success']) {
        await _localStorage.saveUser({
          'id': response['user']['id'],
          'username': response['user']['username'],
          'email': response['user']['email'],
          'token': response['token'],
        });
        _isAuthenticated = true;
        _user = User.fromJson(response['user']);
        return true;
      } else {
        _errorMessage = response['message'];
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

  // 登出
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

  // 获取用户信息
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

  // 更新用户信息
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
