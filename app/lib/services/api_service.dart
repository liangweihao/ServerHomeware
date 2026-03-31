import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API服务类，用于处理与后端服务器的所有通信
class ApiService {
  /// API基础URL
  static const String baseUrl = 'http://localhost:8000/api';
  /// Dio实例，用于发送HTTP请求
  late Dio _dio;

  /// 构造函数，初始化Dio实例和拦截器
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从本地存储获取token并添加到请求头
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // 打印请求信息
        print('API Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 打印响应信息
        print('API Response: ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        // 打印错误信息
        print('API Error: ${e.message}');
        print('Error Response: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  /// 认证相关方法
  
  /// 用户注册
  /// [username] 用户名
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回注册结果，包含用户信息和token
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _dio.post('/register/', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data);
  }

  /// 用户登录
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回登录结果，包含用户信息和token
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/login/', data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data);
  }

  /// 用户相关方法
  
  /// 获取用户个人资料
  /// 返回用户个人资料信息
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _dio.get('/profile/');
    return Map<String, dynamic>.from(response.data);
  }

  /// 更新用户个人资料
  /// [data] 要更新的用户资料数据
  /// 返回更新后的用户资料信息
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/profile/update/', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  /// 家庭相关方法
  
  /// 创建新家庭
  /// [name] 家庭名称
  /// 返回创建的家庭信息
  Future<Map<String, dynamic>> createFamily(String name) async {
    final response = await _dio.post('/families/', data: {'name': name});
    return Map<String, dynamic>.from(response.data);
  }

  /// 获取用户的家庭列表
  /// 返回家庭列表数据
  Future<List<dynamic>> getFamilies() async {
    final response = await _dio.get('/families/');
    return _extractPaginatedResults(response.data);
  }

  /// 获取家庭详情
  /// [id] 家庭ID
  /// 返回家庭详细信息
  Future<Map<String, dynamic>> getFamilyDetail(int id) async {
    final response = await _dio.get('/families/$id/');
    return Map<String, dynamic>.from(response.data);
  }

  /// 加入家庭
  /// [id] 家庭ID
  /// 返回加入结果
  Future<Map<String, dynamic>> joinFamily(int id) async {
    final response = await _dio.post('/families/$id/join/', data: {});
    return Map<String, dynamic>.from(response.data);
  }

  /// 物品相关方法
  
  /// 添加新物品
  /// [data] 物品数据
  /// 返回创建的物品信息
  Future<Map<String, dynamic>> addItem(Map<String, dynamic> data) async {
    final response = await _dio.post('/items/', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  /// 获取物品列表
  /// [familyId] 家庭ID（可选）
  /// 返回物品列表数据
  Future<List<dynamic>> getItems({int? familyId}) async {
    final params = familyId != null ? <String, dynamic>{'family_id': familyId} : <String, dynamic>{};
    final response = await _dio.get('/items/', queryParameters: params);
    return _extractPaginatedResults(response.data);
  }

  /// 获取物品详情
  /// [id] 物品ID
  /// 返回物品详细信息
  Future<Map<String, dynamic>> getItemDetail(int id) async {
    final response = await _dio.get('/items/$id/');
    return Map<String, dynamic>.from(response.data);
  }

  /// 更新物品信息
  /// [id] 物品ID
  /// [data] 要更新的物品数据
  /// 返回更新后的物品信息
  Future<Map<String, dynamic>> updateItem(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/items/$id/', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  /// 删除物品
  /// [id] 物品ID
  Future<void> deleteItem(int id) async {
    await _dio.delete('/items/$id/');
  }

  /// 分类相关方法
  
  /// 添加新分类
  /// [name] 分类名称
  /// [familyId] 家庭ID
  /// 返回创建的分类信息
  Future<Map<String, dynamic>> addCategory(String name, int familyId) async {
    final response = await _dio.post('/categories/', data: {
      'name': name,
      'family_id': familyId,
    });
    return Map<String, dynamic>.from(response.data);
  }

  /// 获取分类列表
  /// [familyId] 家庭ID
  /// 返回分类列表数据
  Future<List<dynamic>> getCategories(int familyId) async {
    final response = await _dio.get('/categories/', queryParameters: {'family_id': familyId});
    return _extractPaginatedResults(response.data);
  }

  /// 位置相关方法
  
  /// 添加新位置
  /// [name] 位置名称
  /// [familyId] 家庭ID
  /// [description] 位置描述（可选）
  /// 返回创建的位置信息
  Future<Map<String, dynamic>> addLocation(String name, int familyId, {String? description}) async {
    final response = await _dio.post('/locations/', data: {
      'name': name,
      'family_id': familyId,
      'description': description,
    });
    return Map<String, dynamic>.from(response.data);
  }

  /// 获取位置列表
  /// [familyId] 家庭ID
  /// 返回位置列表数据
  Future<List<dynamic>> getLocations(int familyId) async {
    final response = await _dio.get('/locations/', queryParameters: {'family_id': familyId});
    return _extractPaginatedResults(response.data);
  }

  /// 库存相关方法
  
  /// 获取库存预警
  /// [familyId] 家庭ID
  /// 返回库存预警列表
  Future<List<dynamic>> getInventoryAlerts(int familyId) async {
    final response = await _dio.get('/inventory/alert/', queryParameters: {'family_id': familyId});
    return List<dynamic>.from(response.data);
  }

  /// 获取库存报表
  /// [familyId] 家庭ID
  /// 返回库存报表数据
  Future<Map<String, dynamic>> getInventoryReport(int familyId) async {
    final response = await _dio.get('/inventory/report/', queryParameters: {'family_id': familyId});
    return Map<String, dynamic>.from(response.data);
  }

  /// 获取采购建议
  /// [familyId] 家庭ID
  /// 返回采购建议列表
  Future<List<dynamic>> getPurchaseSuggestions(int familyId) async {
    final response = await _dio.get('/inventory/suggestions/', queryParameters: {'family_id': familyId});
    return _extractPaginatedResults(response.data);
  }

  /// 提取分页结果
  /// [data] API响应数据
  /// 返回提取的结果列表
  List<dynamic> _extractPaginatedResults(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      return List<dynamic>.from(data['results']);
    }
    if (data is List) {
      return data;
    }
    return [];
  }
}
