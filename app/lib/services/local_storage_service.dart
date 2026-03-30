import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Database? _database;
  static LocalStorageService? _instance;

  factory LocalStorageService() {
    _instance ??= LocalStorageService._internal();
    return _instance!;
  }

  LocalStorageService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'home_ware.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            username TEXT,
            email TEXT,
            token TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS families (
            id INTEGER PRIMARY KEY,
            name TEXT,
            created_by INTEGER,
            created_at TEXT
          )
        ''');
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY,
            name TEXT,
            family_id INTEGER,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            family_id INTEGER,
            created_at TEXT
          )
        ''');
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
    );
  }

  // 保存用户信息
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token']);
  }

  // 获取用户信息
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final results = await db.query('users', limit: 1);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // 清除用户信息
  Future<void> clearUser() async {
    final db = await database;
    await db.delete('users');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // 保存家庭列表
  Future<void> saveFamilies(List<dynamic> families) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('families');
    for (var family in families) {
      batch.insert('families', {
        'id': family['id'],
        'name': family['name'],
        'created_by': family['created_by'],
        'created_at': family['created_at'],
      });
    }
    await batch.commit();
  }

  // 获取家庭列表
  Future<List<Map<String, dynamic>>> getFamilies() async {
    final db = await database;
    return await db.query('families');
  }

  // 保存物品
  Future<int> saveItem(Map<String, dynamic> item) async {
    final db = await database;
    final id = await db.insert('items', item, conflictAlgorithm: ConflictAlgorithm.replace);
    await addToSyncQueue('upsert', 'items', item);
    return id;
  }

  // 获取物品列表
  Future<List<Map<String, dynamic>>> getItems({int? familyId}) async {
    final db = await database;
    if (familyId != null) {
      return await db.query('items', where: 'family_id = ?', whereArgs: [familyId]);
    }
    return await db.query('items');
  }

  // 删除物品
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('delete', 'items', {'id': id});
  }

  // 保存分类
  Future<int> saveCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 获取分类列表
  Future<List<Map<String, dynamic>>> getCategories(int familyId) async {
    final db = await database;
    return await db.query('categories', where: 'family_id = ?', whereArgs: [familyId]);
  }

  // 保存位置
  Future<int> saveLocation(Map<String, dynamic> location) async {
    final db = await database;
    return await db.insert('locations', location, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 获取位置列表
  Future<List<Map<String, dynamic>>> getLocations(int familyId) async {
    final db = await database;
    return await db.query('locations', where: 'family_id = ?', whereArgs: [familyId]);
  }

  // 添加到同步队列
  Future<void> addToSyncQueue(String action, String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'action': action,
      'table_name': tableName,
      'data': data.toString(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 获取同步队列
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at');
  }

  // 清除同步队列
  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  // 标记物品为已同步
  Future<void> markItemAsSynced(int id) async {
    final db = await database;
    await db.update('items', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
