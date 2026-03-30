import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/item.dart';

class ItemProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Item> _items = [];
  List<Category> _categories = [];
  List<Location> _locations = [];
  Item? _selectedItem;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Item> get items => _items;
  List<Category> get categories => _categories;
  List<Location> get locations => _locations;
  Item? get selectedItem => _selectedItem;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  // 获取物品列表
  Future<void> getItems(int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getItems(familyId: familyId);
      _items = response.map<Item>((item) => Item.fromJson(item)).toList();
      // 保存到本地
      for (var item in _items) {
        await _localStorage.saveItem(item.toJson());
      }
    } catch (e) {
      _errorMessage = '获取物品列表失败';
      print('Get items error: $e');
      // 尝试从本地获取
      final localItems = await _localStorage.getItems(familyId: familyId);
      _items = localItems.map<Item>((item) => Item(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        categoryId: item['category_id'],
        locationId: item['location_id'],
        quantity: item['quantity'],
        unit: item['unit'],
        expiryDate: item['expiry_date'] != null ? DateTime.parse(item['expiry_date']) : null,
        purchaseDate: item['purchase_date'] != null ? DateTime.parse(item['purchase_date']) : null,
        price: item['price'],
        familyId: item['family_id'],
        createdBy: item['created_by'],
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
      )).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加物品
  Future<bool> addItem(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addItem(data);
      if (response['success']) {
        final newItem = Item.fromJson(response['item']);
        _items.add(newItem);
        await _localStorage.saveItem(newItem.toJson());
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '添加物品失败';
      print('Add item error: $e');
      // 离线模式下保存到本地
      final itemId = await _localStorage.saveItem(data);
      final newItem = Item(
        id: itemId,
        name: data['name'],
        description: data['description'],
        categoryId: data['category_id'],
        locationId: data['location_id'],
        quantity: data['quantity'],
        unit: data['unit'],
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : null,
        purchaseDate: data['purchase_date'] != null ? DateTime.parse(data['purchase_date']) : null,
        price: data['price'],
        familyId: data['family_id'],
        createdBy: data['created_by'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _items.add(newItem);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新物品
  Future<bool> updateItem(int id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.updateItem(id, data);
      if (response['success']) {
        final updatedItem = Item.fromJson(response['item']);
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        await _localStorage.saveItem(updatedItem.toJson());
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '更新物品失败';
      print('Update item error: $e');
      // 离线模式下更新本地
      data['id'] = id;
      await _localStorage.saveItem(data);
      final updatedItem = Item(
        id: id,
        name: data['name'],
        description: data['description'],
        categoryId: data['category_id'],
        locationId: data['location_id'],
        quantity: data['quantity'],
        unit: data['unit'],
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : null,
        purchaseDate: data['purchase_date'] != null ? DateTime.parse(data['purchase_date']) : null,
        price: data['price'],
        familyId: data['family_id'],
        createdBy: data['created_by'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除物品
  Future<bool> deleteItem(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _apiService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      await _localStorage.deleteItem(id);
      return true;
    } catch (e) {
      _errorMessage = '删除物品失败';
      print('Delete item error: $e');
      // 离线模式下删除本地
      _items.removeWhere((item) => item.id == id);
      await _localStorage.deleteItem(id);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取物品详情
  Future<Item?> getItemDetail(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getItemDetail(id);
      if (response['success']) {
        _selectedItem = Item.fromJson(response['item']);
        notifyListeners();
        return _selectedItem;
      }
      return null;
    } catch (e) {
      _errorMessage = '获取物品详情失败';
      print('Get item detail error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取分类列表
  Future<void> getCategories(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getCategories(familyId);
      _categories = response.map<Category>((item) => Category.fromJson(item)).toList();
      // 保存到本地
      for (var category in _categories) {
        await _localStorage.saveCategory(category.toJson());
      }
    } catch (e) {
      print('Get categories error: $e');
      // 尝试从本地获取
      final localCategories = await _localStorage.getCategories(familyId);
      _categories = localCategories.map<Category>((item) => Category(
        id: item['id'],
        name: item['name'],
        familyId: item['family_id'],
        createdAt: DateTime.parse(item['created_at']),
      )).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加分类
  Future<bool> addCategory(String name, int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addCategory(name, familyId);
      if (response['success']) {
        final newCategory = Category.fromJson(response['category']);
        _categories.add(newCategory);
        await _localStorage.saveCategory(newCategory.toJson());
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '添加分类失败';
      print('Add category error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取位置列表
  Future<void> getLocations(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getLocations(familyId);
      _locations = response.map<Location>((item) => Location.fromJson(item)).toList();
      // 保存到本地
      for (var location in _locations) {
        await _localStorage.saveLocation(location.toJson());
      }
    } catch (e) {
      print('Get locations error: $e');
      // 尝试从本地获取
      final localLocations = await _localStorage.getLocations(familyId);
      _locations = localLocations.map<Location>((item) => Location(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        familyId: item['family_id'],
        createdAt: DateTime.parse(item['created_at']),
      )).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加位置
  Future<bool> addLocation(String name, int familyId, {String? description}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addLocation(name, familyId, description: description);
      if (response['success']) {
        final newLocation = Location.fromJson(response['location']);
        _locations.add(newLocation);
        await _localStorage.saveLocation(newLocation.toJson());
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = '添加位置失败';
      print('Add location error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取库存预警
  Future<List<dynamic>> getInventoryAlerts(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getInventoryAlerts(familyId);
      return response;
    } catch (e) {
      _errorMessage = '获取库存预警失败';
      print('Get inventory alerts error: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取库存报表
  Future<Map<String, dynamic>> getInventoryReport(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getInventoryReport(familyId);
      return response;
    } catch (e) {
      _errorMessage = '获取库存报表失败';
      print('Get inventory report error: $e');
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取采购建议
  Future<List<dynamic>> getPurchaseSuggestions(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getPurchaseSuggestions(familyId);
      return response;
    } catch (e) {
      _errorMessage = '获取采购建议失败';
      print('Get purchase suggestions error: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
