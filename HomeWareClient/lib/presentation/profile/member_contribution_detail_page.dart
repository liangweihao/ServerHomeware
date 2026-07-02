import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/family_contribution_provider.dart';
import '../common/widgets/warm_scaffold.dart';
import 'widgets/member_contribution_detail_body.dart';

/// 成员贡献详情独立页
class MemberContributionDetailPage extends ConsumerWidget {
  const MemberContributionDetailPage({
    super.key,
    required this.member,
    this.familyTotalActions,
  });

  final FamilyMemberContribution member;
  final int? familyTotalActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WarmScaffold(
      title: member.name,
      body: MemberContributionDetailBody(
        member: member,
        familyTotalActions: familyTotalActions,
      ),
    );
  }
}
