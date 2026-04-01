/// 物品模型类，用于表示系统中的物品信息
class Item {
  /// 物品唯一标识符
  final int id;
  /// 物品名称
  final String name;
  /// 物品描述（可选）
  final String? description;
  /// 分类ID
  final int categoryId;
  /// 位置ID
  final int locationId;
  /// 数量
  final int quantity;
  /// 单位
  final String unit;
  /// 过期日期（可选）
  final DateTime? expiryDate;
  /// 购买日期（可选）
  final DateTime? purchaseDate;
  /// 价格（可选）
  final double? price;
  /// 家庭ID
  final int familyId;
  /// 创建者ID
  final int createdBy;
  /// 创建时间
  final DateTime createdAt;
  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  Item({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    required this.locationId,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.purchaseDate,
    this.price,
    required this.familyId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON数据创建Item实例
  /// [json] JSON格式的物品数据
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      locationId: json['location_id'],
      quantity: json['quantity'],
      unit: json['unit'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date']) : null,
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      familyId: json['family_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// 将Item实例转换为JSON格式
  /// 返回JSON格式的物品数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'location_id': locationId,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'purchase_date': purchaseDate?.toIso8601String(),
      'price': price,
      'family_id': familyId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 分类模型类，用于表示物品的分类信息
class Category {
  /// 分类唯一标识符
  final int id;
  /// 分类名称
  final String name;
  /// 分类图标（可选）
  final String? icon;
  /// 分类颜色（可选）
  final String? color;
  /// 家庭ID
  final int familyId;
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.familyId,
    required this.createdAt,
  });

  /// 从JSON数据创建Category实例
  /// [json] JSON格式的分类数据
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      familyId: json['family_id'] ?? json['family'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 将Category实例转换为JSON格式
  /// 返回JSON格式的分类数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 位置模型类，用于表示物品的存放位置信息
class Location {
  /// 位置唯一标识符
  final int id;
  /// 位置名称
  final String name;
  /// 位置描述（可选）
  final String? description;
  /// 父位置ID（可选）
  final int? parent;
  /// 父位置名称（可选）
  final String? parentName;
  /// 家庭ID
  final int familyId;
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  Location({
    required this.id,
    required this.name,
    this.description,
    this.parent,
    this.parentName,
    required this.familyId,
    required this.createdAt,
  });

  /// 从JSON数据创建Location实例
  /// [json] JSON格式的位置数据
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parent: json['parent'],
      parentName: json['parent_name'],
      familyId: json['family_id'] ?? json['family'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 将Location实例转换为JSON格式
  /// 返回JSON格式的位置数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent': parent,
      'parent_name': parentName,
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
