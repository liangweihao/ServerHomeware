/// 家庭模型类，用于表示系统中的家庭信息
class Family {
  /// 家庭唯一标识符
  final int id;
  /// 家庭名称
  final String name;
  /// 邀请码
  final String inviteCode;
  /// 创建者ID
  final int createdBy;
  /// 创建者用户名
  final String createdByUsername;
  /// 家庭成员列表
  final List<FamilyMember> members;
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdByUsername,
    required this.members,
    required this.createdAt,
  });

  /// 从JSON数据创建Family实例
  /// [json] JSON格式的家庭数据
  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'],
      name: json['name'],
      inviteCode: json['invite_code'] ?? '',
      createdBy: json['created_by'],
      createdByUsername: json['created_by_username'] ?? '',
      members: json['members'] != null
          ? List<FamilyMember>.from(
              (json['members'] as List).map((e) => FamilyMember.fromJson(e)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 将Family实例转换为JSON格式
  /// 返回JSON格式的家庭数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'created_by_username': createdByUsername,
      'members': members.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 家庭成员模型类，用于表示家庭中的成员信息
class FamilyMember {
  /// 成员唯一标识符
  final int id;
  /// 成员用户名
  final String username;
  /// 成员邮箱
  final String email;
  /// 成员角色
  final String role;
  /// 加入时间
  final DateTime joinedAt;

  /// 构造函数
  FamilyMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  /// 从JSON数据创建FamilyMember实例
  /// [json] JSON格式的成员数据
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  /// 将FamilyMember实例转换为JSON格式
  /// 返回JSON格式的成员数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
