/// 应用运行环境配置（通过 --dart-define 注入）
///
/// 示例：
/// ```bash
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
/// ```
class AppEnv {
  /// 后端 API 根地址，需包含 `/api/v1` 前缀
  static const String apiBaseUrl = String.fromEnvironment(
    'http://192.168.1.98:8000/api/v1',
    defaultValue: 'http://192.168.1.98:8000/api/v1',
  );

  static String get _normalizedBase {
    final base = apiBaseUrl.trim();
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  /// 拼接 API 路径，[path] 需以 `/` 开头
  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_normalizedBase$normalizedPath');
  }

  /// 服务端根地址（不含 `/api/v1`），用于静态资源如 `/uploads/...`
  static String get serverOrigin {
    final uri = Uri.parse(_normalizedBase);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  /// 将上传接口返回的相对路径转为可访问的完整 URL
  static String resolveUploadUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$serverOrigin$normalized';
  }
}
