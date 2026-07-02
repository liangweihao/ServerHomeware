import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/family_contribution_provider.dart';
import 'member_contribution_detail_body.dart';

/// 打开成员贡献详情 BottomSheet（快速预览）
void showMemberContributionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  FamilyMemberContribution member, {
  int? familyTotalActions,
}) {
  debugPrint('[MemberContributionDetail] INFO: Sheet 预览 ${member.name}');
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return MemberContributionDetailBody(
          member: member,
          familyTotalActions: familyTotalActions,
          scrollController: scrollController,
          isSheet: true,
        );
      },
    ),
  );
}
