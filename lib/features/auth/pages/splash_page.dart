import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import 'login_page.dart';
import '../../home/pages/main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  Timer? _timeoutTimer;
  bool _isInitializationComplete = false;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimeoutTimer();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_isInitializationComplete && mounted) {
        setState(() {
          _hasTimedOut = true;
        });
        debugPrint('启动超时：初始化过程超过10秒');
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('启动超时'),
          content: const Text(
            '应用启动时间过长，可能存在以下问题：\n\n'
            '1. 网络连接不稳定\n'
            '2. 数据库初始化失败\n'
            '3. 认证服务响应缓慢\n\n'
            '请选择下一步操作：',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryInitialization();
              },
              child: const Text('重试'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceNavigateToLogin();
              },
              child: const Text('跳过并继续'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDiagnosticInfo();
              },
              child: const Text('查看详情'),
            ),
          ],
        );
      },
    );
  }

  void _retryInitialization() {
    setState(() {
      _hasTimedOut = false;
      _isInitializationComplete = false;
    });
    _timeoutTimer?.cancel();
    _startTimeoutTimer();
    _initializeApp();
  }

  void _forceNavigateToLogin() {
    _timeoutTimer?.cancel();
    _isInitializationComplete = true;
    _navigateToLogin();
  }

  void _showDiagnosticInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('诊断信息'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('当前状态：', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• 初始化完成：${_isInitializationComplete ? "是" : "否"}'),
                Text('• 已超时：${_hasTimedOut ? "是" : "否"}'),
                const SizedBox(height: 10),
                const Text('建议检查：', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('• 网络连接是否正常'),
                const Text('• 设备存储空间是否充足'),
                const Text('• 应用权限是否完整'),
                const SizedBox(height: 10),
                const Text('如果问题持续存在，请联系技术支持。'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceNavigateToLogin();
              },
              child: const Text('继续使用'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    if (_hasTimedOut) return; // 如果已经超时，不再执行初始化
    
    try {
      debugPrint('Starting app initialization...');
      
      debugPrint('About to initialize database...');
      await _databaseService.database;
      debugPrint('Database initialized successfully');
      
      if (_hasTimedOut) return; // 检查是否在初始化过程中超时
      
      // 初始化认证服务，恢复登录状态
      debugPrint('About to initialize AuthService...');
      await _authService.initialize();
      debugPrint('AuthService initialized successfully');
      
      if (_hasTimedOut) return; // 检查是否在初始化过程中超时
      
      // 等待动画完成
      await Future.delayed(const Duration(milliseconds: 2500));
      
      if (_hasTimedOut) return; // 检查是否在初始化过程中超时
      
      // 检查用户登录状态
      debugPrint('About to check auth state...');
      await _checkAuthState();
      debugPrint('Auth state check completed');
      
      // 标记初始化完成
      _isInitializationComplete = true;
      _timeoutTimer?.cancel();
      
    } catch (e) {
      debugPrint('App initialization error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      if (_hasTimedOut) return; // 如果已经超时，不显示错误信息
      
      // 即使数据库初始化失败，也允许用户进入登录页面
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('应用初始化遇到问题，但您仍可以正常使用'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      debugPrint('Navigating to login due to error...');
      _isInitializationComplete = true;
      _timeoutTimer?.cancel();
      _navigateToLogin();
    }
    debugPrint('_initializeApp method completed');
  }

  Future<void> _checkAuthState() async {
    try {
      debugPrint('Checking authentication state...');
      final currentUserId = _authService.currentUserId;
      debugPrint('Current user ID: $currentUserId');
      
      if (currentUserId != null) {
        // 用户已登录，检查本地数据库中是否有用户信息
        debugPrint('User is logged in, checking user data...');
        final userModel = await _databaseService.getUser(currentUserId);
        
        if (userModel != null) {
          debugPrint('User data found, navigating to main page');
          _navigateToMain();
        } else {
          // 本地没有用户信息，需要重新登录
          debugPrint('User data not found, signing out and navigating to login');
          await _authService.signOut();
          _navigateToLogin();
        }
      } else {
        debugPrint('No user logged in, navigating to login page');
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      // 如果检查认证状态失败，直接进入登录页面
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // App Name
                      Text(
                        'SocialLife',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // App Tagline
                      Text(
                        '连接生活，分享精彩',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      // Loading Indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}