import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/auth_service.dart';
import 'register_page.dart';
import '../../home/pages/main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success && mounted) {
        _showSuccessMessage(result.message);
        _navigateToMain();
      } else if (mounted) {
        // 根据错误代码显示更友好的错误信息
        String errorMessage = result.message;
        if (result.errorCode == 'user-not-found') {
          errorMessage = '用户不存在，请检查邮箱地址或先注册账户';
        } else if (result.errorCode == 'invalid-input') {
          errorMessage = '请输入有效的邮箱和密码';
        } else if (result.errorCode == 'authentication-error') {
          errorMessage = '认证失败，请检查网络连接或稍后重试';
        }
        _showErrorMessage(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Login exception: $e');
        _showErrorMessage('登录过程中发生错误，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.signInWithGoogle();

      if (result.success && mounted) {
        _showSuccessMessage(result.message);
        _navigateToMain();
      } else if (mounted) {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Google登录失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('请先输入邮箱地址');
      return;
    }

    final result = await _authService.sendPasswordResetEmail(_emailController.text.trim());
    
    if (mounted) {
      if (result.success) {
        _showSuccessMessage(result.message);
      } else {
        _showErrorMessage(result.message);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: size.height * 0.08),
                        
                        // Logo and Title
                        _buildHeader(theme),
                        
                        SizedBox(height: size.height * 0.06),
                        
                        // Login Form
                        _buildLoginForm(theme),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        _buildLoginButton(theme),
                        
                        const SizedBox(height: 16),
                        
                        // Forgot Password
                        _buildForgotPassword(theme),
                        
                        const SizedBox(height: 32),
                        
                        // Divider
                        _buildDivider(theme),
                        
                        const SizedBox(height: 24),
                        
                        // Google Login
                        _buildGoogleLogin(theme),
                        
                        const SizedBox(height: 32),
                        
                        // Register Link
                        _buildRegisterLink(theme),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '欢迎回来',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '登录您的账户继续使用',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: '请输入您的邮箱',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入邮箱';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入您的密码',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少需要6位';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleEmailLogin(),
          ),
          const SizedBox(height: 16),
          
          // Remember Me
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
              ),
              Text(
                '记住我',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailLogin,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          '忘记密码？',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLogin(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        icon: SvgPicture.asset(
          'assets/images/google_logo.svg',
          width: 24,
          height: 24,
          placeholderBuilder: (context) {
            return const Icon(Icons.g_mobiledata, size: 24);
          },
        ),
        label: const Text(
          '使用 Google 登录',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账户？',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            '立即注册',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}