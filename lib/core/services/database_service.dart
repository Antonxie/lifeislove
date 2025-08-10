import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/message_model.dart';
import '../models/calendar_event_model.dart';
import '../models/rag_data_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;
  static bool _isInitializing = false;
  static Completer<Database>? _initCompleter;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    // 如果数据库已经初始化，直接返回
    if (_database != null) {
      return _database!;
    }
    
    // 如果正在初始化，等待初始化完成
    if (_isInitializing && _initCompleter != null) {
      return await _initCompleter!.future;
    }
    
    // 开始初始化
    _isInitializing = true;
    _initCompleter = Completer<Database>();
    
    try {
      _database = await initDatabase();
      _initCompleter!.complete(_database!);
      return _database!;
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
  
  Future<Database> initDatabase() async {
    debugPrint('Initializing database...');
    
    if (kIsWeb) {
      debugPrint('Using simplified web storage');
      return await _createWebDatabase();
    } else {
      // 非Web平台的数据库初始化逻辑
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'social_life.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    }
  }
  
  // Web平台的简化数据库实现
  Future<Database> _createWebDatabase() async {
    debugPrint('Creating web database...');
    
    try {
      // 完全跳过 sqflite，使用内存存储模拟数据库
      debugPrint('Using in-memory storage instead of sqflite for web');
      return await _createInMemoryDatabase();
    } catch (e) {
      debugPrint('Web database creation failed: $e');
      rethrow;
    }
  }
  
  // 完全不依赖 sqflite 的内存数据库实现
  Future<Database> _createInMemoryDatabase() async {
    debugPrint('Creating in-memory database for web platform');
    
    try {
      // 创建一个假的数据库对象，实际使用内存存储
      debugPrint('Creating web-compatible database wrapper');
      final db = _WebDatabase();
      debugPrint('In-memory database created successfully');
      return db;
    } catch (e) {
      debugPrint('In-memory database creation failed: $e');
      throw Exception('Unable to create in-memory database: $e');
    }
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    try {
      debugPrint('Creating database tables...');
      
      // 只创建最基本的用户表来测试
      debugPrint('Creating users table...');
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL,
          email TEXT NOT NULL,
          displayName TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');
      
      debugPrint('Users table created successfully');
      debugPrint('Database creation completed successfully');
    } catch (e) {
      debugPrint('Error creating database: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }
  
  // User operations
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }
  
  Future<int> createUser(UserModel user) async {
    return await insertUser(user);
  }
  
  Future<UserModel?> getUser(String id) async {
    return await getUserById(id);
  }
  
  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }
  
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  
  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Web平台的数据库模拟实现
class _WebDatabase implements Database {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  
  _WebDatabase() {
    // 初始化用户表
    _tables['users'] = [];
  }
  
  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    _tables[table]!.add(Map<String, dynamic>.from(values));
    return _tables[table]!.length; // 返回插入后的行数作为ID
  }
  
  @override
  Future<List<Map<String, Object?>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    if (!_tables.containsKey(table)) {
      return [];
    }
    
    List<Map<String, dynamic>> results = List.from(_tables[table]!);
    
    // 简单的 where 条件处理
     if (where != null && whereArgs != null) {
       if (where.contains('id = ?') && whereArgs.isNotEmpty) {
         results = results.where((row) => row['id'] == whereArgs[0]).toList();
       } else if (where.contains('email = ?') && whereArgs.isNotEmpty) {
         results = results.where((row) => row['email'] == whereArgs[0]).toList();
       } else if (where.contains('username = ?') && whereArgs.isNotEmpty) {
         results = results.where((row) => row['username'] == whereArgs[0]).toList();
       }
     }
    
    return results.cast<Map<String, Object?>>();
  }
  
  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }
    
    int updatedCount = 0;
    if (where != null && whereArgs != null) {
      if (where.contains('id = ?') && whereArgs.isNotEmpty) {
        for (int i = 0; i < _tables[table]!.length; i++) {
          if (_tables[table]![i]['id'] == whereArgs[0]) {
            _tables[table]![i].addAll(Map<String, dynamic>.from(values));
            updatedCount++;
          }
        }
      }
    }
    return updatedCount;
  }
  
  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    if (!_tables.containsKey(table)) {
      return 0;
    }
    
    int deletedCount = 0;
    if (where != null && whereArgs != null) {
      if (where.contains('id = ?') && whereArgs.isNotEmpty) {
        _tables[table]!.removeWhere((row) {
          if (row['id'] == whereArgs[0]) {
            deletedCount++;
            return true;
          }
          return false;
        });
      }
    }
    return deletedCount;
  }
  
  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // 对于 CREATE TABLE 语句，我们只需要确保表存在
    if (sql.toUpperCase().contains('CREATE TABLE')) {
      // 解析表名（简单实现）
      if (sql.contains('users')) {
        _tables['users'] = [];
      }
    }
  }
  
  // 实现其他必需的方法（简单返回默认值）
  @override
  Future<void> close() async {}
  
  @override
  bool get isOpen => true;
  
  @override
  String get path => ':memory:';
  
  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) async {
    // 简单实现：直接执行action
    return await action(this as Transaction);
  }
  
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    return [];
  }
  
  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return 0;
  }
  
  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return 0;
  }
  
  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    return 0;
  }
  
  @override
  Batch batch() {
    throw UnimplementedError('Batch operations not implemented');
  }
  
  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) async {
    return await action(this as Transaction);
  }
  
  @override
  Future<T> writeTransaction<T>(Future<T> Function(Transaction txn) action) async {
    return await action(this as Transaction);
  }
  
  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) async {
    throw UnimplementedError('devInvokeMethod not implemented');
  }
  
  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql, [List<Object?>? arguments]) async {
    throw UnimplementedError('devInvokeSqlMethod not implemented');
  }
  
  @override
  Database get database => this;
  
  @override
  Future<QueryCursor> queryCursor(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset, int? bufferSize}) async {
    throw UnimplementedError('queryCursor not implemented');
  }
  
  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments, {int? bufferSize}) async {
    throw UnimplementedError('rawQueryCursor not implemented');
  }
}