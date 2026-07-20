// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    parentId,
    sortOrder,
    isSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String icon;
  final String color;
  final int? parentId;
  final int sortOrder;
  final bool isSystem;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parentId,
    required this.sortOrder,
    required this.isSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'parentId': serializer.toJson<int?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    Value<int?> parentId = const Value.absent(),
    int? sortOrder,
    bool? isSystem,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    color,
    parentId,
    sortOrder,
    isSystem,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<int?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required String color,
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon),
       color = Value(color);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? color,
    Value<int?>? parentId,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _fullPathMeta = const VerificationMeta(
    'fullPath',
  );
  @override
  late final GeneratedColumn<String> fullPath = GeneratedColumn<String>(
    'full_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    images,
    parentId,
    level,
    fullPath,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('full_path')) {
      context.handle(
        _fullPathMeta,
        fullPath.isAcceptableOrUnknown(data['full_path']!, _fullPathMeta),
      );
    } else if (isInserting) {
      context.missing(_fullPathMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      fullPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_path'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final int id;
  final String name;
  final String? icon;
  final String? images;
  final int? parentId;
  final int level;
  final String fullPath;
  final int sortOrder;
  final DateTime createdAt;
  const Location({
    required this.id,
    required this.name,
    this.icon,
    this.images,
    this.parentId,
    required this.level,
    required this.fullPath,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['level'] = Variable<int>(level);
    map['full_path'] = Variable<String>(fullPath);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      images: images == null && nullToAbsent
          ? const Value.absent()
          : Value(images),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      level: Value(level),
      fullPath: Value(fullPath),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      images: serializer.fromJson<String?>(json['images']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      level: serializer.fromJson<int>(json['level']),
      fullPath: serializer.fromJson<String>(json['fullPath']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'images': serializer.toJson<String?>(images),
      'parentId': serializer.toJson<int?>(parentId),
      'level': serializer.toJson<int>(level),
      'fullPath': serializer.toJson<String>(fullPath),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Location copyWith({
    int? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<String?> images = const Value.absent(),
    Value<int?> parentId = const Value.absent(),
    int? level,
    String? fullPath,
    int? sortOrder,
    DateTime? createdAt,
  }) => Location(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    images: images.present ? images.value : this.images,
    parentId: parentId.present ? parentId.value : this.parentId,
    level: level ?? this.level,
    fullPath: fullPath ?? this.fullPath,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      images: data.images.present ? data.images.value : this.images,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      level: data.level.present ? data.level.value : this.level,
      fullPath: data.fullPath.present ? data.fullPath.value : this.fullPath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('images: $images, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('fullPath: $fullPath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    images,
    parentId,
    level,
    fullPath,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.images == this.images &&
          other.parentId == this.parentId &&
          other.level == this.level &&
          other.fullPath == this.fullPath &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> images;
  final Value<int?> parentId;
  final Value<int> level;
  final Value<String> fullPath;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.images = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    this.fullPath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.images = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    required String fullPath,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       fullPath = Value(fullPath);
  static Insertable<Location> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? images,
    Expression<int>? parentId,
    Expression<int>? level,
    Expression<String>? fullPath,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (images != null) 'images': images,
      if (parentId != null) 'parent_id': parentId,
      if (level != null) 'level': level,
      if (fullPath != null) 'full_path': fullPath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<String?>? images,
    Value<int?>? parentId,
    Value<int>? level,
    Value<String>? fullPath,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      images: images ?? this.images,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      fullPath: fullPath ?? this.fullPath,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (fullPath.present) {
      map['full_path'] = Variable<String>(fullPath.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('images: $images, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('fullPath: $fullPath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specificationMeta = const VerificationMeta(
    'specification',
  );
  @override
  late final GeneratedColumn<String> specification = GeneratedColumn<String>(
    'specification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<int> locationId = GeneratedColumn<int>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerNameMeta = const VerificationMeta(
    'containerName',
  );
  @override
  late final GeneratedColumn<String> containerName = GeneratedColumn<String>(
    'container_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseQuantityMeta = const VerificationMeta(
    'purchaseQuantity',
  );
  @override
  late final GeneratedColumn<int> purchaseQuantity = GeneratedColumn<int>(
    'purchase_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _packageUnitMeta = const VerificationMeta(
    'packageUnit',
  );
  @override
  late final GeneratedColumn<String> packageUnit = GeneratedColumn<String>(
    'package_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageQuantityMeta = const VerificationMeta(
    'packageQuantity',
  );
  @override
  late final GeneratedColumn<int> packageQuantity = GeneratedColumn<int>(
    'package_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentQuantityMeta = const VerificationMeta(
    'currentQuantity',
  );
  @override
  late final GeneratedColumn<double> currentQuantity = GeneratedColumn<double>(
    'current_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('件'),
  );
  static const VerificationMeta _safetyStockMeta = const VerificationMeta(
    'safetyStock',
  );
  @override
  late final GeneratedColumn<double> safetyStock = GeneratedColumn<double>(
    'safety_stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseChannelMeta = const VerificationMeta(
    'purchaseChannel',
  );
  @override
  late final GeneratedColumn<String> purchaseChannel = GeneratedColumn<String>(
    'purchase_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productionDateMeta = const VerificationMeta(
    'productionDate',
  );
  @override
  late final GeneratedColumn<DateTime> productionDate =
      GeneratedColumn<DateTime>(
        'production_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfLifeDaysMeta = const VerificationMeta(
    'shelfLifeDays',
  );
  @override
  late final GeneratedColumn<int> shelfLifeDays = GeneratedColumn<int>(
    'shelf_life_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedDateMeta = const VerificationMeta(
    'openedDate',
  );
  @override
  late final GeneratedColumn<DateTime> openedDate = GeneratedColumn<DateTime>(
    'opened_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterOpenDaysMeta = const VerificationMeta(
    'afterOpenDays',
  );
  @override
  late final GeneratedColumn<int> afterOpenDays = GeneratedColumn<int>(
    'after_open_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyDateMeta = const VerificationMeta(
    'warrantyDate',
  );
  @override
  late final GeneratedColumn<DateTime> warrantyDate = GeneratedColumn<DateTime>(
    'warranty_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryAlertDaysMeta = const VerificationMeta(
    'expiryAlertDays',
  );
  @override
  late final GeneratedColumn<int> expiryAlertDays = GeneratedColumn<int>(
    'expiry_alert_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _stockAlertMeta = const VerificationMeta(
    'stockAlert',
  );
  @override
  late final GeneratedColumn<bool> stockAlert = GeneratedColumn<bool>(
    'stock_alert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stock_alert" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgDailyConsumptionMeta =
      const VerificationMeta('avgDailyConsumption');
  @override
  late final GeneratedColumn<double> avgDailyConsumption =
      GeneratedColumn<double>(
        'avg_daily_consumption',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _predictedEmptyDateMeta =
      const VerificationMeta('predictedEmptyDate');
  @override
  late final GeneratedColumn<DateTime> predictedEmptyDate =
      GeneratedColumn<DateTime>(
        'predicted_empty_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _serverItemIdMeta = const VerificationMeta(
    'serverItemId',
  );
  @override
  late final GeneratedColumn<int> serverItemId = GeneratedColumn<int>(
    'server_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    specification,
    barcode,
    categoryId,
    locationId,
    containerName,
    purchasePrice,
    salePrice,
    supplier,
    purchaseQuantity,
    packageUnit,
    packageQuantity,
    currentQuantity,
    unit,
    safetyStock,
    purchaseDate,
    purchaseChannel,
    productionDate,
    expiryDate,
    shelfLifeDays,
    openedDate,
    afterOpenDays,
    warrantyDate,
    expiryAlertDays,
    stockAlert,
    images,
    notes,
    status,
    avgDailyConsumption,
    predictedEmptyDate,
    lastUsedAt,
    createdAt,
    updatedAt,
    serverItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('specification')) {
      context.handle(
        _specificationMeta,
        specification.isAcceptableOrUnknown(
          data['specification']!,
          _specificationMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('container_name')) {
      context.handle(
        _containerNameMeta,
        containerName.isAcceptableOrUnknown(
          data['container_name']!,
          _containerNameMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('purchase_quantity')) {
      context.handle(
        _purchaseQuantityMeta,
        purchaseQuantity.isAcceptableOrUnknown(
          data['purchase_quantity']!,
          _purchaseQuantityMeta,
        ),
      );
    }
    if (data.containsKey('package_unit')) {
      context.handle(
        _packageUnitMeta,
        packageUnit.isAcceptableOrUnknown(
          data['package_unit']!,
          _packageUnitMeta,
        ),
      );
    }
    if (data.containsKey('package_quantity')) {
      context.handle(
        _packageQuantityMeta,
        packageQuantity.isAcceptableOrUnknown(
          data['package_quantity']!,
          _packageQuantityMeta,
        ),
      );
    }
    if (data.containsKey('current_quantity')) {
      context.handle(
        _currentQuantityMeta,
        currentQuantity.isAcceptableOrUnknown(
          data['current_quantity']!,
          _currentQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('safety_stock')) {
      context.handle(
        _safetyStockMeta,
        safetyStock.isAcceptableOrUnknown(
          data['safety_stock']!,
          _safetyStockMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('purchase_channel')) {
      context.handle(
        _purchaseChannelMeta,
        purchaseChannel.isAcceptableOrUnknown(
          data['purchase_channel']!,
          _purchaseChannelMeta,
        ),
      );
    }
    if (data.containsKey('production_date')) {
      context.handle(
        _productionDateMeta,
        productionDate.isAcceptableOrUnknown(
          data['production_date']!,
          _productionDateMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('shelf_life_days')) {
      context.handle(
        _shelfLifeDaysMeta,
        shelfLifeDays.isAcceptableOrUnknown(
          data['shelf_life_days']!,
          _shelfLifeDaysMeta,
        ),
      );
    }
    if (data.containsKey('opened_date')) {
      context.handle(
        _openedDateMeta,
        openedDate.isAcceptableOrUnknown(data['opened_date']!, _openedDateMeta),
      );
    }
    if (data.containsKey('after_open_days')) {
      context.handle(
        _afterOpenDaysMeta,
        afterOpenDays.isAcceptableOrUnknown(
          data['after_open_days']!,
          _afterOpenDaysMeta,
        ),
      );
    }
    if (data.containsKey('warranty_date')) {
      context.handle(
        _warrantyDateMeta,
        warrantyDate.isAcceptableOrUnknown(
          data['warranty_date']!,
          _warrantyDateMeta,
        ),
      );
    }
    if (data.containsKey('expiry_alert_days')) {
      context.handle(
        _expiryAlertDaysMeta,
        expiryAlertDays.isAcceptableOrUnknown(
          data['expiry_alert_days']!,
          _expiryAlertDaysMeta,
        ),
      );
    }
    if (data.containsKey('stock_alert')) {
      context.handle(
        _stockAlertMeta,
        stockAlert.isAcceptableOrUnknown(data['stock_alert']!, _stockAlertMeta),
      );
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('avg_daily_consumption')) {
      context.handle(
        _avgDailyConsumptionMeta,
        avgDailyConsumption.isAcceptableOrUnknown(
          data['avg_daily_consumption']!,
          _avgDailyConsumptionMeta,
        ),
      );
    }
    if (data.containsKey('predicted_empty_date')) {
      context.handle(
        _predictedEmptyDateMeta,
        predictedEmptyDate.isAcceptableOrUnknown(
          data['predicted_empty_date']!,
          _predictedEmptyDateMeta,
        ),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('server_item_id')) {
      context.handle(
        _serverItemIdMeta,
        serverItemId.isAcceptableOrUnknown(
          data['server_item_id']!,
          _serverItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      specification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specification'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_id'],
      ),
      containerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_name'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      ),
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      purchaseQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_quantity'],
      )!,
      packageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_unit'],
      ),
      packageQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}package_quantity'],
      )!,
      currentQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      safetyStock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}safety_stock'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      purchaseChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_channel'],
      ),
      productionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}production_date'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      shelfLifeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_life_days'],
      ),
      openedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_date'],
      ),
      afterOpenDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}after_open_days'],
      ),
      warrantyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}warranty_date'],
      ),
      expiryAlertDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiry_alert_days'],
      )!,
      stockAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stock_alert'],
      )!,
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      avgDailyConsumption: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_daily_consumption'],
      ),
      predictedEmptyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}predicted_empty_date'],
      ),
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      serverItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_item_id'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String name;
  final String? brand;
  final String? specification;
  final String? barcode;
  final int categoryId;
  final int? locationId;
  final String? containerName;
  final double? purchasePrice;

  /// B+ 售价 — 店铺场景零售价
  final double? salePrice;

  /// B+ 供应商 — 店铺场景
  final String? supplier;
  final int purchaseQuantity;
  final String? packageUnit;
  final int packageQuantity;
  final double currentQuantity;
  final String unit;
  final double safetyStock;
  final DateTime? purchaseDate;
  final String? purchaseChannel;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final int? shelfLifeDays;
  final DateTime? openedDate;
  final int? afterOpenDays;
  final DateTime? warrantyDate;
  final int expiryAlertDays;
  final bool stockAlert;
  final String? images;
  final String? notes;
  final int status;
  final double? avgDailyConsumption;
  final DateTime? predictedEmptyDate;

  /// 最后一次使用时间（type=1 UsageRecord 写入时同步更新）
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 服务端 items.id — 本地主键与服务端不一致时用于 API / usage 映射
  final int? serverItemId;
  const Item({
    required this.id,
    required this.name,
    this.brand,
    this.specification,
    this.barcode,
    required this.categoryId,
    this.locationId,
    this.containerName,
    this.purchasePrice,
    this.salePrice,
    this.supplier,
    required this.purchaseQuantity,
    this.packageUnit,
    required this.packageQuantity,
    required this.currentQuantity,
    required this.unit,
    required this.safetyStock,
    this.purchaseDate,
    this.purchaseChannel,
    this.productionDate,
    this.expiryDate,
    this.shelfLifeDays,
    this.openedDate,
    this.afterOpenDays,
    this.warrantyDate,
    required this.expiryAlertDays,
    required this.stockAlert,
    this.images,
    this.notes,
    required this.status,
    this.avgDailyConsumption,
    this.predictedEmptyDate,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
    this.serverItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || specification != null) {
      map['specification'] = Variable<String>(specification);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<int>(locationId);
    }
    if (!nullToAbsent || containerName != null) {
      map['container_name'] = Variable<String>(containerName);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    if (!nullToAbsent || salePrice != null) {
      map['sale_price'] = Variable<double>(salePrice);
    }
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    map['purchase_quantity'] = Variable<int>(purchaseQuantity);
    if (!nullToAbsent || packageUnit != null) {
      map['package_unit'] = Variable<String>(packageUnit);
    }
    map['package_quantity'] = Variable<int>(packageQuantity);
    map['current_quantity'] = Variable<double>(currentQuantity);
    map['unit'] = Variable<String>(unit);
    map['safety_stock'] = Variable<double>(safetyStock);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || purchaseChannel != null) {
      map['purchase_channel'] = Variable<String>(purchaseChannel);
    }
    if (!nullToAbsent || productionDate != null) {
      map['production_date'] = Variable<DateTime>(productionDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || shelfLifeDays != null) {
      map['shelf_life_days'] = Variable<int>(shelfLifeDays);
    }
    if (!nullToAbsent || openedDate != null) {
      map['opened_date'] = Variable<DateTime>(openedDate);
    }
    if (!nullToAbsent || afterOpenDays != null) {
      map['after_open_days'] = Variable<int>(afterOpenDays);
    }
    if (!nullToAbsent || warrantyDate != null) {
      map['warranty_date'] = Variable<DateTime>(warrantyDate);
    }
    map['expiry_alert_days'] = Variable<int>(expiryAlertDays);
    map['stock_alert'] = Variable<bool>(stockAlert);
    if (!nullToAbsent || images != null) {
      map['images'] = Variable<String>(images);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || avgDailyConsumption != null) {
      map['avg_daily_consumption'] = Variable<double>(avgDailyConsumption);
    }
    if (!nullToAbsent || predictedEmptyDate != null) {
      map['predicted_empty_date'] = Variable<DateTime>(predictedEmptyDate);
    }
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || serverItemId != null) {
      map['server_item_id'] = Variable<int>(serverItemId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      specification: specification == null && nullToAbsent
          ? const Value.absent()
          : Value(specification),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      categoryId: Value(categoryId),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      containerName: containerName == null && nullToAbsent
          ? const Value.absent()
          : Value(containerName),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      salePrice: salePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(salePrice),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      purchaseQuantity: Value(purchaseQuantity),
      packageUnit: packageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(packageUnit),
      packageQuantity: Value(packageQuantity),
      currentQuantity: Value(currentQuantity),
      unit: Value(unit),
      safetyStock: Value(safetyStock),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      purchaseChannel: purchaseChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseChannel),
      productionDate: productionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(productionDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      shelfLifeDays: shelfLifeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLifeDays),
      openedDate: openedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openedDate),
      afterOpenDays: afterOpenDays == null && nullToAbsent
          ? const Value.absent()
          : Value(afterOpenDays),
      warrantyDate: warrantyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyDate),
      expiryAlertDays: Value(expiryAlertDays),
      stockAlert: Value(stockAlert),
      images: images == null && nullToAbsent
          ? const Value.absent()
          : Value(images),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      avgDailyConsumption: avgDailyConsumption == null && nullToAbsent
          ? const Value.absent()
          : Value(avgDailyConsumption),
      predictedEmptyDate: predictedEmptyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedEmptyDate),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverItemId: serverItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverItemId),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      specification: serializer.fromJson<String?>(json['specification']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      locationId: serializer.fromJson<int?>(json['locationId']),
      containerName: serializer.fromJson<String?>(json['containerName']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      salePrice: serializer.fromJson<double?>(json['salePrice']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      purchaseQuantity: serializer.fromJson<int>(json['purchaseQuantity']),
      packageUnit: serializer.fromJson<String?>(json['packageUnit']),
      packageQuantity: serializer.fromJson<int>(json['packageQuantity']),
      currentQuantity: serializer.fromJson<double>(json['currentQuantity']),
      unit: serializer.fromJson<String>(json['unit']),
      safetyStock: serializer.fromJson<double>(json['safetyStock']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      purchaseChannel: serializer.fromJson<String?>(json['purchaseChannel']),
      productionDate: serializer.fromJson<DateTime?>(json['productionDate']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      shelfLifeDays: serializer.fromJson<int?>(json['shelfLifeDays']),
      openedDate: serializer.fromJson<DateTime?>(json['openedDate']),
      afterOpenDays: serializer.fromJson<int?>(json['afterOpenDays']),
      warrantyDate: serializer.fromJson<DateTime?>(json['warrantyDate']),
      expiryAlertDays: serializer.fromJson<int>(json['expiryAlertDays']),
      stockAlert: serializer.fromJson<bool>(json['stockAlert']),
      images: serializer.fromJson<String?>(json['images']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<int>(json['status']),
      avgDailyConsumption: serializer.fromJson<double?>(
        json['avgDailyConsumption'],
      ),
      predictedEmptyDate: serializer.fromJson<DateTime?>(
        json['predictedEmptyDate'],
      ),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      serverItemId: serializer.fromJson<int?>(json['serverItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'specification': serializer.toJson<String?>(specification),
      'barcode': serializer.toJson<String?>(barcode),
      'categoryId': serializer.toJson<int>(categoryId),
      'locationId': serializer.toJson<int?>(locationId),
      'containerName': serializer.toJson<String?>(containerName),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'salePrice': serializer.toJson<double?>(salePrice),
      'supplier': serializer.toJson<String?>(supplier),
      'purchaseQuantity': serializer.toJson<int>(purchaseQuantity),
      'packageUnit': serializer.toJson<String?>(packageUnit),
      'packageQuantity': serializer.toJson<int>(packageQuantity),
      'currentQuantity': serializer.toJson<double>(currentQuantity),
      'unit': serializer.toJson<String>(unit),
      'safetyStock': serializer.toJson<double>(safetyStock),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'purchaseChannel': serializer.toJson<String?>(purchaseChannel),
      'productionDate': serializer.toJson<DateTime?>(productionDate),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'shelfLifeDays': serializer.toJson<int?>(shelfLifeDays),
      'openedDate': serializer.toJson<DateTime?>(openedDate),
      'afterOpenDays': serializer.toJson<int?>(afterOpenDays),
      'warrantyDate': serializer.toJson<DateTime?>(warrantyDate),
      'expiryAlertDays': serializer.toJson<int>(expiryAlertDays),
      'stockAlert': serializer.toJson<bool>(stockAlert),
      'images': serializer.toJson<String?>(images),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<int>(status),
      'avgDailyConsumption': serializer.toJson<double?>(avgDailyConsumption),
      'predictedEmptyDate': serializer.toJson<DateTime?>(predictedEmptyDate),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'serverItemId': serializer.toJson<int?>(serverItemId),
    };
  }

  Item copyWith({
    int? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> specification = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    int? categoryId,
    Value<int?> locationId = const Value.absent(),
    Value<String?> containerName = const Value.absent(),
    Value<double?> purchasePrice = const Value.absent(),
    Value<double?> salePrice = const Value.absent(),
    Value<String?> supplier = const Value.absent(),
    int? purchaseQuantity,
    Value<String?> packageUnit = const Value.absent(),
    int? packageQuantity,
    double? currentQuantity,
    String? unit,
    double? safetyStock,
    Value<DateTime?> purchaseDate = const Value.absent(),
    Value<String?> purchaseChannel = const Value.absent(),
    Value<DateTime?> productionDate = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<int?> shelfLifeDays = const Value.absent(),
    Value<DateTime?> openedDate = const Value.absent(),
    Value<int?> afterOpenDays = const Value.absent(),
    Value<DateTime?> warrantyDate = const Value.absent(),
    int? expiryAlertDays,
    bool? stockAlert,
    Value<String?> images = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? status,
    Value<double?> avgDailyConsumption = const Value.absent(),
    Value<DateTime?> predictedEmptyDate = const Value.absent(),
    Value<DateTime?> lastUsedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> serverItemId = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    specification: specification.present
        ? specification.value
        : this.specification,
    barcode: barcode.present ? barcode.value : this.barcode,
    categoryId: categoryId ?? this.categoryId,
    locationId: locationId.present ? locationId.value : this.locationId,
    containerName: containerName.present
        ? containerName.value
        : this.containerName,
    purchasePrice: purchasePrice.present
        ? purchasePrice.value
        : this.purchasePrice,
    salePrice: salePrice.present ? salePrice.value : this.salePrice,
    supplier: supplier.present ? supplier.value : this.supplier,
    purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
    packageUnit: packageUnit.present ? packageUnit.value : this.packageUnit,
    packageQuantity: packageQuantity ?? this.packageQuantity,
    currentQuantity: currentQuantity ?? this.currentQuantity,
    unit: unit ?? this.unit,
    safetyStock: safetyStock ?? this.safetyStock,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    purchaseChannel: purchaseChannel.present
        ? purchaseChannel.value
        : this.purchaseChannel,
    productionDate: productionDate.present
        ? productionDate.value
        : this.productionDate,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    shelfLifeDays: shelfLifeDays.present
        ? shelfLifeDays.value
        : this.shelfLifeDays,
    openedDate: openedDate.present ? openedDate.value : this.openedDate,
    afterOpenDays: afterOpenDays.present
        ? afterOpenDays.value
        : this.afterOpenDays,
    warrantyDate: warrantyDate.present ? warrantyDate.value : this.warrantyDate,
    expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
    stockAlert: stockAlert ?? this.stockAlert,
    images: images.present ? images.value : this.images,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    avgDailyConsumption: avgDailyConsumption.present
        ? avgDailyConsumption.value
        : this.avgDailyConsumption,
    predictedEmptyDate: predictedEmptyDate.present
        ? predictedEmptyDate.value
        : this.predictedEmptyDate,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverItemId: serverItemId.present ? serverItemId.value : this.serverItemId,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      specification: data.specification.present
          ? data.specification.value
          : this.specification,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      containerName: data.containerName.present
          ? data.containerName.value
          : this.containerName,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      purchaseQuantity: data.purchaseQuantity.present
          ? data.purchaseQuantity.value
          : this.purchaseQuantity,
      packageUnit: data.packageUnit.present
          ? data.packageUnit.value
          : this.packageUnit,
      packageQuantity: data.packageQuantity.present
          ? data.packageQuantity.value
          : this.packageQuantity,
      currentQuantity: data.currentQuantity.present
          ? data.currentQuantity.value
          : this.currentQuantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      safetyStock: data.safetyStock.present
          ? data.safetyStock.value
          : this.safetyStock,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchaseChannel: data.purchaseChannel.present
          ? data.purchaseChannel.value
          : this.purchaseChannel,
      productionDate: data.productionDate.present
          ? data.productionDate.value
          : this.productionDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      shelfLifeDays: data.shelfLifeDays.present
          ? data.shelfLifeDays.value
          : this.shelfLifeDays,
      openedDate: data.openedDate.present
          ? data.openedDate.value
          : this.openedDate,
      afterOpenDays: data.afterOpenDays.present
          ? data.afterOpenDays.value
          : this.afterOpenDays,
      warrantyDate: data.warrantyDate.present
          ? data.warrantyDate.value
          : this.warrantyDate,
      expiryAlertDays: data.expiryAlertDays.present
          ? data.expiryAlertDays.value
          : this.expiryAlertDays,
      stockAlert: data.stockAlert.present
          ? data.stockAlert.value
          : this.stockAlert,
      images: data.images.present ? data.images.value : this.images,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      avgDailyConsumption: data.avgDailyConsumption.present
          ? data.avgDailyConsumption.value
          : this.avgDailyConsumption,
      predictedEmptyDate: data.predictedEmptyDate.present
          ? data.predictedEmptyDate.value
          : this.predictedEmptyDate,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverItemId: data.serverItemId.present
          ? data.serverItemId.value
          : this.serverItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('specification: $specification, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('locationId: $locationId, ')
          ..write('containerName: $containerName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('supplier: $supplier, ')
          ..write('purchaseQuantity: $purchaseQuantity, ')
          ..write('packageUnit: $packageUnit, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('currentQuantity: $currentQuantity, ')
          ..write('unit: $unit, ')
          ..write('safetyStock: $safetyStock, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseChannel: $purchaseChannel, ')
          ..write('productionDate: $productionDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('openedDate: $openedDate, ')
          ..write('afterOpenDays: $afterOpenDays, ')
          ..write('warrantyDate: $warrantyDate, ')
          ..write('expiryAlertDays: $expiryAlertDays, ')
          ..write('stockAlert: $stockAlert, ')
          ..write('images: $images, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('avgDailyConsumption: $avgDailyConsumption, ')
          ..write('predictedEmptyDate: $predictedEmptyDate, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverItemId: $serverItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    brand,
    specification,
    barcode,
    categoryId,
    locationId,
    containerName,
    purchasePrice,
    salePrice,
    supplier,
    purchaseQuantity,
    packageUnit,
    packageQuantity,
    currentQuantity,
    unit,
    safetyStock,
    purchaseDate,
    purchaseChannel,
    productionDate,
    expiryDate,
    shelfLifeDays,
    openedDate,
    afterOpenDays,
    warrantyDate,
    expiryAlertDays,
    stockAlert,
    images,
    notes,
    status,
    avgDailyConsumption,
    predictedEmptyDate,
    lastUsedAt,
    createdAt,
    updatedAt,
    serverItemId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.specification == this.specification &&
          other.barcode == this.barcode &&
          other.categoryId == this.categoryId &&
          other.locationId == this.locationId &&
          other.containerName == this.containerName &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.supplier == this.supplier &&
          other.purchaseQuantity == this.purchaseQuantity &&
          other.packageUnit == this.packageUnit &&
          other.packageQuantity == this.packageQuantity &&
          other.currentQuantity == this.currentQuantity &&
          other.unit == this.unit &&
          other.safetyStock == this.safetyStock &&
          other.purchaseDate == this.purchaseDate &&
          other.purchaseChannel == this.purchaseChannel &&
          other.productionDate == this.productionDate &&
          other.expiryDate == this.expiryDate &&
          other.shelfLifeDays == this.shelfLifeDays &&
          other.openedDate == this.openedDate &&
          other.afterOpenDays == this.afterOpenDays &&
          other.warrantyDate == this.warrantyDate &&
          other.expiryAlertDays == this.expiryAlertDays &&
          other.stockAlert == this.stockAlert &&
          other.images == this.images &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.avgDailyConsumption == this.avgDailyConsumption &&
          other.predictedEmptyDate == this.predictedEmptyDate &&
          other.lastUsedAt == this.lastUsedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverItemId == this.serverItemId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> specification;
  final Value<String?> barcode;
  final Value<int> categoryId;
  final Value<int?> locationId;
  final Value<String?> containerName;
  final Value<double?> purchasePrice;
  final Value<double?> salePrice;
  final Value<String?> supplier;
  final Value<int> purchaseQuantity;
  final Value<String?> packageUnit;
  final Value<int> packageQuantity;
  final Value<double> currentQuantity;
  final Value<String> unit;
  final Value<double> safetyStock;
  final Value<DateTime?> purchaseDate;
  final Value<String?> purchaseChannel;
  final Value<DateTime?> productionDate;
  final Value<DateTime?> expiryDate;
  final Value<int?> shelfLifeDays;
  final Value<DateTime?> openedDate;
  final Value<int?> afterOpenDays;
  final Value<DateTime?> warrantyDate;
  final Value<int> expiryAlertDays;
  final Value<bool> stockAlert;
  final Value<String?> images;
  final Value<String?> notes;
  final Value<int> status;
  final Value<double?> avgDailyConsumption;
  final Value<DateTime?> predictedEmptyDate;
  final Value<DateTime?> lastUsedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> serverItemId;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.specification = const Value.absent(),
    this.barcode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.containerName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.supplier = const Value.absent(),
    this.purchaseQuantity = const Value.absent(),
    this.packageUnit = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.currentQuantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.safetyStock = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseChannel = const Value.absent(),
    this.productionDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.shelfLifeDays = const Value.absent(),
    this.openedDate = const Value.absent(),
    this.afterOpenDays = const Value.absent(),
    this.warrantyDate = const Value.absent(),
    this.expiryAlertDays = const Value.absent(),
    this.stockAlert = const Value.absent(),
    this.images = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.avgDailyConsumption = const Value.absent(),
    this.predictedEmptyDate = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverItemId = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.specification = const Value.absent(),
    this.barcode = const Value.absent(),
    required int categoryId,
    this.locationId = const Value.absent(),
    this.containerName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.supplier = const Value.absent(),
    this.purchaseQuantity = const Value.absent(),
    this.packageUnit = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.currentQuantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.safetyStock = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseChannel = const Value.absent(),
    this.productionDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.shelfLifeDays = const Value.absent(),
    this.openedDate = const Value.absent(),
    this.afterOpenDays = const Value.absent(),
    this.warrantyDate = const Value.absent(),
    this.expiryAlertDays = const Value.absent(),
    this.stockAlert = const Value.absent(),
    this.images = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.avgDailyConsumption = const Value.absent(),
    this.predictedEmptyDate = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverItemId = const Value.absent(),
  }) : name = Value(name),
       categoryId = Value(categoryId);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? specification,
    Expression<String>? barcode,
    Expression<int>? categoryId,
    Expression<int>? locationId,
    Expression<String>? containerName,
    Expression<double>? purchasePrice,
    Expression<double>? salePrice,
    Expression<String>? supplier,
    Expression<int>? purchaseQuantity,
    Expression<String>? packageUnit,
    Expression<int>? packageQuantity,
    Expression<double>? currentQuantity,
    Expression<String>? unit,
    Expression<double>? safetyStock,
    Expression<DateTime>? purchaseDate,
    Expression<String>? purchaseChannel,
    Expression<DateTime>? productionDate,
    Expression<DateTime>? expiryDate,
    Expression<int>? shelfLifeDays,
    Expression<DateTime>? openedDate,
    Expression<int>? afterOpenDays,
    Expression<DateTime>? warrantyDate,
    Expression<int>? expiryAlertDays,
    Expression<bool>? stockAlert,
    Expression<String>? images,
    Expression<String>? notes,
    Expression<int>? status,
    Expression<double>? avgDailyConsumption,
    Expression<DateTime>? predictedEmptyDate,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? serverItemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (specification != null) 'specification': specification,
      if (barcode != null) 'barcode': barcode,
      if (categoryId != null) 'category_id': categoryId,
      if (locationId != null) 'location_id': locationId,
      if (containerName != null) 'container_name': containerName,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (supplier != null) 'supplier': supplier,
      if (purchaseQuantity != null) 'purchase_quantity': purchaseQuantity,
      if (packageUnit != null) 'package_unit': packageUnit,
      if (packageQuantity != null) 'package_quantity': packageQuantity,
      if (currentQuantity != null) 'current_quantity': currentQuantity,
      if (unit != null) 'unit': unit,
      if (safetyStock != null) 'safety_stock': safetyStock,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchaseChannel != null) 'purchase_channel': purchaseChannel,
      if (productionDate != null) 'production_date': productionDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (shelfLifeDays != null) 'shelf_life_days': shelfLifeDays,
      if (openedDate != null) 'opened_date': openedDate,
      if (afterOpenDays != null) 'after_open_days': afterOpenDays,
      if (warrantyDate != null) 'warranty_date': warrantyDate,
      if (expiryAlertDays != null) 'expiry_alert_days': expiryAlertDays,
      if (stockAlert != null) 'stock_alert': stockAlert,
      if (images != null) 'images': images,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (avgDailyConsumption != null)
        'avg_daily_consumption': avgDailyConsumption,
      if (predictedEmptyDate != null)
        'predicted_empty_date': predictedEmptyDate,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverItemId != null) 'server_item_id': serverItemId,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? specification,
    Value<String?>? barcode,
    Value<int>? categoryId,
    Value<int?>? locationId,
    Value<String?>? containerName,
    Value<double?>? purchasePrice,
    Value<double?>? salePrice,
    Value<String?>? supplier,
    Value<int>? purchaseQuantity,
    Value<String?>? packageUnit,
    Value<int>? packageQuantity,
    Value<double>? currentQuantity,
    Value<String>? unit,
    Value<double>? safetyStock,
    Value<DateTime?>? purchaseDate,
    Value<String?>? purchaseChannel,
    Value<DateTime?>? productionDate,
    Value<DateTime?>? expiryDate,
    Value<int?>? shelfLifeDays,
    Value<DateTime?>? openedDate,
    Value<int?>? afterOpenDays,
    Value<DateTime?>? warrantyDate,
    Value<int>? expiryAlertDays,
    Value<bool>? stockAlert,
    Value<String?>? images,
    Value<String?>? notes,
    Value<int>? status,
    Value<double?>? avgDailyConsumption,
    Value<DateTime?>? predictedEmptyDate,
    Value<DateTime?>? lastUsedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? serverItemId,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      specification: specification ?? this.specification,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      containerName: containerName ?? this.containerName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      supplier: supplier ?? this.supplier,
      purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
      packageUnit: packageUnit ?? this.packageUnit,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      unit: unit ?? this.unit,
      safetyStock: safetyStock ?? this.safetyStock,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseChannel: purchaseChannel ?? this.purchaseChannel,
      productionDate: productionDate ?? this.productionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      openedDate: openedDate ?? this.openedDate,
      afterOpenDays: afterOpenDays ?? this.afterOpenDays,
      warrantyDate: warrantyDate ?? this.warrantyDate,
      expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
      stockAlert: stockAlert ?? this.stockAlert,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      avgDailyConsumption: avgDailyConsumption ?? this.avgDailyConsumption,
      predictedEmptyDate: predictedEmptyDate ?? this.predictedEmptyDate,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverItemId: serverItemId ?? this.serverItemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (specification.present) {
      map['specification'] = Variable<String>(specification.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<int>(locationId.value);
    }
    if (containerName.present) {
      map['container_name'] = Variable<String>(containerName.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (purchaseQuantity.present) {
      map['purchase_quantity'] = Variable<int>(purchaseQuantity.value);
    }
    if (packageUnit.present) {
      map['package_unit'] = Variable<String>(packageUnit.value);
    }
    if (packageQuantity.present) {
      map['package_quantity'] = Variable<int>(packageQuantity.value);
    }
    if (currentQuantity.present) {
      map['current_quantity'] = Variable<double>(currentQuantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (safetyStock.present) {
      map['safety_stock'] = Variable<double>(safetyStock.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (purchaseChannel.present) {
      map['purchase_channel'] = Variable<String>(purchaseChannel.value);
    }
    if (productionDate.present) {
      map['production_date'] = Variable<DateTime>(productionDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (shelfLifeDays.present) {
      map['shelf_life_days'] = Variable<int>(shelfLifeDays.value);
    }
    if (openedDate.present) {
      map['opened_date'] = Variable<DateTime>(openedDate.value);
    }
    if (afterOpenDays.present) {
      map['after_open_days'] = Variable<int>(afterOpenDays.value);
    }
    if (warrantyDate.present) {
      map['warranty_date'] = Variable<DateTime>(warrantyDate.value);
    }
    if (expiryAlertDays.present) {
      map['expiry_alert_days'] = Variable<int>(expiryAlertDays.value);
    }
    if (stockAlert.present) {
      map['stock_alert'] = Variable<bool>(stockAlert.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (avgDailyConsumption.present) {
      map['avg_daily_consumption'] = Variable<double>(
        avgDailyConsumption.value,
      );
    }
    if (predictedEmptyDate.present) {
      map['predicted_empty_date'] = Variable<DateTime>(
        predictedEmptyDate.value,
      );
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverItemId.present) {
      map['server_item_id'] = Variable<int>(serverItemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('specification: $specification, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('locationId: $locationId, ')
          ..write('containerName: $containerName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('supplier: $supplier, ')
          ..write('purchaseQuantity: $purchaseQuantity, ')
          ..write('packageUnit: $packageUnit, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('currentQuantity: $currentQuantity, ')
          ..write('unit: $unit, ')
          ..write('safetyStock: $safetyStock, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseChannel: $purchaseChannel, ')
          ..write('productionDate: $productionDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('openedDate: $openedDate, ')
          ..write('afterOpenDays: $afterOpenDays, ')
          ..write('warrantyDate: $warrantyDate, ')
          ..write('expiryAlertDays: $expiryAlertDays, ')
          ..write('stockAlert: $stockAlert, ')
          ..write('images: $images, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('avgDailyConsumption: $avgDailyConsumption, ')
          ..write('predictedEmptyDate: $predictedEmptyDate, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverItemId: $serverItemId')
          ..write(')'))
        .toString();
  }
}

class $UsageRecordsTable extends UsageRecords
    with TableInfo<$UsageRecordsTable, UsageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingQuantityMeta = const VerificationMeta(
    'remainingQuantity',
  );
  @override
  late final GeneratedColumn<double> remainingQuantity =
      GeneratedColumn<double>(
        'remaining_quantity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _operatorNameMeta = const VerificationMeta(
    'operatorName',
  );
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
    'operator_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverRecordIdMeta = const VerificationMeta(
    'serverRecordId',
  );
  @override
  late final GeneratedColumn<int> serverRecordId = GeneratedColumn<int>(
    'server_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    type,
    quantity,
    remainingQuantity,
    operatorName,
    serverRecordId,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('remaining_quantity')) {
      context.handle(
        _remainingQuantityMeta,
        remainingQuantity.isAcceptableOrUnknown(
          data['remaining_quantity']!,
          _remainingQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingQuantityMeta);
    }
    if (data.containsKey('operator_name')) {
      context.handle(
        _operatorNameMeta,
        operatorName.isAcceptableOrUnknown(
          data['operator_name']!,
          _operatorNameMeta,
        ),
      );
    }
    if (data.containsKey('server_record_id')) {
      context.handle(
        _serverRecordIdMeta,
        serverRecordId.isAcceptableOrUnknown(
          data['server_record_id']!,
          _serverRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      remainingQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining_quantity'],
      )!,
      operatorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_name'],
      ),
      serverRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_record_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsageRecordsTable createAlias(String alias) {
    return $UsageRecordsTable(attachedDatabase, alias);
  }
}

class UsageRecord extends DataClass implements Insertable<UsageRecord> {
  final int id;
  final int itemId;
  final int type;
  final double quantity;
  final double remainingQuantity;
  final String? operatorName;

  /// 服务端 usage_records.id — 用于多端去重与补推
  final int? serverRecordId;
  final String? notes;
  final DateTime createdAt;
  const UsageRecord({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.remainingQuantity,
    this.operatorName,
    this.serverRecordId,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['type'] = Variable<int>(type);
    map['quantity'] = Variable<double>(quantity);
    map['remaining_quantity'] = Variable<double>(remainingQuantity);
    if (!nullToAbsent || operatorName != null) {
      map['operator_name'] = Variable<String>(operatorName);
    }
    if (!nullToAbsent || serverRecordId != null) {
      map['server_record_id'] = Variable<int>(serverRecordId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsageRecordsCompanion toCompanion(bool nullToAbsent) {
    return UsageRecordsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      type: Value(type),
      quantity: Value(quantity),
      remainingQuantity: Value(remainingQuantity),
      operatorName: operatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorName),
      serverRecordId: serverRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRecordId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory UsageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageRecord(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      type: serializer.fromJson<int>(json['type']),
      quantity: serializer.fromJson<double>(json['quantity']),
      remainingQuantity: serializer.fromJson<double>(json['remainingQuantity']),
      operatorName: serializer.fromJson<String?>(json['operatorName']),
      serverRecordId: serializer.fromJson<int?>(json['serverRecordId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'type': serializer.toJson<int>(type),
      'quantity': serializer.toJson<double>(quantity),
      'remainingQuantity': serializer.toJson<double>(remainingQuantity),
      'operatorName': serializer.toJson<String?>(operatorName),
      'serverRecordId': serializer.toJson<int?>(serverRecordId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UsageRecord copyWith({
    int? id,
    int? itemId,
    int? type,
    double? quantity,
    double? remainingQuantity,
    Value<String?> operatorName = const Value.absent(),
    Value<int?> serverRecordId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => UsageRecord(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    remainingQuantity: remainingQuantity ?? this.remainingQuantity,
    operatorName: operatorName.present ? operatorName.value : this.operatorName,
    serverRecordId: serverRecordId.present
        ? serverRecordId.value
        : this.serverRecordId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  UsageRecord copyWithCompanion(UsageRecordsCompanion data) {
    return UsageRecord(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      remainingQuantity: data.remainingQuantity.present
          ? data.remainingQuantity.value
          : this.remainingQuantity,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      serverRecordId: data.serverRecordId.present
          ? data.serverRecordId.value
          : this.serverRecordId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageRecord(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('operatorName: $operatorName, ')
          ..write('serverRecordId: $serverRecordId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    type,
    quantity,
    remainingQuantity,
    operatorName,
    serverRecordId,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageRecord &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.remainingQuantity == this.remainingQuantity &&
          other.operatorName == this.operatorName &&
          other.serverRecordId == this.serverRecordId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class UsageRecordsCompanion extends UpdateCompanion<UsageRecord> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<int> type;
  final Value<double> quantity;
  final Value<double> remainingQuantity;
  final Value<String?> operatorName;
  final Value<int?> serverRecordId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const UsageRecordsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.remainingQuantity = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.serverRecordId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsageRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required int type,
    required double quantity,
    required double remainingQuantity,
    this.operatorName = const Value.absent(),
    this.serverRecordId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : itemId = Value(itemId),
       type = Value(type),
       quantity = Value(quantity),
       remainingQuantity = Value(remainingQuantity);
  static Insertable<UsageRecord> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<int>? type,
    Expression<double>? quantity,
    Expression<double>? remainingQuantity,
    Expression<String>? operatorName,
    Expression<int>? serverRecordId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (remainingQuantity != null) 'remaining_quantity': remainingQuantity,
      if (operatorName != null) 'operator_name': operatorName,
      if (serverRecordId != null) 'server_record_id': serverRecordId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsageRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<int>? type,
    Value<double>? quantity,
    Value<double>? remainingQuantity,
    Value<String?>? operatorName,
    Value<int?>? serverRecordId,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return UsageRecordsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      operatorName: operatorName ?? this.operatorName,
      serverRecordId: serverRecordId ?? this.serverRecordId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (remainingQuantity.present) {
      map['remaining_quantity'] = Variable<double>(remainingQuantity.value);
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (serverRecordId.present) {
      map['server_record_id'] = Variable<int>(serverRecordId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('operatorName: $operatorName, ')
          ..write('serverRecordId: $serverRecordId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListTable extends ShoppingList
    with TableInfo<$ShoppingListTable, ShoppingListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedItemIdMeta = const VerificationMeta(
    'relatedItemId',
  );
  @override
  late final GeneratedColumn<int> relatedItemId = GeneratedColumn<int>(
    'related_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('件'),
  );
  static const VerificationMeta _estimatedPriceMeta = const VerificationMeta(
    'estimatedPrice',
  );
  @override
  late final GeneratedColumn<double> estimatedPrice = GeneratedColumn<double>(
    'estimated_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPurchasedMeta = const VerificationMeta(
    'isPurchased',
  );
  @override
  late final GeneratedColumn<bool> isPurchased = GeneratedColumn<bool>(
    'is_purchased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_purchased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAutoGeneratedMeta = const VerificationMeta(
    'isAutoGenerated',
  );
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
    'is_auto_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    relatedItemId,
    quantity,
    unit,
    estimatedPrice,
    isPurchased,
    isAutoGenerated,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('related_item_id')) {
      context.handle(
        _relatedItemIdMeta,
        relatedItemId.isAcceptableOrUnknown(
          data['related_item_id']!,
          _relatedItemIdMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('estimated_price')) {
      context.handle(
        _estimatedPriceMeta,
        estimatedPrice.isAcceptableOrUnknown(
          data['estimated_price']!,
          _estimatedPriceMeta,
        ),
      );
    }
    if (data.containsKey('is_purchased')) {
      context.handle(
        _isPurchasedMeta,
        isPurchased.isAcceptableOrUnknown(
          data['is_purchased']!,
          _isPurchasedMeta,
        ),
      );
    }
    if (data.containsKey('is_auto_generated')) {
      context.handle(
        _isAutoGeneratedMeta,
        isAutoGenerated.isAcceptableOrUnknown(
          data['is_auto_generated']!,
          _isAutoGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relatedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_item_id'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      estimatedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_price'],
      ),
      isPurchased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_purchased'],
      )!,
      isAutoGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_generated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShoppingListTable createAlias(String alias) {
    return $ShoppingListTable(attachedDatabase, alias);
  }
}

class ShoppingListData extends DataClass
    implements Insertable<ShoppingListData> {
  final int id;
  final String name;
  final int? relatedItemId;
  final double quantity;
  final String unit;
  final double? estimatedPrice;
  final bool isPurchased;
  final bool isAutoGenerated;
  final DateTime createdAt;
  const ShoppingListData({
    required this.id,
    required this.name,
    this.relatedItemId,
    required this.quantity,
    required this.unit,
    this.estimatedPrice,
    required this.isPurchased,
    required this.isAutoGenerated,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || relatedItemId != null) {
      map['related_item_id'] = Variable<int>(relatedItemId);
    }
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || estimatedPrice != null) {
      map['estimated_price'] = Variable<double>(estimatedPrice);
    }
    map['is_purchased'] = Variable<bool>(isPurchased);
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShoppingListCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListCompanion(
      id: Value(id),
      name: Value(name),
      relatedItemId: relatedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedItemId),
      quantity: Value(quantity),
      unit: Value(unit),
      estimatedPrice: estimatedPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedPrice),
      isPurchased: Value(isPurchased),
      isAutoGenerated: Value(isAutoGenerated),
      createdAt: Value(createdAt),
    );
  }

  factory ShoppingListData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      relatedItemId: serializer.fromJson<int?>(json['relatedItemId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      estimatedPrice: serializer.fromJson<double?>(json['estimatedPrice']),
      isPurchased: serializer.fromJson<bool>(json['isPurchased']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'relatedItemId': serializer.toJson<int?>(relatedItemId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'estimatedPrice': serializer.toJson<double?>(estimatedPrice),
      'isPurchased': serializer.toJson<bool>(isPurchased),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShoppingListData copyWith({
    int? id,
    String? name,
    Value<int?> relatedItemId = const Value.absent(),
    double? quantity,
    String? unit,
    Value<double?> estimatedPrice = const Value.absent(),
    bool? isPurchased,
    bool? isAutoGenerated,
    DateTime? createdAt,
  }) => ShoppingListData(
    id: id ?? this.id,
    name: name ?? this.name,
    relatedItemId: relatedItemId.present
        ? relatedItemId.value
        : this.relatedItemId,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    estimatedPrice: estimatedPrice.present
        ? estimatedPrice.value
        : this.estimatedPrice,
    isPurchased: isPurchased ?? this.isPurchased,
    isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
    createdAt: createdAt ?? this.createdAt,
  );
  ShoppingListData copyWithCompanion(ShoppingListCompanion data) {
    return ShoppingListData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      relatedItemId: data.relatedItemId.present
          ? data.relatedItemId.value
          : this.relatedItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      estimatedPrice: data.estimatedPrice.present
          ? data.estimatedPrice.value
          : this.estimatedPrice,
      isPurchased: data.isPurchased.present
          ? data.isPurchased.value
          : this.isPurchased,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relatedItemId: $relatedItemId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('estimatedPrice: $estimatedPrice, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    relatedItemId,
    quantity,
    unit,
    estimatedPrice,
    isPurchased,
    isAutoGenerated,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListData &&
          other.id == this.id &&
          other.name == this.name &&
          other.relatedItemId == this.relatedItemId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.estimatedPrice == this.estimatedPrice &&
          other.isPurchased == this.isPurchased &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.createdAt == this.createdAt);
}

class ShoppingListCompanion extends UpdateCompanion<ShoppingListData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> relatedItemId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double?> estimatedPrice;
  final Value<bool> isPurchased;
  final Value<bool> isAutoGenerated;
  final Value<DateTime> createdAt;
  const ShoppingListCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.relatedItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.estimatedPrice = const Value.absent(),
    this.isPurchased = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShoppingListCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.relatedItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.estimatedPrice = const Value.absent(),
    this.isPurchased = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ShoppingListData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? relatedItemId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? estimatedPrice,
    Expression<bool>? isPurchased,
    Expression<bool>? isAutoGenerated,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (relatedItemId != null) 'related_item_id': relatedItemId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (estimatedPrice != null) 'estimated_price': estimatedPrice,
      if (isPurchased != null) 'is_purchased': isPurchased,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShoppingListCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? relatedItemId,
    Value<double>? quantity,
    Value<String>? unit,
    Value<double?>? estimatedPrice,
    Value<bool>? isPurchased,
    Value<bool>? isAutoGenerated,
    Value<DateTime>? createdAt,
  }) {
    return ShoppingListCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isPurchased: isPurchased ?? this.isPurchased,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relatedItemId.present) {
      map['related_item_id'] = Variable<int>(relatedItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (estimatedPrice.present) {
      map['estimated_price'] = Variable<double>(estimatedPrice.value);
    }
    if (isPurchased.present) {
      map['is_purchased'] = Variable<bool>(isPurchased.value);
    }
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relatedItemId: $relatedItemId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('estimatedPrice: $estimatedPrice, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FamilyMembersTable extends FamilyMembers
    with TableInfo<$FamilyMembersTable, FamilyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, avatar, role, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FamilyMembersTable createAlias(String alias) {
    return $FamilyMembersTable(attachedDatabase, alias);
  }
}

class FamilyMember extends DataClass implements Insertable<FamilyMember> {
  final int id;
  final String name;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  const FamilyMember({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FamilyMembersCompanion toCompanion(bool nullToAbsent) {
    return FamilyMembersCompanion(
      id: Value(id),
      name: Value(name),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      role: Value(role),
      createdAt: Value(createdAt),
    );
  }

  factory FamilyMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMember(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FamilyMember copyWith({
    int? id,
    String? name,
    Value<String?> avatar = const Value.absent(),
    String? role,
    DateTime? createdAt,
  }) => FamilyMember(
    id: id ?? this.id,
    name: name ?? this.name,
    avatar: avatar.present ? avatar.value : this.avatar,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
  FamilyMember copyWithCompanion(FamilyMembersCompanion data) {
    return FamilyMember(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMember(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, avatar, role, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMember &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.role == this.role &&
          other.createdAt == this.createdAt);
}

class FamilyMembersCompanion extends UpdateCompanion<FamilyMember> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String> role;
  final Value<DateTime> createdAt;
  const FamilyMembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FamilyMembersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.avatar = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<FamilyMember> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FamilyMembersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? avatar,
    Value<String>? role,
    Value<DateTime>? createdAt,
  }) {
    return FamilyMembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AlertReadStatesTable extends AlertReadStates
    with TableInfo<$AlertReadStatesTable, AlertReadState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertReadStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertTypeMeta = const VerificationMeta(
    'alertType',
  );
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
    'alert_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<int> familyId = GeneratedColumn<int>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ignoredMeta = const VerificationMeta(
    'ignored',
  );
  @override
  late final GeneratedColumn<bool> ignored = GeneratedColumn<bool>(
    'ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    alertType,
    familyId,
    readAt,
    ignored,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_read_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertReadState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(
        _alertTypeMeta,
        alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('ignored')) {
      context.handle(
        _ignoredMeta,
        ignored.isAcceptableOrUnknown(data['ignored']!, _ignoredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertReadState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertReadState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      alertType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_type'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}family_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      ignored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ignored'],
      )!,
    );
  }

  @override
  $AlertReadStatesTable createAlias(String alias) {
    return $AlertReadStatesTable(attachedDatabase, alias);
  }
}

class AlertReadState extends DataClass implements Insertable<AlertReadState> {
  final int id;
  final int itemId;
  final String alertType;
  final int familyId;
  final DateTime? readAt;
  final bool ignored;
  const AlertReadState({
    required this.id,
    required this.itemId,
    required this.alertType,
    required this.familyId,
    this.readAt,
    required this.ignored,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['alert_type'] = Variable<String>(alertType);
    map['family_id'] = Variable<int>(familyId);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['ignored'] = Variable<bool>(ignored);
    return map;
  }

  AlertReadStatesCompanion toCompanion(bool nullToAbsent) {
    return AlertReadStatesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      alertType: Value(alertType),
      familyId: Value(familyId),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      ignored: Value(ignored),
    );
  }

  factory AlertReadState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertReadState(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      alertType: serializer.fromJson<String>(json['alertType']),
      familyId: serializer.fromJson<int>(json['familyId']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      ignored: serializer.fromJson<bool>(json['ignored']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'alertType': serializer.toJson<String>(alertType),
      'familyId': serializer.toJson<int>(familyId),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'ignored': serializer.toJson<bool>(ignored),
    };
  }

  AlertReadState copyWith({
    int? id,
    int? itemId,
    String? alertType,
    int? familyId,
    Value<DateTime?> readAt = const Value.absent(),
    bool? ignored,
  }) => AlertReadState(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    alertType: alertType ?? this.alertType,
    familyId: familyId ?? this.familyId,
    readAt: readAt.present ? readAt.value : this.readAt,
    ignored: ignored ?? this.ignored,
  );
  AlertReadState copyWithCompanion(AlertReadStatesCompanion data) {
    return AlertReadState(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      ignored: data.ignored.present ? data.ignored.value : this.ignored,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertReadState(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('alertType: $alertType, ')
          ..write('familyId: $familyId, ')
          ..write('readAt: $readAt, ')
          ..write('ignored: $ignored')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, alertType, familyId, readAt, ignored);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertReadState &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.alertType == this.alertType &&
          other.familyId == this.familyId &&
          other.readAt == this.readAt &&
          other.ignored == this.ignored);
}

class AlertReadStatesCompanion extends UpdateCompanion<AlertReadState> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<String> alertType;
  final Value<int> familyId;
  final Value<DateTime?> readAt;
  final Value<bool> ignored;
  const AlertReadStatesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.alertType = const Value.absent(),
    this.familyId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.ignored = const Value.absent(),
  });
  AlertReadStatesCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required String alertType,
    this.familyId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.ignored = const Value.absent(),
  }) : itemId = Value(itemId),
       alertType = Value(alertType);
  static Insertable<AlertReadState> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<String>? alertType,
    Expression<int>? familyId,
    Expression<DateTime>? readAt,
    Expression<bool>? ignored,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (alertType != null) 'alert_type': alertType,
      if (familyId != null) 'family_id': familyId,
      if (readAt != null) 'read_at': readAt,
      if (ignored != null) 'ignored': ignored,
    });
  }

  AlertReadStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<String>? alertType,
    Value<int>? familyId,
    Value<DateTime?>? readAt,
    Value<bool>? ignored,
  }) {
    return AlertReadStatesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      alertType: alertType ?? this.alertType,
      familyId: familyId ?? this.familyId,
      readAt: readAt ?? this.readAt,
      ignored: ignored ?? this.ignored,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<int>(familyId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (ignored.present) {
      map['ignored'] = Variable<bool>(ignored.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertReadStatesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('alertType: $alertType, ')
          ..write('familyId: $familyId, ')
          ..write('readAt: $readAt, ')
          ..write('ignored: $ignored')
          ..write(')'))
        .toString();
  }
}

class $AssistantMessagesTable extends AssistantMessages
    with TableInfo<$AssistantMessagesTable, AssistantMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
    'is_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user" IN (0, 1))',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaJsonMeta = const VerificationMeta(
    'metaJson',
  );
  @override
  late final GeneratedColumn<String> metaJson = GeneratedColumn<String>(
    'meta_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isUser,
    content,
    metaJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('is_user')) {
      context.handle(
        _isUserMeta,
        isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta),
      );
    } else if (isInserting) {
      context.missing(_isUserMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('meta_json')) {
      context.handle(
        _metaJsonMeta,
        metaJson.isAcceptableOrUnknown(data['meta_json']!, _metaJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      metaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssistantMessagesTable createAlias(String alias) {
    return $AssistantMessagesTable(attachedDatabase, alias);
  }
}

class AssistantMessage extends DataClass
    implements Insertable<AssistantMessage> {
  final int id;
  final bool isUser;
  final String content;

  /// JSON：items / actionLabel / actionRoute
  final String? metaJson;
  final DateTime createdAt;
  const AssistantMessage({
    required this.id,
    required this.isUser,
    required this.content,
    this.metaJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_user'] = Variable<bool>(isUser);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || metaJson != null) {
      map['meta_json'] = Variable<String>(metaJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssistantMessagesCompanion toCompanion(bool nullToAbsent) {
    return AssistantMessagesCompanion(
      id: Value(id),
      isUser: Value(isUser),
      content: Value(content),
      metaJson: metaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metaJson),
      createdAt: Value(createdAt),
    );
  }

  factory AssistantMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantMessage(
      id: serializer.fromJson<int>(json['id']),
      isUser: serializer.fromJson<bool>(json['isUser']),
      content: serializer.fromJson<String>(json['content']),
      metaJson: serializer.fromJson<String?>(json['metaJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isUser': serializer.toJson<bool>(isUser),
      'content': serializer.toJson<String>(content),
      'metaJson': serializer.toJson<String?>(metaJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssistantMessage copyWith({
    int? id,
    bool? isUser,
    String? content,
    Value<String?> metaJson = const Value.absent(),
    DateTime? createdAt,
  }) => AssistantMessage(
    id: id ?? this.id,
    isUser: isUser ?? this.isUser,
    content: content ?? this.content,
    metaJson: metaJson.present ? metaJson.value : this.metaJson,
    createdAt: createdAt ?? this.createdAt,
  );
  AssistantMessage copyWithCompanion(AssistantMessagesCompanion data) {
    return AssistantMessage(
      id: data.id.present ? data.id.value : this.id,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      content: data.content.present ? data.content.value : this.content,
      metaJson: data.metaJson.present ? data.metaJson.value : this.metaJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessage(')
          ..write('id: $id, ')
          ..write('isUser: $isUser, ')
          ..write('content: $content, ')
          ..write('metaJson: $metaJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, isUser, content, metaJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantMessage &&
          other.id == this.id &&
          other.isUser == this.isUser &&
          other.content == this.content &&
          other.metaJson == this.metaJson &&
          other.createdAt == this.createdAt);
}

class AssistantMessagesCompanion extends UpdateCompanion<AssistantMessage> {
  final Value<int> id;
  final Value<bool> isUser;
  final Value<String> content;
  final Value<String?> metaJson;
  final Value<DateTime> createdAt;
  const AssistantMessagesCompanion({
    this.id = const Value.absent(),
    this.isUser = const Value.absent(),
    this.content = const Value.absent(),
    this.metaJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssistantMessagesCompanion.insert({
    this.id = const Value.absent(),
    required bool isUser,
    required String content,
    this.metaJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : isUser = Value(isUser),
       content = Value(content);
  static Insertable<AssistantMessage> custom({
    Expression<int>? id,
    Expression<bool>? isUser,
    Expression<String>? content,
    Expression<String>? metaJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isUser != null) 'is_user': isUser,
      if (content != null) 'content': content,
      if (metaJson != null) 'meta_json': metaJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssistantMessagesCompanion copyWith({
    Value<int>? id,
    Value<bool>? isUser,
    Value<String>? content,
    Value<String?>? metaJson,
    Value<DateTime>? createdAt,
  }) {
    return AssistantMessagesCompanion(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      content: content ?? this.content,
      metaJson: metaJson ?? this.metaJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (metaJson.present) {
      map['meta_json'] = Variable<String>(metaJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessagesCompanion(')
          ..write('id: $id, ')
          ..write('isUser: $isUser, ')
          ..write('content: $content, ')
          ..write('metaJson: $metaJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UsageRecordsTable usageRecords = $UsageRecordsTable(this);
  late final $ShoppingListTable shoppingList = $ShoppingListTable(this);
  late final $FamilyMembersTable familyMembers = $FamilyMembersTable(this);
  late final $AlertReadStatesTable alertReadStates = $AlertReadStatesTable(
    this,
  );
  late final $AssistantMessagesTable assistantMessages =
      $AssistantMessagesTable(this);
  late final Index alertReadUnique = Index(
    'alert_read_unique',
    'CREATE UNIQUE INDEX alert_read_unique ON alert_read_states (item_id, alert_type, family_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    locations,
    items,
    usageRecords,
    shoppingList,
    familyMembers,
    alertReadStates,
    assistantMessages,
    alertReadUnique,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String icon,
      required String color,
      Value<int?> parentId,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<String> color,
      Value<int?> parentId,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                sortOrder: sortOrder,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                required String color,
                Value<int?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                sortOrder: sortOrder,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> icon,
      Value<String?> images,
      Value<int?> parentId,
      Value<int> level,
      required String fullPath,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> icon,
      Value<String?> images,
      Value<int?> parentId,
      Value<int> level,
      Value<String> fullPath,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullPath => $composableBuilder(
    column: $table.fullPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullPath => $composableBuilder(
    column: $table.fullPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get fullPath =>
      $composableBuilder(column: $table.fullPath, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
          Location,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> fullPath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                name: name,
                icon: icon,
                images: images,
                parentId: parentId,
                level: level,
                fullPath: fullPath,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> level = const Value.absent(),
                required String fullPath,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                images: images,
                parentId: parentId,
                level: level,
                fullPath: fullPath,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
      Location,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> brand,
      Value<String?> specification,
      Value<String?> barcode,
      required int categoryId,
      Value<int?> locationId,
      Value<String?> containerName,
      Value<double?> purchasePrice,
      Value<double?> salePrice,
      Value<String?> supplier,
      Value<int> purchaseQuantity,
      Value<String?> packageUnit,
      Value<int> packageQuantity,
      Value<double> currentQuantity,
      Value<String> unit,
      Value<double> safetyStock,
      Value<DateTime?> purchaseDate,
      Value<String?> purchaseChannel,
      Value<DateTime?> productionDate,
      Value<DateTime?> expiryDate,
      Value<int?> shelfLifeDays,
      Value<DateTime?> openedDate,
      Value<int?> afterOpenDays,
      Value<DateTime?> warrantyDate,
      Value<int> expiryAlertDays,
      Value<bool> stockAlert,
      Value<String?> images,
      Value<String?> notes,
      Value<int> status,
      Value<double?> avgDailyConsumption,
      Value<DateTime?> predictedEmptyDate,
      Value<DateTime?> lastUsedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> serverItemId,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> brand,
      Value<String?> specification,
      Value<String?> barcode,
      Value<int> categoryId,
      Value<int?> locationId,
      Value<String?> containerName,
      Value<double?> purchasePrice,
      Value<double?> salePrice,
      Value<String?> supplier,
      Value<int> purchaseQuantity,
      Value<String?> packageUnit,
      Value<int> packageQuantity,
      Value<double> currentQuantity,
      Value<String> unit,
      Value<double> safetyStock,
      Value<DateTime?> purchaseDate,
      Value<String?> purchaseChannel,
      Value<DateTime?> productionDate,
      Value<DateTime?> expiryDate,
      Value<int?> shelfLifeDays,
      Value<DateTime?> openedDate,
      Value<int?> afterOpenDays,
      Value<DateTime?> warrantyDate,
      Value<int> expiryAlertDays,
      Value<bool> stockAlert,
      Value<String?> images,
      Value<String?> notes,
      Value<int> status,
      Value<double?> avgDailyConsumption,
      Value<DateTime?> predictedEmptyDate,
      Value<DateTime?> lastUsedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> serverItemId,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specification => $composableBuilder(
    column: $table.specification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerName => $composableBuilder(
    column: $table.containerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get safetyStock => $composableBuilder(
    column: $table.safetyStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfLifeDays => $composableBuilder(
    column: $table.shelfLifeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedDate => $composableBuilder(
    column: $table.openedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get warrantyDate => $composableBuilder(
    column: $table.warrantyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiryAlertDays => $composableBuilder(
    column: $table.expiryAlertDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stockAlert => $composableBuilder(
    column: $table.stockAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgDailyConsumption => $composableBuilder(
    column: $table.avgDailyConsumption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get predictedEmptyDate => $composableBuilder(
    column: $table.predictedEmptyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverItemId => $composableBuilder(
    column: $table.serverItemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specification => $composableBuilder(
    column: $table.specification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerName => $composableBuilder(
    column: $table.containerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get safetyStock => $composableBuilder(
    column: $table.safetyStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfLifeDays => $composableBuilder(
    column: $table.shelfLifeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedDate => $composableBuilder(
    column: $table.openedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get warrantyDate => $composableBuilder(
    column: $table.warrantyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiryAlertDays => $composableBuilder(
    column: $table.expiryAlertDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stockAlert => $composableBuilder(
    column: $table.stockAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgDailyConsumption => $composableBuilder(
    column: $table.avgDailyConsumption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get predictedEmptyDate => $composableBuilder(
    column: $table.predictedEmptyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverItemId => $composableBuilder(
    column: $table.serverItemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get specification => $composableBuilder(
    column: $table.specification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get containerName => $composableBuilder(
    column: $table.containerName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<int> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get safetyStock => $composableBuilder(
    column: $table.safetyStock,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfLifeDays => $composableBuilder(
    column: $table.shelfLifeDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedDate => $composableBuilder(
    column: $table.openedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get warrantyDate => $composableBuilder(
    column: $table.warrantyDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiryAlertDays => $composableBuilder(
    column: $table.expiryAlertDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get stockAlert => $composableBuilder(
    column: $table.stockAlert,
    builder: (column) => column,
  );

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get avgDailyConsumption => $composableBuilder(
    column: $table.avgDailyConsumption,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get predictedEmptyDate => $composableBuilder(
    column: $table.predictedEmptyDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverItemId => $composableBuilder(
    column: $table.serverItemId,
    builder: (column) => column,
  );
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> specification = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> locationId = const Value.absent(),
                Value<String?> containerName = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double?> salePrice = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<int> purchaseQuantity = const Value.absent(),
                Value<String?> packageUnit = const Value.absent(),
                Value<int> packageQuantity = const Value.absent(),
                Value<double> currentQuantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> safetyStock = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> purchaseChannel = const Value.absent(),
                Value<DateTime?> productionDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> shelfLifeDays = const Value.absent(),
                Value<DateTime?> openedDate = const Value.absent(),
                Value<int?> afterOpenDays = const Value.absent(),
                Value<DateTime?> warrantyDate = const Value.absent(),
                Value<int> expiryAlertDays = const Value.absent(),
                Value<bool> stockAlert = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> avgDailyConsumption = const Value.absent(),
                Value<DateTime?> predictedEmptyDate = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> serverItemId = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                brand: brand,
                specification: specification,
                barcode: barcode,
                categoryId: categoryId,
                locationId: locationId,
                containerName: containerName,
                purchasePrice: purchasePrice,
                salePrice: salePrice,
                supplier: supplier,
                purchaseQuantity: purchaseQuantity,
                packageUnit: packageUnit,
                packageQuantity: packageQuantity,
                currentQuantity: currentQuantity,
                unit: unit,
                safetyStock: safetyStock,
                purchaseDate: purchaseDate,
                purchaseChannel: purchaseChannel,
                productionDate: productionDate,
                expiryDate: expiryDate,
                shelfLifeDays: shelfLifeDays,
                openedDate: openedDate,
                afterOpenDays: afterOpenDays,
                warrantyDate: warrantyDate,
                expiryAlertDays: expiryAlertDays,
                stockAlert: stockAlert,
                images: images,
                notes: notes,
                status: status,
                avgDailyConsumption: avgDailyConsumption,
                predictedEmptyDate: predictedEmptyDate,
                lastUsedAt: lastUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverItemId: serverItemId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> specification = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required int categoryId,
                Value<int?> locationId = const Value.absent(),
                Value<String?> containerName = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double?> salePrice = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<int> purchaseQuantity = const Value.absent(),
                Value<String?> packageUnit = const Value.absent(),
                Value<int> packageQuantity = const Value.absent(),
                Value<double> currentQuantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> safetyStock = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> purchaseChannel = const Value.absent(),
                Value<DateTime?> productionDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> shelfLifeDays = const Value.absent(),
                Value<DateTime?> openedDate = const Value.absent(),
                Value<int?> afterOpenDays = const Value.absent(),
                Value<DateTime?> warrantyDate = const Value.absent(),
                Value<int> expiryAlertDays = const Value.absent(),
                Value<bool> stockAlert = const Value.absent(),
                Value<String?> images = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> avgDailyConsumption = const Value.absent(),
                Value<DateTime?> predictedEmptyDate = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> serverItemId = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                specification: specification,
                barcode: barcode,
                categoryId: categoryId,
                locationId: locationId,
                containerName: containerName,
                purchasePrice: purchasePrice,
                salePrice: salePrice,
                supplier: supplier,
                purchaseQuantity: purchaseQuantity,
                packageUnit: packageUnit,
                packageQuantity: packageQuantity,
                currentQuantity: currentQuantity,
                unit: unit,
                safetyStock: safetyStock,
                purchaseDate: purchaseDate,
                purchaseChannel: purchaseChannel,
                productionDate: productionDate,
                expiryDate: expiryDate,
                shelfLifeDays: shelfLifeDays,
                openedDate: openedDate,
                afterOpenDays: afterOpenDays,
                warrantyDate: warrantyDate,
                expiryAlertDays: expiryAlertDays,
                stockAlert: stockAlert,
                images: images,
                notes: notes,
                status: status,
                avgDailyConsumption: avgDailyConsumption,
                predictedEmptyDate: predictedEmptyDate,
                lastUsedAt: lastUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverItemId: serverItemId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$UsageRecordsTableCreateCompanionBuilder =
    UsageRecordsCompanion Function({
      Value<int> id,
      required int itemId,
      required int type,
      required double quantity,
      required double remainingQuantity,
      Value<String?> operatorName,
      Value<int?> serverRecordId,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$UsageRecordsTableUpdateCompanionBuilder =
    UsageRecordsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<int> type,
      Value<double> quantity,
      Value<double> remainingQuantity,
      Value<String?> operatorName,
      Value<int?> serverRecordId,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$UsageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRecordId => $composableBuilder(
    column: $table.serverRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRecordId => $composableBuilder(
    column: $table.serverRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRecordId => $composableBuilder(
    column: $table.serverRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsageRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageRecordsTable,
          UsageRecord,
          $$UsageRecordsTableFilterComposer,
          $$UsageRecordsTableOrderingComposer,
          $$UsageRecordsTableAnnotationComposer,
          $$UsageRecordsTableCreateCompanionBuilder,
          $$UsageRecordsTableUpdateCompanionBuilder,
          (
            UsageRecord,
            BaseReferences<_$AppDatabase, $UsageRecordsTable, UsageRecord>,
          ),
          UsageRecord,
          PrefetchHooks Function()
        > {
  $$UsageRecordsTableTableManager(_$AppDatabase db, $UsageRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> remainingQuantity = const Value.absent(),
                Value<String?> operatorName = const Value.absent(),
                Value<int?> serverRecordId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsageRecordsCompanion(
                id: id,
                itemId: itemId,
                type: type,
                quantity: quantity,
                remainingQuantity: remainingQuantity,
                operatorName: operatorName,
                serverRecordId: serverRecordId,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required int type,
                required double quantity,
                required double remainingQuantity,
                Value<String?> operatorName = const Value.absent(),
                Value<int?> serverRecordId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsageRecordsCompanion.insert(
                id: id,
                itemId: itemId,
                type: type,
                quantity: quantity,
                remainingQuantity: remainingQuantity,
                operatorName: operatorName,
                serverRecordId: serverRecordId,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageRecordsTable,
      UsageRecord,
      $$UsageRecordsTableFilterComposer,
      $$UsageRecordsTableOrderingComposer,
      $$UsageRecordsTableAnnotationComposer,
      $$UsageRecordsTableCreateCompanionBuilder,
      $$UsageRecordsTableUpdateCompanionBuilder,
      (
        UsageRecord,
        BaseReferences<_$AppDatabase, $UsageRecordsTable, UsageRecord>,
      ),
      UsageRecord,
      PrefetchHooks Function()
    >;
typedef $$ShoppingListTableCreateCompanionBuilder =
    ShoppingListCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> relatedItemId,
      Value<double> quantity,
      Value<String> unit,
      Value<double?> estimatedPrice,
      Value<bool> isPurchased,
      Value<bool> isAutoGenerated,
      Value<DateTime> createdAt,
    });
typedef $$ShoppingListTableUpdateCompanionBuilder =
    ShoppingListCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> relatedItemId,
      Value<double> quantity,
      Value<String> unit,
      Value<double?> estimatedPrice,
      Value<bool> isPurchased,
      Value<bool> isAutoGenerated,
      Value<DateTime> createdAt,
    });

class $$ShoppingListTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relatedItemId => $composableBuilder(
    column: $table.relatedItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShoppingListTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relatedItemId => $composableBuilder(
    column: $table.relatedItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoppingListTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get relatedItemId => $composableBuilder(
    column: $table.relatedItemId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPurchased => $composableBuilder(
    column: $table.isPurchased,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShoppingListTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingListTable,
          ShoppingListData,
          $$ShoppingListTableFilterComposer,
          $$ShoppingListTableOrderingComposer,
          $$ShoppingListTableAnnotationComposer,
          $$ShoppingListTableCreateCompanionBuilder,
          $$ShoppingListTableUpdateCompanionBuilder,
          (
            ShoppingListData,
            BaseReferences<_$AppDatabase, $ShoppingListTable, ShoppingListData>,
          ),
          ShoppingListData,
          PrefetchHooks Function()
        > {
  $$ShoppingListTableTableManager(_$AppDatabase db, $ShoppingListTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> relatedItemId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> estimatedPrice = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShoppingListCompanion(
                id: id,
                name: name,
                relatedItemId: relatedItemId,
                quantity: quantity,
                unit: unit,
                estimatedPrice: estimatedPrice,
                isPurchased: isPurchased,
                isAutoGenerated: isAutoGenerated,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> relatedItemId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> estimatedPrice = const Value.absent(),
                Value<bool> isPurchased = const Value.absent(),
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShoppingListCompanion.insert(
                id: id,
                name: name,
                relatedItemId: relatedItemId,
                quantity: quantity,
                unit: unit,
                estimatedPrice: estimatedPrice,
                isPurchased: isPurchased,
                isAutoGenerated: isAutoGenerated,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShoppingListTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingListTable,
      ShoppingListData,
      $$ShoppingListTableFilterComposer,
      $$ShoppingListTableOrderingComposer,
      $$ShoppingListTableAnnotationComposer,
      $$ShoppingListTableCreateCompanionBuilder,
      $$ShoppingListTableUpdateCompanionBuilder,
      (
        ShoppingListData,
        BaseReferences<_$AppDatabase, $ShoppingListTable, ShoppingListData>,
      ),
      ShoppingListData,
      PrefetchHooks Function()
    >;
typedef $$FamilyMembersTableCreateCompanionBuilder =
    FamilyMembersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> avatar,
      Value<String> role,
      Value<DateTime> createdAt,
    });
typedef $$FamilyMembersTableUpdateCompanionBuilder =
    FamilyMembersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> avatar,
      Value<String> role,
      Value<DateTime> createdAt,
    });

class $$FamilyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FamilyMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyMembersTable,
          FamilyMember,
          $$FamilyMembersTableFilterComposer,
          $$FamilyMembersTableOrderingComposer,
          $$FamilyMembersTableAnnotationComposer,
          $$FamilyMembersTableCreateCompanionBuilder,
          $$FamilyMembersTableUpdateCompanionBuilder,
          (
            FamilyMember,
            BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMember>,
          ),
          FamilyMember,
          PrefetchHooks Function()
        > {
  $$FamilyMembersTableTableManager(_$AppDatabase db, $FamilyMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FamilyMembersCompanion(
                id: id,
                name: name,
                avatar: avatar,
                role: role,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> avatar = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FamilyMembersCompanion.insert(
                id: id,
                name: name,
                avatar: avatar,
                role: role,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyMembersTable,
      FamilyMember,
      $$FamilyMembersTableFilterComposer,
      $$FamilyMembersTableOrderingComposer,
      $$FamilyMembersTableAnnotationComposer,
      $$FamilyMembersTableCreateCompanionBuilder,
      $$FamilyMembersTableUpdateCompanionBuilder,
      (
        FamilyMember,
        BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMember>,
      ),
      FamilyMember,
      PrefetchHooks Function()
    >;
typedef $$AlertReadStatesTableCreateCompanionBuilder =
    AlertReadStatesCompanion Function({
      Value<int> id,
      required int itemId,
      required String alertType,
      Value<int> familyId,
      Value<DateTime?> readAt,
      Value<bool> ignored,
    });
typedef $$AlertReadStatesTableUpdateCompanionBuilder =
    AlertReadStatesCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<String> alertType,
      Value<int> familyId,
      Value<DateTime?> readAt,
      Value<bool> ignored,
    });

class $$AlertReadStatesTableFilterComposer
    extends Composer<_$AppDatabase, $AlertReadStatesTable> {
  $$AlertReadStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertType => $composableBuilder(
    column: $table.alertType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ignored => $composableBuilder(
    column: $table.ignored,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertReadStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertReadStatesTable> {
  $$AlertReadStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertType => $composableBuilder(
    column: $table.alertType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ignored => $composableBuilder(
    column: $table.ignored,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertReadStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertReadStatesTable> {
  $$AlertReadStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get alertType =>
      $composableBuilder(column: $table.alertType, builder: (column) => column);

  GeneratedColumn<int> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<bool> get ignored =>
      $composableBuilder(column: $table.ignored, builder: (column) => column);
}

class $$AlertReadStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertReadStatesTable,
          AlertReadState,
          $$AlertReadStatesTableFilterComposer,
          $$AlertReadStatesTableOrderingComposer,
          $$AlertReadStatesTableAnnotationComposer,
          $$AlertReadStatesTableCreateCompanionBuilder,
          $$AlertReadStatesTableUpdateCompanionBuilder,
          (
            AlertReadState,
            BaseReferences<
              _$AppDatabase,
              $AlertReadStatesTable,
              AlertReadState
            >,
          ),
          AlertReadState,
          PrefetchHooks Function()
        > {
  $$AlertReadStatesTableTableManager(
    _$AppDatabase db,
    $AlertReadStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertReadStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertReadStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertReadStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> alertType = const Value.absent(),
                Value<int> familyId = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<bool> ignored = const Value.absent(),
              }) => AlertReadStatesCompanion(
                id: id,
                itemId: itemId,
                alertType: alertType,
                familyId: familyId,
                readAt: readAt,
                ignored: ignored,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required String alertType,
                Value<int> familyId = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<bool> ignored = const Value.absent(),
              }) => AlertReadStatesCompanion.insert(
                id: id,
                itemId: itemId,
                alertType: alertType,
                familyId: familyId,
                readAt: readAt,
                ignored: ignored,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertReadStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertReadStatesTable,
      AlertReadState,
      $$AlertReadStatesTableFilterComposer,
      $$AlertReadStatesTableOrderingComposer,
      $$AlertReadStatesTableAnnotationComposer,
      $$AlertReadStatesTableCreateCompanionBuilder,
      $$AlertReadStatesTableUpdateCompanionBuilder,
      (
        AlertReadState,
        BaseReferences<_$AppDatabase, $AlertReadStatesTable, AlertReadState>,
      ),
      AlertReadState,
      PrefetchHooks Function()
    >;
typedef $$AssistantMessagesTableCreateCompanionBuilder =
    AssistantMessagesCompanion Function({
      Value<int> id,
      required bool isUser,
      required String content,
      Value<String?> metaJson,
      Value<DateTime> createdAt,
    });
typedef $$AssistantMessagesTableUpdateCompanionBuilder =
    AssistantMessagesCompanion Function({
      Value<int> id,
      Value<bool> isUser,
      Value<String> content,
      Value<String?> metaJson,
      Value<DateTime> createdAt,
    });

class $$AssistantMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaJson => $composableBuilder(
    column: $table.metaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssistantMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaJson => $composableBuilder(
    column: $table.metaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssistantMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get metaJson =>
      $composableBuilder(column: $table.metaJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AssistantMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssistantMessagesTable,
          AssistantMessage,
          $$AssistantMessagesTableFilterComposer,
          $$AssistantMessagesTableOrderingComposer,
          $$AssistantMessagesTableAnnotationComposer,
          $$AssistantMessagesTableCreateCompanionBuilder,
          $$AssistantMessagesTableUpdateCompanionBuilder,
          (
            AssistantMessage,
            BaseReferences<
              _$AppDatabase,
              $AssistantMessagesTable,
              AssistantMessage
            >,
          ),
          AssistantMessage,
          PrefetchHooks Function()
        > {
  $$AssistantMessagesTableTableManager(
    _$AppDatabase db,
    $AssistantMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isUser = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> metaJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssistantMessagesCompanion(
                id: id,
                isUser: isUser,
                content: content,
                metaJson: metaJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool isUser,
                required String content,
                Value<String?> metaJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssistantMessagesCompanion.insert(
                id: id,
                isUser: isUser,
                content: content,
                metaJson: metaJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssistantMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssistantMessagesTable,
      AssistantMessage,
      $$AssistantMessagesTableFilterComposer,
      $$AssistantMessagesTableOrderingComposer,
      $$AssistantMessagesTableAnnotationComposer,
      $$AssistantMessagesTableCreateCompanionBuilder,
      $$AssistantMessagesTableUpdateCompanionBuilder,
      (
        AssistantMessage,
        BaseReferences<
          _$AppDatabase,
          $AssistantMessagesTable,
          AssistantMessage
        >,
      ),
      AssistantMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$UsageRecordsTableTableManager get usageRecords =>
      $$UsageRecordsTableTableManager(_db, _db.usageRecords);
  $$ShoppingListTableTableManager get shoppingList =>
      $$ShoppingListTableTableManager(_db, _db.shoppingList);
  $$FamilyMembersTableTableManager get familyMembers =>
      $$FamilyMembersTableTableManager(_db, _db.familyMembers);
  $$AlertReadStatesTableTableManager get alertReadStates =>
      $$AlertReadStatesTableTableManager(_db, _db.alertReadStates);
  $$AssistantMessagesTableTableManager get assistantMessages =>
      $$AssistantMessagesTableTableManager(_db, _db.assistantMessages);
}
