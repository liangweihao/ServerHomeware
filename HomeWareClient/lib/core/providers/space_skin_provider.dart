import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/space_skin_config.dart';
import '../models/space_type.dart';
import 'auth_provider.dart';
import 'family_provider.dart';

/// 本地缓存 key — 与当前家庭 space_type 同步
const kFamilySpaceTypePrefsKey = 'family_space_type_v1';

/// 当前空间的文案皮肤 — 优先 API，离线读 SharedPreferences
final spaceSkinProvider = Provider<SpaceSkinConfig>((ref) {
  final family = ref.watch(currentFamilyProvider).valueOrNull;
  final cached = ref.watch(_cachedSpaceTypeProvider).valueOrNull;

  final raw = family?['space_type'] as String? ?? cached;
  final type = SpaceType.parse(raw);
  debugPrint('[spaceSkinProvider] INFO: spaceType=${type.apiValue}');
  return SpaceSkinConfig.forType(type);
});

/// 当前空间类型（便于 B2+ 分支逻辑）
final currentSpaceTypeProvider = Provider<SpaceType>((ref) {
  return ref.watch(spaceSkinProvider).spaceType;
});

/// SharedPreferences 中的 space_type 缓存
final _cachedSpaceTypeProvider = FutureProvider<String?>((ref) async {
  ref.watch(authProvider);
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(kFamilySpaceTypePrefsKey);
});

/// 写入 space_type 本地缓存（创建/加入/切换家庭后调用）
Future<void> persistFamilySpaceType(String? spaceType) async {
  final prefs = await SharedPreferences.getInstance();
  final normalized = SpaceType.parse(spaceType).apiValue;
  await prefs.setString(kFamilySpaceTypePrefsKey, normalized);
  debugPrint('[spaceSkinProvider] INFO: 缓存 space_type=$normalized');
}
