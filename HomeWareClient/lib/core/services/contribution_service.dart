import '../services/auth_service.dart';

/// 贡献度服务
class ContributionService {
  static const _delay = Duration(milliseconds: 300);

  /// 获取用户贡献数据
  Future<ApiResponse<Map<String, dynamic>>> getUserContribution({
    required String userId,
  }) async {
    await _delay;

    // 模拟数据
    final contribution = {
      'user_id': userId,
      'monthly_input': 18, // 本月录入物品数
      'monthly_consumption': 32, // 本月消耗记录数
      'total_input': 156, // 累计录入
      'total_consumption': 234, // 累计消耗
      'family_total': 254, // 全家本月操作总数
      'contribution_rate': 0.62, // 贡献度比例
      'rank': 1, // 家庭内排名
      'encouragement': '本月你比上月多录入了5件 👍',
    };

    return ApiResponse<Map<String, dynamic>>(
      code: 200,
      message: 'success',
      data: contribution,
    );
  }
}
