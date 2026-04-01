import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/models/item.dart';

/// 物品提供者类，用于管理物品相关的状态和操作
class ItemProvider extends ChangeNotifier {
  /// 是否正在加载
  bool _isLoading = false;
  /// 物品列表
  List<Item> _items = [];
  /// 分类列表
  List<Category> _categories = [];
  /// 位置列表
  List<Location> _locations = [];
  /// 库存预警列表
  List<dynamic> _inventoryAlerts = [];
  /// 库存报表数据
  Map<String, dynamic> _inventoryReport = {};
  /// 采购建议列表
  List<dynamic> _purchaseSuggestions = [];
  /// 当前选中的物品
  Item? _selectedItem;
  /// 错误信息
  String? _errorMessage;

  /// 获取加载状态
  bool get isLoading => _isLoading;
  /// 获取物品列表
  List<Item> get items => _items;
  /// 获取分类列表
  List<Category> get categories => _categories;
  /// 获取位置列表
  List<Location> get locations => _locations;
  /// 获取库存预警列表
  List<dynamic> get inventoryAlerts => _inventoryAlerts;
  /// 获取库存报表数据
  Map<String, dynamic> get inventoryReport => _inventoryReport;
  /// 获取采购建议列表
  List<dynamic> get purchaseSuggestions => _purchaseSuggestions;
  /// 获取当前选中的物品
  Item? get selectedItem => _selectedItem;
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// API服务实例
  final ApiService _apiService = ApiService();
  /// 本地存储服务实例
  final LocalStorageService _localStorage = LocalStorageService();

  /// 获取物品列表
  /// [familyId] 家庭ID
  /// 从服务器获取物品列表，并保存到本地存储
  /// 若网络请求失败，尝试从本地获取
  Future<void> getItems(int familyId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getItems(familyId: familyId);
      _items = List<Item>.from(
        response.map((item) => Item.fromJson(Map<String, dynamic>.from(item)))
      );
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

  /// 添加物品
  /// [data] 物品数据
  /// 返回添加是否成功
  Future<bool> addItem(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addItem(data);
      // 检查响应是否直接包含物品数据
      if (response.containsKey('id') && response.containsKey('name')) {
        final newItem = Item.fromJson(response);
        _items.add(newItem);
        await _localStorage.saveItem(newItem.toJson());
        return true;
      } else if (response['success'] == true && response.containsKey('item')) {
        final newItem = Item.fromJson(response['item']);
        _items.add(newItem);
        await _localStorage.saveItem(newItem.toJson());
        return true;
      } else {
        _errorMessage = response['message'] ?? '添加物品失败';
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

  /// 更新物品
  /// [id] 物品ID
  /// [data] 要更新的物品数据
  /// 返回更新是否成功
  Future<bool> updateItem(int id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.updateItem(id, data);
      // 检查响应是否直接包含物品数据
      if (response.containsKey('id') && response.containsKey('name')) {
        final updatedItem = Item.fromJson(response);
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        await _localStorage.saveItem(updatedItem.toJson());
        return true;
      } else if (response['success'] == true && response.containsKey('item')) {
        final updatedItem = Item.fromJson(response['item']);
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        await _localStorage.saveItem(updatedItem.toJson());
        return true;
      } else {
        _errorMessage = response['message'] ?? '更新物品失败';
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

  /// 删除物品
  /// [id] 物品ID
  /// 返回删除是否成功
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

  /// 获取物品详情
  /// [id] 物品ID
  /// 返回物品详情，若获取失败则返回null
  Future<Item?> getItemDetail(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getItemDetail(id);
      // 检查响应是否直接包含物品数据
      if (response.containsKey('id') && response.containsKey('name')) {
        _selectedItem = Item.fromJson(response);
        notifyListeners();
        return _selectedItem;
      } else if (response['success'] == true && response.containsKey('item')) {
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

  /// 获取分类列表
  /// [familyId] 家庭ID
  /// 从服务器获取分类列表，并保存到本地存储
  /// 若网络请求失败，尝试从本地获取
  Future<void> getCategories(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getCategories(familyId);
      _categories = List<Category>.from(
        response.map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
      );
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
        icon: item['icon'],
        color: item['color'],
        familyId: item['family_id'],
        createdAt: DateTime.parse(item['created_at']),
      )).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加分类
  /// [name] 分类名称
  /// [familyId] 家庭ID
  /// [icon] 分类图标（可选）
  /// [color] 分类颜色（可选）
  /// 返回添加是否成功
  Future<bool> addCategory(String name, int familyId, {String? icon, String? color}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addCategory(name, familyId, icon: icon, color: color);
      // 检查响应是否直接包含分类数据
      if (response.containsKey('id') && response.containsKey('name')) {
        final newCategory = Category.fromJson(response);
        _categories.add(newCategory);
        await _localStorage.saveCategory(newCategory.toJson());
        return true;
      } else if (response['success'] == true && response.containsKey('category')) {
        final newCategory = Category.fromJson(response['category']);
        _categories.add(newCategory);
        await _localStorage.saveCategory(newCategory.toJson());
        return true;
      } else {
        _errorMessage = response['message'] ?? '添加分类失败';
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

  /// 获取位置列表
  /// [familyId] 家庭ID
  /// 从服务器获取位置列表，并保存到本地存储
  /// 若网络请求失败，尝试从本地获取
  Future<void> getLocations(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getLocations(familyId);
      _locations = List<Location>.from(
        response.map((item) => Location.fromJson(Map<String, dynamic>.from(item)))
      );
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

  /// 添加位置
  /// [name] 位置名称
  /// [familyId] 家庭ID
  /// [description] 位置描述（可选）
  /// [parent] 父位置ID（可选）
  /// 返回添加是否成功
  Future<bool> addLocation(String name, int familyId, {String? description, int? parent}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.addLocation(name, familyId, description: description, parent: parent);
      // 检查响应是否直接包含位置数据
      if (response.containsKey('id') && response.containsKey('name')) {
        final newLocation = Location.fromJson(response);
        _locations.add(newLocation);
        await _localStorage.saveLocation(newLocation.toJson());
        return true;
      } else if (response['success'] == true && response.containsKey('location')) {
        final newLocation = Location.fromJson(response['location']);
        _locations.add(newLocation);
        await _localStorage.saveLocation(newLocation.toJson());
        return true;
      } else {
        _errorMessage = response['message'] ?? '添加位置失败';
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

  /// 获取库存预警
  /// [familyId] 家庭ID
  /// 返回库存预警列表
  Future<List<dynamic>> getInventoryAlerts(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getInventoryAlerts(familyId);
      _inventoryAlerts = response;
      return response;
    } catch (e) {
      _errorMessage = '获取库存预警失败';
      print('Get inventory alerts error: $e');
      _inventoryAlerts = [];
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取库存报表
  /// [familyId] 家庭ID
  /// 返回库存报表数据
  Future<Map<String, dynamic>> getInventoryReport(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getInventoryReport(familyId);
      _inventoryReport = response;
      return response;
    } catch (e) {
      _errorMessage = '获取库存报表失败';
      print('Get inventory report error: $e');
      _inventoryReport = {};
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取采购建议
  /// [familyId] 家庭ID
  /// 返回采购建议列表
  Future<List<dynamic>> getPurchaseSuggestions(int familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getPurchaseSuggestions(familyId);
      _purchaseSuggestions = response;
      return response;
    } catch (e) {
      _errorMessage = '获取采购建议失败';
      print('Get purchase suggestions error: $e');
      _purchaseSuggestions = [];
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
