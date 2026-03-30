class Item {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final int locationId;
  final int quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final double? price;
  final int familyId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

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

class Category {
  final int id;
  final String name;
  final int familyId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.familyId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      familyId: json['family_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Location {
  final int id;
  final String name;
  final String? description;
  final int familyId;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.name,
    this.description,
    required this.familyId,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      familyId: json['family_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
