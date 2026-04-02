import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/family.dart';

/// 家庭提供者类，用于管理家庭相关的状态和操作
class FamilyProvider extends ChangeNotifier {
  /// 是否正在加载
  bool _isLoading = false;
  /// 家庭列表
  List<Family> _families = [];
  /// 当前选择的家庭
  Family? _selectedFamily;
  /// 错误信息
  String? _errorMessage;

  /// 获取加载状态
  bool get isLoading => _isLoading;
  /// 获取家庭列表
  List<Family> get families => _families;
  /// 获取当前选择的家庭
  Family? get selectedFamily => _selectedFamily;
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// API服务实例
  final ApiService _apiService = ApiService();
  /// 本地存储服务实例
  final LocalStorageService _localStorage = LocalStorageService();

  /// 获取家庭列表
  /// 从服务器获取家庭列表，并保存到本地存储
  /// 若网络请求失败，尝试从本地获取
  Future<void> getFamilies() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getFamilies();
      _families = List<Family>.from(
        response.map((item) => Family.fromJson(Map<String, dynamic>.from(item)))
      );
      await _localStorage.saveFamilies(response);
    } catch (e) {
      _errorMessage = '获取家庭列表失败';
      print('Get families error: $e');
      // 尝试从本地获取
      final localFamilies = await _localStorage.getFamilies();
      _families = localFamilies.map<Family>((item) => Family.fromJson(Map<String, dynamic>.from(item))).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建家庭
  /// [name] 家庭名称
  /// 返回创建是否成功
  Future<bool> createFamily(String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.createFamily(name);
      if (response.containsKey('id') && response.containsKey('name')) {
        final newFamily = Family.fromJson(response);
        _families.add(newFamily);
        await _localStorage.saveFamilies(_families.map((f) => f.toJson()).toList());
        return true;
      } else if (response['success'] == true && response.containsKey('family')) {
        final newFamily = Family.fromJson(response['family']);
        _families.add(newFamily);
        await _localStorage.saveFamilies(_families.map((f) => f.toJson()).toList());
        return true;
      } else {
        _errorMessage = response['message'] ?? '创建家庭失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '创建家庭失败';
      print('Create family error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加入家庭
  /// [familyId] 家庭ID
  /// 返回加入是否成功
  Future<bool> joinFamily(int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.joinFamily(familyId);
      if (response['success'] == true) {
        // 重新获取家庭列表
        await getFamilies();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '加入家庭失败';
      print('Join family error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 选择家庭
  /// [family] 要选择的家庭
  void selectFamily(Family family) {
    _selectedFamily = family;
    notifyListeners();
  }

  /// 更新选中家庭
  /// [familyId] 家庭ID
  /// 返回更新是否成功
  Future<bool> updateSelectedFamily(int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.updateSelectedFamily(familyId);
      if (response.containsKey('message') && response.containsKey('family_id')) {
        // 重新获取家庭列表，以更新 is_selected 字段
        await getFamilies();
        return true;
      } else {
        _errorMessage = '更新选中家庭失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '更新选中家庭失败';
      print('Update selected family error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取家庭详情
  /// [familyId] 家庭ID
  /// 返回家庭详情，若获取失败则返回null
  Future<Family?> getFamilyDetail(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getFamilyDetail(familyId);
      // 检查响应是否直接包含家庭数据
      if (response.containsKey('id') && response.containsKey('name')) {
        final family = Family.fromJson(response);
        // 更新本地家庭列表
        final index = _families.indexWhere((f) => f.id == familyId);
        if (index != -1) {
          _families[index] = family;
        }
        notifyListeners();
        return family;
      } else if (response['success'] == true && response.containsKey('family')) {
        final family = Family.fromJson(response['family']);
        // 更新本地家庭列表
        final index = _families.indexWhere((f) => f.id == familyId);
        if (index != -1) {
          _families[index] = family;
        }
        notifyListeners();
        return family;
      }
      return null;
    } catch (e) {
      _errorMessage = '获取家庭详情失败';
      print('Get family detail error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
