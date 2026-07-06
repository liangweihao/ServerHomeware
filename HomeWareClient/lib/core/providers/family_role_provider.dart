import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// 当前用户在当前家庭的角色（SharedPreferences 缓存）
final familyRoleProvider = Provider<String?>((ref) {
  ref.watch(authProvider);
  return ref.read(authProvider.notifier).currentUser?.familyRole;
});
