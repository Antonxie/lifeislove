import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/pages/login_page.dart';
import 'home_page.dart';
import '../../messages/pages/messages_page.dart';
import '../../discover/pages/discover_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../profile/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [
    const HomePage(),
    const MessagesPage(),
    const DiscoverPage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '主页',
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: '消息',
    ),
    NavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: '发现',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: '日历',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '我的',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _pageController = PageController(initialPage: _currentIndex);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // 双击回到顶部或刷新
      _handleDoubleTap(index);
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    // 页面切换动画
    _animationController.forward().then((_) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reverse();
    });

    // 触觉反馈
    HapticFeedback.lightImpact();
  }

  void _handleDoubleTap(int index) {
    // 这里可以实现双击回到顶部的逻辑
    // 例如：通知对应页面滚动到顶部
    HapticFeedback.mediumImpact();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await _showLogoutDialog();
    if (shouldLogout == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('退出登录失败: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _pages,
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == _currentIndex;
              
              return _buildNavigationItem(
                item: item,
                isActive: isActive,
                onTap: () => _onTabTapped(index),
                theme: theme,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required NavigationItem item,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(
                color: isActive 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}