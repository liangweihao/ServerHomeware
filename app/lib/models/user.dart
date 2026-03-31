/// 用户模型类，用于表示系统中的用户信息
class User {
  /// 用户唯一标识符
  final int id;
  /// 用户名
  final String username;
  /// 邮箱地址
  final String email;
  /// 电话号码（可选）
  final String? phone;
  /// 头像URL（可选）
  final String? avatar;
  /// 是否验证
  final bool isVerified;
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatar,
    required this.isVerified,
    required this.createdAt,
  });

  /// 从JSON数据创建User实例
  /// [json] JSON格式的用户数据
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'] as String? ,
      avatar: json['avatar'] as String? ,
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 将User实例转换为JSON格式
  /// 返回JSON格式的用户数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
