// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService.instance;

  // 当前用户流
  // Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // 当前用户
  // User? get currentUser => _auth.currentUser;
  
  // 当前用户ID
  // String? get currentUserId => _auth.currentUser?.uid;
  
  // Mock current user for development
  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  bool get isLoggedIn => _currentUserId != null;
  
  static const String _userIdKey = 'current_user_id';
  
  /// 初始化认证服务，从持久化存储中恢复登录状态
  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web平台使用简化的实现，避免SharedPreferences的兼容性问题
        debugPrint('AuthService initialized for web platform');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString(_userIdKey);
      debugPrint('AuthService initialized, current user ID: $_currentUserId');
    } catch (e) {
      debugPrint('Failed to initialize AuthService: $e');
    }
  }
  
  /// 保存用户ID到持久化存储
  Future<void> _saveCurrentUserId(String userId) async {
    try {
      if (kIsWeb) {
        // Web平台仅在内存中保存
        _currentUserId = userId;
        debugPrint('User ID saved in memory for web: $userId');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      _currentUserId = userId;
      debugPrint('User ID saved to persistent storage: $userId');
    } catch (e) {
      debugPrint('Failed to save user ID: $e');
      _currentUserId = userId; // 至少在内存中保存
    }
  }
  
  /// 清除持久化存储中的用户ID
  Future<void> _clearCurrentUserId() async {
    try {
      if (kIsWeb) {
        // Web平台仅清除内存中的数据
        _currentUserId = null;
        debugPrint('User ID cleared from memory for web');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      _currentUserId = null;
      debugPrint('User ID cleared from persistent storage');
    } catch (e) {
      debugPrint('Failed to clear user ID: $e');
      _currentUserId = null; // 至少在内存中清除
    }
  }

  /// 邮箱密码注册 (Mock implementation)
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // 检查用户名是否已存在
      final existingUser = await _databaseService.getUserByUsername(username);
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: '用户名已存在',
          errorCode: 'username-already-exists',
        );
      }

      // 生成用户ID
      final userId = _generateUserId();
      
      // 创建用户数据模型
      final userModel = UserModel(
        id: userId,
        username: username,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存到本地数据库
      await _databaseService.createUser(userModel);
      
      // 设置当前用户并持久化
      await _saveCurrentUserId(userId);

      return AuthResult(
        success: true,
        user: userModel,
        message: '注册成功',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '注册失败: ${e.toString()}',
        errorCode: 'unknown-error',
      );
    }
  }
  
  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// 邮箱密码登录 (Mock implementation)
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting login with email: $email');
      
      // 验证输入参数
      if (email.isEmpty || password.isEmpty) {
        debugPrint('Login failed: Empty email or password');
        return AuthResult(
          success: false,
          message: '邮箱和密码不能为空',
          errorCode: 'invalid-input',
        );
      }

      // 从本地数据库获取用户信息
      debugPrint('Looking up user by email: $email');
      UserModel? userModel = await _databaseService.getUserByEmail(email);
      
      if (userModel == null) {
        debugPrint('User not found for email: $email');
        // 为了演示，如果用户不存在，创建一个默认用户
        debugPrint('Creating default user for demo purposes');
        final userId = _generateUserId();
        userModel = UserModel(
          id: userId,
          username: email.split('@')[0],
          email: email,
          displayName: email.split('@')[0],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        try {
          await _databaseService.createUser(userModel);
          debugPrint('Default user created successfully');
        } catch (e) {
          debugPrint('Failed to create default user: $e');
          // 即使创建用户失败，也允许登录
        }
      }
      
      // 简单的密码验证 (在实际应用中应该使用哈希验证)
      // 这里为了演示，我们假设密码验证通过
      debugPrint('Password validation passed (demo mode)');
      
      // 设置当前用户并持久化
      await _saveCurrentUserId(userModel.id);
      debugPrint('Login successful for user: ${userModel.id}');

      return AuthResult(
        success: true,
        user: userModel,
        message: '登录成功',
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return AuthResult(
        success: false,
        message: '登录失败: ${e.toString()}',
        errorCode: 'authentication-error',
      );
    }
  }

  /// Google登录 (Mock implementation)
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Mock Google 登录 - 创建一个测试用户
      final userId = _generateUserId();
      final userModel = UserModel(
        id: userId,
        username: 'google_user',
        email: 'google@example.com',
        displayName: 'Google User',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _databaseService.createUser(userModel);
      await _saveCurrentUserId(userId);

      return AuthResult(
        success: true,
        user: userModel,
        message: '登录成功',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '登录失败: $e',
        errorCode: 'google-sign-in-error',
      );
    }
  }

  /// 发送密码重置邮件 (Mock implementation)
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      // Mock implementation - 检查用户是否存在
      final user = await _databaseService.getUserByEmail(email);
      if (user == null) {
        return AuthResult(
          success: false,
          message: '用户不存在',
          errorCode: 'user-not-found',
        );
      }
      
      return AuthResult(
        success: true,
        message: '密码重置邮件已发送',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '发送失败: ${e.toString()}',
        errorCode: 'unknown-error',
      );
    }
  }

  /// 更新用户资料 (Mock implementation)
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      if (_currentUserId == null) {
        return AuthResult(
          success: false,
          message: '用户未登录',
          errorCode: 'user-not-signed-in',
        );
      }

      // 更新本地数据库
      final userModel = await _databaseService.getUser(_currentUserId!);
      if (userModel != null) {
        final updatedUser = userModel.copyWith(
          displayName: displayName ?? userModel.displayName,
          avatarUrl: photoURL ?? userModel.avatarUrl,
          bio: bio ?? userModel.bio,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateUser(updatedUser);

        return AuthResult(
          success: true,
          user: updatedUser,
          message: '资料更新成功',
        );
      }

      return AuthResult(
        success: false,
        message: '用户信息不存在',
        errorCode: 'user-not-found',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '更新失败: ${e.toString()}',
        errorCode: 'update-failed',
      );
    }
  }

  /// 登出 (Mock implementation)
  Future<void> signOut() async {
    await _clearCurrentUserId();
  }

  /// 删除账户 (Mock implementation)
  Future<AuthResult> deleteAccount() async {
    try {
      if (_currentUserId == null) {
        return AuthResult(
          success: false,
          message: '用户未登录',
          errorCode: 'user-not-signed-in',
        );
      }

      // 删除本地数据
      await _databaseService.deleteUser(_currentUserId!);
      
      // 清除当前用户
      await _clearCurrentUserId();

      return AuthResult(
        success: true,
        message: '账户删除成功',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '删除失败: ${e.toString()}',
        errorCode: 'delete-failed',
      );
    }
  }

  // /// 生成唯一用户名
  // Future<String> _generateUniqueUsername(String baseName) async {
  //   String username = baseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  //   
  //   // 检查用户名是否已存在
  //   UserModel? existingUser = await _databaseService.getUserByUsername(username);
  //   
  //   if (existingUser == null) {
  //     return username;
  //   }

  //   // 如果已存在，添加随机数字
  //   int counter = 1;
  //   while (existingUser != null) {
  //     String newUsername = '${username}_$counter';
  //     existingUser = await _databaseService.getUserByUsername(newUsername);
  //     if (existingUser == null) {
  //       return newUsername;
  //     }
  //     counter++;
  //   }

  //   return '${username}_${Random().nextInt(9999)}';
  // }

  // /// 获取错误信息
  // String _getErrorMessage(String errorCode) {
  //   switch (errorCode) {
  //     case 'weak-password':
  //       return '密码强度不够';
  //     case 'email-already-in-use':
  //       return '邮箱已被使用';
  //     case 'invalid-email':
  //       return '邮箱格式不正确';
  //     case 'user-not-found':
  //       return '用户不存在';
  //     case 'wrong-password':
  //       return '密码错误';
  //     case 'user-disabled':
  //       return '用户已被禁用';
  //     case 'too-many-requests':
  //       return '请求过于频繁，请稍后再试';
  //     case 'operation-not-allowed':
  //       return '操作不被允许';
  //     case 'requires-recent-login':
  //       return '需要重新登录';
  //     default:
  //       return '认证失败: $errorCode';
  //   }
  // }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String message;
  final String? errorCode;

  AuthResult({
    required this.success,
    this.user,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, errorCode: $errorCode)';
  }
}