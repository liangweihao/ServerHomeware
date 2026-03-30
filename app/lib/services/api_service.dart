import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) {
        print('API Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // 认证相关
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data);
  }

  // 用户相关
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _dio.get('/users/profile');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/users/profile', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  // 家庭相关
  Future<Map<String, dynamic>> createFamily(String name) async {
    final response = await _dio.post('/families', data: {'name': name});
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getFamilies() async {
    final response = await _dio.get('/families');
    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getFamilyDetail(int id) async {
    final response = await _dio.get('/families/$id');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> joinFamily(int id) async {
    final response = await _dio.post('/families/$id/join');
    return Map<String, dynamic>.from(response.data);
  }

  // 物品相关
  Future<Map<String, dynamic>> addItem(Map<String, dynamic> data) async {
    final response = await _dio.post('/items', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getItems({int? familyId}) async {
    final params = familyId != null ? <String, dynamic>{'family_id': familyId} : <String, dynamic>{};
    final response = await _dio.get('/items', queryParameters: params);
    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getItemDetail(int id) async {
    final response = await _dio.get('/items/$id');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateItem(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/items/$id', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItem(int id) async {
    await _dio.delete('/items/$id');
  }

  // 分类相关
  Future<Map<String, dynamic>> addCategory(String name, int familyId) async {
    final response = await _dio.post('/categories', data: {
      'name': name,
      'family_id': familyId,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getCategories(int familyId) async {
    final response = await _dio.get('/categories', queryParameters: {'family_id': familyId});
    return List<dynamic>.from(response.data);
  }

  // 位置相关
  Future<Map<String, dynamic>> addLocation(String name, int familyId, {String? description}) async {
    final response = await _dio.post('/locations', data: {
      'name': name,
      'family_id': familyId,
      'description': description,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getLocations(int familyId) async {
    final response = await _dio.get('/locations', queryParameters: {'family_id': familyId});
    return List<dynamic>.from(response.data);
  }

  // 库存相关
  Future<List<dynamic>> getInventoryAlerts(int familyId) async {
    final response = await _dio.get('/inventory/alert', queryParameters: {'family_id': familyId});
    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getInventoryReport(int familyId) async {
    final response = await _dio.get('/inventory/report', queryParameters: {'family_id': familyId});
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getPurchaseSuggestions(int familyId) async {
    final response = await _dio.get('/inventory/suggestions', queryParameters: {'family_id': familyId});
    return List<dynamic>.from(response.data);
  }
}
