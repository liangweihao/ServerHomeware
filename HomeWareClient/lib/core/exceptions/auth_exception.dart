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

/// 检查响应是否为认证错误（仅 HTTP 状态码，含业务类 401）
bool isAuthError(int code) {
  return code == 401 || code == 403;
}

/// 401/403 中属于业务状态、不应触发全局退出登录的 message
const Set<String> sessionLogoutBypassMessages = {
  '用户未加入任何家庭',
};

/// 是否应触发全局退出登录（token 失效等），排除「未加入家庭」等业务态
bool shouldTriggerSessionLogout(int code, String message) {
  if (!isAuthError(code)) return false;
  if (sessionLogoutBypassMessages.contains(message)) return false;
  return true;
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