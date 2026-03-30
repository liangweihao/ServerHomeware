import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/family.dart';

class FamilyProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Family> _families = [];
  Family? _selectedFamily;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Family> get families => _families;
  Family? get selectedFamily => _selectedFamily;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  // 获取家庭列表
  Future<void> getFamilies() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getFamilies();
      _families = response.map<Family>((item) => Family.fromJson(item)).toList();
      await _localStorage.saveFamilies(response);
    } catch (e) {
      _errorMessage = '获取家庭列表失败';
      print('Get families error: $e');
      // 尝试从本地获取
      final localFamilies = await _localStorage.getFamilies();
      _families = localFamilies.map<Family>((item) => Family(
        id: item['id'],
        name: item['name'],
        createdBy: item['created_by'],
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['created_at']),
      )).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建家庭
  Future<bool> createFamily(String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.createFamily(name);
      if (response['success']) {
        final newFamily = Family.fromJson(response['family']);
        _families.add(newFamily);
        await _localStorage.saveFamilies(_families.map((f) => f.toJson()).toList());
        return true;
      } else {
        _errorMessage = response['message'];
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

  // 加入家庭
  Future<bool> joinFamily(int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.joinFamily(familyId);
      if (response['success']) {
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

  // 选择家庭
  void selectFamily(Family family) {
    _selectedFamily = family;
    notifyListeners();
  }

  // 获取家庭详情
  Future<Family?> getFamilyDetail(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getFamilyDetail(familyId);
      if (response['success']) {
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
