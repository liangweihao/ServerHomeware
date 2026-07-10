/// 应用运行环境配置（通过 --dart-define 注入）
///
/// 示例（本地开发）：
/// ```bash
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
/// ```
///
/// 示例（生产环境，API 和静态资源分离）：
/// ```bash
/// flutter run \
///   --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
///   --dart-define=STATIC_BASE_URL=https://oss.example.com
/// ```
class AppEnv {
  /// 后端 API 根地址，需包含 `/api/v1` 前缀
  /// // 正式服环境 82.156.91.220
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.98:8000/api/v1',
  );

  /// 静态资源根地址（图片、上传文件等），默认从 apiBaseUrl 推导
  /// 生产环境可指向独立 OSS/CDN
  static const String _staticBaseUrl = String.fromEnvironment(
    'STATIC_BASE_URL',
    defaultValue: '',
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

  /// 静态资源根地址：优先用 STATIC_BASE_URL，否则从 API_BASE_URL 推导
  static String get staticBaseUrl {
    if (_staticBaseUrl.isNotEmpty) {
      final base = _staticBaseUrl.trim();
      return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    }
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
    return '$staticBaseUrl$normalized';
  }

  /// WebSocket 实时通知地址（`/ws/notifications`）
  static Uri wsNotificationsUri(String token) {
    final apiUri = Uri.parse(_normalizedBase);
    final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: wsScheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: '${apiUri.path}/ws/notifications',
      queryParameters: {'token': token},
    );
  }
}
