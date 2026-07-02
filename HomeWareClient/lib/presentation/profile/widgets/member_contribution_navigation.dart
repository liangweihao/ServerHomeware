import 'package:flutter/foundation.dart' show debugPrint;
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../providers/family_contribution_provider.dart';

/// 跳转成员贡献详情独立页
void openMemberContributionDetail(
  BuildContext context,
  FamilyMemberContribution member, {
  int? familyTotalActions,
}) {
  debugPrint('[MemberContributionNav] INFO: 打开详情 ${member.name}');
  final query = <String, String>{
    'name': member.name,
    'record': '${member.recordCount}',
    'consume': '${member.consumeCount}',
  };
  if (member.rank != null) query['rank'] = '${member.rank}';
  if (member.userId != null) query['userId'] = '${member.userId}';
  if (familyTotalActions != null) query['total'] = '$familyTotalActions';

  context.push(Uri(path: '/profile/family/member', queryParameters: query).toString());
}

/// 从路由 query 解析成员模型
FamilyMemberContribution memberContributionFromQuery(
  Map<String, String> query,
) {
  return FamilyMemberContribution(
    name: query['name'] ?? '未署名',
    recordCount: int.tryParse(query['record'] ?? '') ?? 0,
    consumeCount: int.tryParse(query['consume'] ?? '') ?? 0,
    rank: int.tryParse(query['rank'] ?? ''),
    userId: int.tryParse(query['userId'] ?? ''),
  );
}

int? familyTotalActionsFromQuery(Map<String, String> query) {
  return int.tryParse(query['total'] ?? '');
}
