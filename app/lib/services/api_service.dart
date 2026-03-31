import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/models/api_error.dart';

/// API服务类，用于处理与后端服务器的所有通信
class ApiService {
  /// API基础URL
  static const String baseUrl = 'http://localhost:8000/api';
  /// Dio实例，用于发送HTTP请求
  late Dio _dio;
  /// 全局导航键，用于处理401错误时的导航
  static GlobalKey<NavigatorState>? navigatorKey;

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
        print('API Request: ${options.method} ${options.uri} ${options.headers}');
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
        
        // 处理401错误（未授权）
        if (e.response?.statusCode == 401) {
          // 清除本地存储的token
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('token');
          });
          
          // 跳转到登录页面
          if (navigatorKey?.currentState != null) {
            navigatorKey?.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          }
        }
        
        return handler.next(e);
      },
    ));
  }
  
  /// 设置全局导航键
  /// [key] 全局导航键
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// 认证相关方法
  
  /// 用户注册
  /// [username] 用户名
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回注册结果，包含用户信息和token
  /// 异常：当注册失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      print('开始注册，用户名: $username, 邮箱: $email');
      
      final response = await _dio.post('/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('注册成功，获取到用户信息和token');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('注册异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 用户登录
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回登录结果，包含用户信息和token
  /// 异常：当登录失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('开始登录，邮箱: $email');
      
      final response = await _dio.post('/login/', data: {
        'email': email,
        'password': password,
      });
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('登录成功，获取到用户信息和token');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('登录异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 用户相关方法
  
  /// 获取用户个人资料
  /// 返回用户个人资料信息
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('开始获取用户个人资料');
      
      final response = await _dio.get('/profile/');
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取用户个人资料成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('获取用户个人资料异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 更新用户个人资料
  /// [data] 要更新的用户资料数据
  /// 返回更新后的用户资料信息
  /// 异常：当更新失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      print('开始更新用户个人资料');
      
      final response = await _dio.put('/profile/update/', data: data);
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('更新用户个人资料成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('更新用户个人资料异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 家庭相关方法
  
  /// 创建新家庭
  /// [name] 家庭名称
  /// 返回创建的家庭信息
  /// 异常：当创建失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> createFamily(String name) async {
    try {
      print('开始创建新家庭，名称: $name');
      
      final response = await _dio.post('/families/', data: {'name': name});
      
      // 检查响应状态码
      if (response.statusCode != 201 && response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('创建家庭成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('创建家庭异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取用户的家庭列表
  /// 返回家庭列表数据
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getFamilies() async {
    try {
      print('开始获取用户的家庭列表');
      
      final response = await _dio.get('/families/');
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取家庭列表成功');
      return _extractPaginatedResults(response.data);
    } catch (e) {
      print('获取家庭列表异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取家庭详情
  /// [id] 家庭ID
  /// 返回家庭详细信息
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> getFamilyDetail(int id) async {
    try {
      print('开始获取家庭详情，ID: $id');
      
      final response = await _dio.get('/families/$id/');
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取家庭详情成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('获取家庭详情异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 加入家庭
  /// [id] 家庭ID
  /// 返回加入结果
  /// 异常：当加入失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> joinFamily(int id) async {
    try {
      print('开始加入家庭，ID: $id');
      
      final response = await _dio.post('/families/$id/join/', data: {});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('加入家庭成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('加入家庭异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 物品相关方法
  
  /// 添加新物品
  /// [data] 物品数据
  /// 返回创建的物品信息
  /// 异常：当添加失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> addItem(Map<String, dynamic> data) async {
    try {
      print('开始添加新物品');
      
      final response = await _dio.post('/items/', data: data);
      
      // 检查响应状态码
      if (response.statusCode != 201 && response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('添加物品成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('添加物品异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取物品列表
  /// [familyId] 家庭ID（可选）
  /// 返回物品列表数据
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getItems({int? familyId}) async {
    try {
      print('开始获取物品列表，家庭ID: $familyId');
      
      final params = familyId != null ? <String, dynamic>{'family_id': familyId} : <String, dynamic>{};
      final response = await _dio.get('/items/', queryParameters: params);
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取物品列表成功');
      return _extractPaginatedResults(response.data);
    } catch (e) {
      print('获取物品列表异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取物品详情
  /// [id] 物品ID
  /// 返回物品详细信息
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> getItemDetail(int id) async {
    try {
      print('开始获取物品详情，ID: $id');
      
      final response = await _dio.get('/items/$id/');
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取物品详情成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('获取物品详情异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 更新物品信息
  /// [id] 物品ID
  /// [data] 要更新的物品数据
  /// 返回更新后的物品信息
  /// 异常：当更新失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> updateItem(int id, Map<String, dynamic> data) async {
    try {
      print('开始更新物品信息，ID: $id');
      
      final response = await _dio.put('/items/$id/', data: data);
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('更新物品信息成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('更新物品信息异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 删除物品
  /// [id] 物品ID
  /// 异常：当删除失败时抛出ApiException异常，包含错误信息
  Future<void> deleteItem(int id) async {
    try {
      print('开始删除物品，ID: $id');
      
      final response = await _dio.delete('/items/$id/');
      
      // 检查响应状态码
      if (response.statusCode != 204 && response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('删除物品成功');
    } catch (e) {
      print('删除物品异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 分类相关方法
  
  /// 添加新分类
  /// [name] 分类名称
  /// [familyId] 家庭ID
  /// 返回创建的分类信息
  /// 异常：当添加失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> addCategory(String name, int familyId) async {
    try {
      print('开始添加新分类，名称: $name, 家庭ID: $familyId');
      
      final response = await _dio.post('/categories/', data: {
        'name': name,
        'family_id': familyId,
      });
      
      // 检查响应状态码
      if (response.statusCode != 201 && response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('添加分类成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('添加分类异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取分类列表
  /// [familyId] 家庭ID
  /// 返回分类列表数据
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getCategories(int familyId) async {
    try {
      print('开始获取分类列表，家庭ID: $familyId');
      
      final response = await _dio.get('/categories/', queryParameters: {'family_id': familyId});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取分类列表成功');
      // 根据API文档，返回的是直接的列表数据，不需要提取分页结果
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        return List<dynamic>.from(response.data['results']);
      }
      return [];
    } catch (e) {
      print('获取分类列表异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 位置相关方法
  
  /// 添加新位置
  /// [name] 位置名称
  /// [familyId] 家庭ID
  /// [description] 位置描述（可选）
  /// 返回创建的位置信息
  /// 异常：当添加失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> addLocation(String name, int familyId, {String? description}) async {
    try {
      print('开始添加新位置，名称: $name, 家庭ID: $familyId');
      
      final response = await _dio.post('/locations/', data: {
        'name': name,
        'family_id': familyId,
        'description': description,
      });
      
      // 检查响应状态码
      if (response.statusCode != 201 && response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('添加位置成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('添加位置异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取位置列表
  /// [familyId] 家庭ID
  /// 返回位置列表数据
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getLocations(int familyId) async {
    try {
      print('开始获取位置列表，家庭ID: $familyId');
      
      final response = await _dio.get('/locations/', queryParameters: {'family_id': familyId});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取位置列表成功');
      return _extractPaginatedResults(response.data);
    } catch (e) {
      print('获取位置列表异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 库存相关方法
  
  /// 获取库存预警
  /// [familyId] 家庭ID
  /// 返回库存预警列表
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getInventoryAlerts(int familyId) async {
    try {
      print('开始获取库存预警，家庭ID: $familyId');
      
      final response = await _dio.get('/inventory/alert/', queryParameters: {'family_id': familyId});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取库存预警成功');
      return List<dynamic>.from(response.data);
    } catch (e) {
      print('获取库存预警异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取库存报表
  /// [familyId] 家庭ID
  /// 返回库存报表数据
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<Map<String, dynamic>> getInventoryReport(int familyId) async {
    try {
      print('开始获取库存报表，家庭ID: $familyId');
      
      final response = await _dio.get('/inventory/report/', queryParameters: {'family_id': familyId});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取库存报表成功');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('获取库存报表异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
  }

  /// 获取采购建议
  /// [familyId] 家庭ID
  /// 返回采购建议列表
  /// 异常：当获取失败时抛出ApiException异常，包含错误信息
  Future<List<dynamic>> getPurchaseSuggestions(int familyId) async {
    try {
      print('开始获取采购建议，家庭ID: $familyId');
      
      final response = await _dio.get('/inventory/suggestions/', queryParameters: {'family_id': familyId});
      
      // 检查响应状态码
      if (response.statusCode != 200) {
        // 尝试获取响应数据，处理不同格式的错误响应
        dynamic responseData = response.data;
        String errorMessage = '请求失败';
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        final apiError = ApiError(
          statusCode: response.statusCode!,
          message: errorMessage.isNotEmpty ? errorMessage : '请求失败',
        );
        throw ApiException(apiError);
      }
      
      print('获取采购建议成功');
      return _extractPaginatedResults(response.data);
    } catch (e) {
      print('获取采购建议异常: $e');
      if (e is ApiException) {
        rethrow;
      }
      // 网络异常或其他异常
      final apiError = ApiError(
        statusCode: 0,
        message: '网络连接失败，请检查网络设置',
      );
      throw ApiException(apiError);
    }
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
