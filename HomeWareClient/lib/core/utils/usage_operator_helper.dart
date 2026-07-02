import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// 解析当前登录用户作为操作人名称（家庭贡献 / usage 同步）
String? resolveUsageOperatorName(WidgetRef ref) {
  final user = ref.read(currentUserProvider);
  final nickname = user?.nickname?.trim();
  if (nickname != null && nickname.isNotEmpty) return nickname;
  final phone = user?.phone.trim();
  if (phone != null && phone.isNotEmpty) return phone;
  return null;
}

/// 当前用户 ID（服务端 operator_id 由 token 解析，本地仅作日志）
String? resolveUsageOperatorUserId(WidgetRef ref) {
  return ref.read(currentUserProvider)?.id;
}
