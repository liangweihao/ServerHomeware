

/// API错误模型，用于统一处理API错误响应
class ApiError {
  /// HTTP状态码
  final int statusCode;
  /// 错误消息
  final String message;

  /// 构造函数
  ApiError({
    required this.statusCode,
    required this.message,
  });
}

/// API异常类，用于抛出API错误
class ApiException implements Exception {
  /// API错误信息
  final ApiError error;

  /// 构造函数
  ApiException(this.error);

  @override
  String toString() {
    return 'ApiException: ${error.statusCode} - ${error.message}';
  }
}
