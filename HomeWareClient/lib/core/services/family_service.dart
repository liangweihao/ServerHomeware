import 'dart:math';
import '../services/auth_service.dart';

/// 家庭信息服务
class FamilyService {
  static const _delay = Duration(milliseconds: 500);

  /// 获取当前家庭信息
  Future<ApiResponse<Map<String, dynamic>>> getCurrentFamily({
    required String userId,
  }) async {
    await _delay;

    // 模拟数据
    final family = {
      'id': _generateId(),
      'name': '温馨小窝',
      'invite_code': _generateInviteCode(),
      'owner_id': userId,
      'members': [
        {'id': userId, 'name': '妈妈', 'role': 'admin', 'avatar': null},
        {'id': _generateId(), 'name': '爸爸', 'role': 'member', 'avatar': null},
        {'id': _generateId(), 'name': '小明', 'role': 'member', 'avatar': null},
      ],
      'item_count': 95,
      'created_at': DateTime.now().toIso8601String(),
    };

    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: family,
    );
  }

  /// 获取邀请码
  Future<ApiResponse<Map<String, dynamic>>> getInviteCode({
    required String familyId,
  }) async {
    await _delay;

    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'invite_code': _generateInviteCode(),
        'expire_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      },
    );
  }

  /// 刷新邀请码
  Future<ApiResponse<Map<String, dynamic>>> refreshInviteCode({
    required String familyId,
  }) async {
    await _delay;

    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: {
        'invite_code': _generateInviteCode(),
        'expire_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      },
    );
  }

  /// 生成邀请码
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// 生成ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
