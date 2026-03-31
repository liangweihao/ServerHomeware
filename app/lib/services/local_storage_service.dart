import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务类，用于处理应用的本地数据存储和管理
class LocalStorageService {
  /// 数据库实例
  static Database? _database;
  /// 单例实例
  static LocalStorageService? _instance;

  /// 工厂构造函数，实现单例模式
  factory LocalStorageService() {
    _instance ??= LocalStorageService._internal();
    return _instance!;
  }

  /// 私有构造函数
  LocalStorageService._internal();

  /// 获取数据库实例，懒加载模式
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  /// 创建必要的表结构，包括用户、家庭、家庭成员、物品、分类、位置和同步队列
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'home_ware.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // 创建用户表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            username TEXT,
            email TEXT,
            token TEXT
          )
        ''');
        // 创建家庭表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS families (
            id INTEGER PRIMARY KEY,
            name TEXT,
            invite_code TEXT,
            created_by INTEGER,
            created_by_username TEXT,
            created_at TEXT
          )
        ''');
        // 创建家庭成员表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS family_members (
            id INTEGER PRIMARY KEY,
            family_id INTEGER,
            username TEXT,
            email TEXT,
            role TEXT,
            joined_at TEXT
          )
        ''');
        // 创建物品表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            category_id INTEGER,
            location_id INTEGER,
            quantity INTEGER,
            unit TEXT,
            expiry_date TEXT,
            purchase_date TEXT,
            price REAL,
            family_id INTEGER,
            created_by INTEGER,
            created_at TEXT,
            updated_at TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
        // 创建分类表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY,
            name TEXT,
            family_id INTEGER,
            created_at TEXT
          )
        ''');
        // 创建位置表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            family_id INTEGER,
            created_at TEXT
          )
        ''');
        // 创建同步队列表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            table_name TEXT,
            data TEXT,
            created_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 数据库版本升级处理
        if (oldVersion < 2) {
          // 添加家庭表的新字段
          await db.execute('ALTER TABLE families ADD COLUMN invite_code TEXT');
          await db.execute('ALTER TABLE families ADD COLUMN created_by_username TEXT');
          // 创建家庭成员表
          await db.execute('''
            CREATE TABLE IF NOT EXISTS family_members (
              id INTEGER PRIMARY KEY,
              family_id INTEGER,
              username TEXT,
              email TEXT,
              role TEXT,
              joined_at TEXT
            )
          ''');
        }
      },
    );
  }

  /// 用户相关方法
  
  /// 保存用户信息
  /// [userData] 用户数据，包含id、username、email和token
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
    // 同时将token保存到SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token']);
  }

  /// 获取用户信息
  /// 返回用户数据，如果没有则返回null
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final results = await db.query('users', limit: 1);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// 清除用户信息
  Future<void> clearUser() async {
    final db = await database;
    await db.delete('users');
    // 同时从SharedPreferences中移除token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// 家庭相关方法
  
  /// 保存家庭列表
  /// [families] 家庭列表数据
  Future<void> saveFamilies(List<dynamic> families) async {
    final db = await database;
    final batch = db.batch();
    // 先清空现有数据
    await db.delete('families');
    await db.delete('family_members');
    // 批量插入家庭和成员数据
    for (var family in families) {
      batch.insert('families', {
        'id': family['id'],
        'name': family['name'],
        'invite_code': family['invite_code'] ?? '',
        'created_by': family['created_by'],
        'created_by_username': family['created_by_username'] ?? '',
        'created_at': family['created_at'],
      });
      // 处理家庭成员
      if (family['members'] != null) {
        for (var member in family['members']) {
          batch.insert('family_members', {
            'id': member['id'],
            'family_id': family['id'],
            'username': member['username'] ?? '',
            'email': member['email'] ?? '',
            'role': member['role'] ?? 'member',
            'joined_at': member['joined_at'],
          });
        }
      }
    }
    await batch.commit();
  }

  /// 获取家庭列表
  /// 返回包含家庭成员信息的家庭列表
  Future<List<Map<String, dynamic>>> getFamilies() async {
    final db = await database;
    final families = await db.query('families');
    // 为每个家庭加载成员信息
    for (var family in families) {
      final members = await db.query('family_members',
          where: 'family_id = ?', whereArgs: [family['id']]);
      family['members'] = members;
    }
    return families;
  }

  /// 物品相关方法
  
  /// 保存物品
  /// [item] 物品数据
  /// 返回插入的物品ID
  Future<int> saveItem(Map<String, dynamic> item) async {
    final db = await database;
    final id = await db.insert('items', item, conflictAlgorithm: ConflictAlgorithm.replace);
    // 添加到同步队列
    await addToSyncQueue('upsert', 'items', item);
    return id;
  }

  /// 获取物品列表
  /// [familyId] 家庭ID（可选）
  /// 返回物品列表
  Future<List<Map<String, dynamic>>> getItems({int? familyId}) async {
    final db = await database;
    if (familyId != null) {
      return await db.query('items', where: 'family_id = ?', whereArgs: [familyId]);
    }
    return await db.query('items');
  }

  /// 删除物品
  /// [id] 物品ID
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    // 添加到同步队列
    await addToSyncQueue('delete', 'items', {'id': id});
  }

  /// 分类相关方法
  
  /// 保存分类
  /// [category] 分类数据
  /// 返回插入的分类ID
  Future<int> saveCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 获取分类列表
  /// [familyId] 家庭ID
  /// 返回分类列表
  Future<List<Map<String, dynamic>>> getCategories(int familyId) async {
    final db = await database;
    return await db.query('categories', where: 'family_id = ?', whereArgs: [familyId]);
  }

  /// 位置相关方法
  
  /// 保存位置
  /// [location] 位置数据
  /// 返回插入的位置ID
  Future<int> saveLocation(Map<String, dynamic> location) async {
    final db = await database;
    return await db.insert('locations', location, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 获取位置列表
  /// [familyId] 家庭ID
  /// 返回位置列表
  Future<List<Map<String, dynamic>>> getLocations(int familyId) async {
    final db = await database;
    return await db.query('locations', where: 'family_id = ?', whereArgs: [familyId]);
  }

  /// 同步队列相关方法
  
  /// 添加到同步队列
  /// [action] 操作类型（upsert/delete）
  /// [tableName] 表名
  /// [data] 操作数据
  Future<void> addToSyncQueue(String action, String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'action': action,
      'table_name': tableName,
      'data': data.toString(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 获取同步队列
  /// 返回同步队列列表
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at');
  }

  /// 清除同步队列
  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  /// 标记物品为已同步
  /// [id] 物品ID
  Future<void> markItemAsSynced(int id) async {
    final db = await database;
    await db.update('items', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
