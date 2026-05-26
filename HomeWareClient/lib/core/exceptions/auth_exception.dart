/// 认证相关异常
class AuthException implements Exception {
  final String message;
  final AuthExceptionType type;

  AuthException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'AuthException(type: $type, message: $message)';
}

/// 认证异常类型
enum AuthExceptionType {
  tokenExpired,
  tokenInvalid,
  unauthorized,
}

/// 检查响应是否为认证错误
bool isAuthError(int code) {
  return code == 401 || code == 403;
}

/// 从响应码获取认证异常类型
AuthExceptionType getAuthExceptionType(int code) {
  switch (code) {
    case 401:
      return AuthExceptionType.tokenInvalid;
    case 403:
      return AuthExceptionType.unauthorized;
    default:
      return AuthExceptionType.tokenInvalid;
  }
}