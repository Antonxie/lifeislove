import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/auth_service.dart';
import '../../home/pages/main_navigation_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  
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
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      _showErrorMessage('请同意服务条款和隐私政策');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      if (result.success && mounted) {
        _showSuccessMessage(result.message);
        _navigateToMain();
      } else if (mounted) {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('注册失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    if (!_agreeToTerms) {
      _showErrorMessage('请同意服务条款和隐私政策');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.signInWithGoogle();

      if (result.success && mounted) {
        _showSuccessMessage('注册成功');
        _navigateToMain();
      } else if (mounted) {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Google注册失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                        // Header
                        _buildHeader(theme),
                        
                        const SizedBox(height: 32),
                        
                        // Register Form
                        _buildRegisterForm(theme),
                        
                        const SizedBox(height: 16),
                        
                        // Terms Agreement
                        _buildTermsAgreement(theme),
                        
                        const SizedBox(height: 24),
                        
                        // Register Button
                        _buildRegisterButton(theme),
                        
                        const SizedBox(height: 24),
                        
                        // Divider
                        _buildDivider(theme),
                        
                        const SizedBox(height: 24),
                        
                        // Google Register
                        _buildGoogleRegister(theme),
                        
                        const SizedBox(height: 32),
                        
                        // Login Link
                        _buildLoginLink(theme),
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
        Text(
          '创建账户',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '加入我们，开始您的社交之旅',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username Field
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入用户名';
              }
              if (value.trim().length < 3) {
                return '用户名至少需要3个字符';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                return '用户名只能包含字母、数字和下划线';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Display Name Field
          TextFormField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '显示名称',
              hintText: '请输入显示名称',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入显示名称';
              }
              if (value.trim().length < 2) {
                return '显示名称至少需要2个字符';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '邮箱',
              hintText: '请输入您的邮箱',
              prefixIcon: Icon(Icons.email_outlined),
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
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
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
              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                return '密码必须包含字母和数字';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: '确认密码',
              hintText: '请再次输入密码',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认密码';
              }
              if (value != _passwordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleRegister(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() => _agreeToTerms = value ?? false);
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _agreeToTerms = !_agreeToTerms);
            },
            child: Text.rich(
              TextSpan(
                text: '我已阅读并同意',
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '《服务条款》',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
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
                '注册',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildGoogleRegister(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleRegister,
        icon: SvgPicture.asset(
          'assets/images/google_logo.svg',
          width: 24,
          height: 24,
          placeholderBuilder: (context) {
            return const Icon(Icons.g_mobiledata, size: 24);
          },
        ),
        label: const Text(
          '使用 Google 注册',
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

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '立即登录',
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