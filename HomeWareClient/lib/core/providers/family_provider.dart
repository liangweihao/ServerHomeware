import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';
import 'auth_provider.dart';

/// 当前选中家庭信息 Provider（首页标题、个人中心等复用）
final currentFamilyProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;
  if (userId == null || userId.isEmpty) {
    _log('WARN: 无用户 ID，跳过获取当前家庭');
    return null;
  }

  final familyService = FamilyService();
  final result = await familyService.getCurrentFamily(userId: userId);

  if (result.code == 200) {
    _log('INFO: 当前家庭 - ${result.data?['name']}');
    return result.data;
  }

  _log('WARN: 获取当前家庭失败 - code=${result.code}, message=${result.message}');
  return null;
});

void _log(String message) {
  debugPrint('[CurrentFamilyProvider] $message');
}
