import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import '../config/app_env.dart';
import '../exceptions/auth_exception.dart';

/// 物品信息服务
class ItemService {
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const _keyToken = 'auth_token';

  /// 创建物品
  /// 调用服务端 POST /api/v1/items 接口
  Future<ApiResponse<Map<String, dynamic>>> createItem({
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 POST /api/v1/items');
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 创建物品失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '创建物品失败: $e',
      );
    }
  }

  /// 更新物品
  /// 调用服务端 PUT /api/v1/items/{id} 接口
  Future<ApiResponse<Map<String, dynamic>>> updateItem({
    required int itemId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 PUT /api/v1/items/$itemId');
      final response = await http.put(
        Uri.parse('$_baseUrl/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 更新物品失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '更新物品失败: $e',
      );
    }
  }

  /// 删除物品
  /// 调用服务端 DELETE /api/v1/items/{id} 接口
  Future<ApiResponse<Map<String, dynamic>>> deleteItem({
    required int itemId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(code: 401, message: '未登录');
      }

      _log('INFO: 调用 DELETE /api/v1/items/$itemId');
      final response = await http.delete(
        Uri.parse('$_baseUrl/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 删除物品失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '删除物品失败: $e',
      );
    }
  }

  /// 获取物品列表（分页 + 筛选 + 排序）
  /// 调用服务端 GET /api/v1/items 接口
  Future<ApiResponse<Map<String, dynamic>>> getItems({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? sortBy,
    String? sortOrder,
    int? expiringWithinDays,
    bool? lowStock,
    String? keyword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(code: 401, message: '未登录');
      }

      final query = <String, String>{
        'page': '$page',
        'page_size': '$pageSize',
      };
      if (status != null) query['status'] = '$status';
      if (sortBy != null) query['sort_by'] = sortBy;
      if (sortOrder != null) query['sort_order'] = sortOrder;
      if (expiringWithinDays != null) {
        query['expiring_within_days'] = '$expiringWithinDays';
      }
      if (lowStock == true) query['low_stock'] = 'true';
      if (keyword != null && keyword.isNotEmpty) query['keyword'] = keyword;

      final uri = Uri.parse('$_baseUrl/items').replace(queryParameters: query);
      _log('INFO: 调用 GET $uri');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取物品列表失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取物品列表失败: $e',
      );
    }
  }

  /// 获取全部服务端物品（自动翻页，用于同步）
  Future<List<Map<String, dynamic>>> getAllItemsFromServer() async {
    final allItems = <Map<String, dynamic>>[];
    int page = 1;
    const pageSize = 100;

    while (true) {
      final result = await getItems(page: page, pageSize: pageSize);
      if (result.code != 200 || result.data == null) {
        _log('WARN: 获取第 $page 页失败，停止翻页 code=${result.code}');
        break;
      }

      final items = result.data!['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) break;

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          allItems.add(item);
        }
      }

      final total = result.data!['total'] as int? ?? 0;
      final pages = result.data!['pages'] as int? ?? 1;
      if (page >= pages || allItems.length >= total) break;

      page++;
    }

    _log('INFO: 从服务端拉取 ${allItems.length} 件物品');
    return allItems;
  }

  /// 获取家庭使用记录（分页，用于同步到本地）
  /// 调用服务端 GET /api/v1/usage_records 接口
  Future<ApiResponse<Map<String, dynamic>>> getUsageRecords({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(code: 401, message: '未登录');
      }

      _log('INFO: 调用 GET /api/v1/usage_records?page=$page&page_size=$pageSize');
      final response = await http.get(
        Uri.parse('$_baseUrl/usage_records?page=$page&page_size=$pageSize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取使用记录失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取使用记录失败: $e',
      );
    }
  }

  /// 创建使用记录（入库/消耗/丢弃等）
  Future<ApiResponse<Map<String, dynamic>>> createUsageRecord({
    required int itemId,
    required int type,
    required double quantity,
    required double remainingQuantity,
    String? operatorName,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(code: 401, message: '未登录');
      }

      final body = <String, dynamic>{
        'item_id': itemId,
        'type': type,
        'quantity': quantity,
        'remaining_quantity': remainingQuantity,
      };
      if (operatorName != null && operatorName.isNotEmpty) {
        body['operator_name'] = operatorName;
      }
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      _log('INFO: POST usage_records itemId=$itemId type=$type qty=$quantity');
      final response = await http.post(
        Uri.parse('$_baseUrl/usage_records'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 创建使用记录失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '创建使用记录失败: $e',
      );
    }
  }

  /// 同步消耗记录到服务端（type=1）
  Future<ApiResponse<Map<String, dynamic>>> recordUsage({
    required int itemId,
    required double quantity,
    required double remainingQuantity,
    String? operatorName,
  }) {
    return createUsageRecord(
      itemId: itemId,
      type: 1,
      quantity: quantity,
      remainingQuantity: remainingQuantity,
      operatorName: operatorName,
    );
  }

  /// 获取全部使用记录（自动翻页）
  Future<List<Map<String, dynamic>>> getAllUsageRecordsFromServer() async {
    final allRecords = <Map<String, dynamic>>[];
    int page = 1;
    const pageSize = 100;

    while (true) {
      final result = await getUsageRecords(page: page, pageSize: pageSize);
      if (result.code != 200 || result.data == null) break;

      final items = result.data!['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) break;

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          allRecords.add(item);
        }
      }

      final total = result.data!['total'] as int? ?? 0;
      if (allRecords.length >= total) break;
      page++;
    }

    _log('INFO: 从服务端拉取 ${allRecords.length} 条使用记录');
    return allRecords;
  }

  /// 获取物品详情（含图片列表）
  /// 调用服务端 GET /api/v1/items/{id} 接口
  Future<ApiResponse<Map<String, dynamic>>> getItemDetail({
    required int itemId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('ERROR: 未登录');
        return ApiResponse<Map<String, dynamic>>(
          code: 401,
          message: '未登录',
        );
      }

      _log('INFO: 调用 GET /api/v1/items/$itemId');
      final response = await http.get(
        Uri.parse('$_baseUrl/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      _log('ERROR: 获取物品详情失败 - $e');
      return ApiResponse<Map<String, dynamic>>(
        code: 500,
        message: '获取物品详情失败: $e',
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final code = jsonData['code'] ?? response.statusCode;
      final message = jsonData['message'] ?? 'success';

      _log('RESPONSE: ${json.encode(jsonData)}');

      if (code != 200) {
        _log('WARN: 接口返回错误 - code: $code, message: $message');

        if (code == 401 || code == 403) {
          if (shouldTriggerSessionLogout(code, message)) {
            _log('WARN: Token无效或已过期，触发认证错误处理');
            ApiService.handleAuthError(code, message);
          } else {
            _log('INFO: 业务态 401/403，不退出登录 - $message');
          }
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        code: code,
        message: message,
        data: jsonData['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      _log('ERROR: 响应解析失败 - $e, body: ${response.body}');
      return ApiResponse<Map<String, dynamic>>(
        code: response.statusCode,
        message: '解析错误: $e',
      );
    }
  }

  /// 长日志分段输出，避免 Flutter print 行长度截断
  void _log(String message) {
    const maxLen = 960;
    final prefix = '[ItemService] ';
    if (message.length <= maxLen) {
      print('$prefix$message');
    } else {
      // 分段打印，每段标记序号
      int i = 1;
      int start = 0;
      while (start < message.length) {
        final end = start + maxLen < message.length
            ? start + maxLen
            : message.length;
        print('$prefix[$i] ${message.substring(start, end)}');
        start = end;
        i++;
      }
    }
  }
}
