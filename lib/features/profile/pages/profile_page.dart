import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu.dart';
import '../widgets/recent_posts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  UserModel? _currentUser;
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadUserProfile();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load current user profile
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = _generateMockUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载用户资料失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App bar with profile header
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.surface,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showSettings,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: _handleMenuAction,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit_profile',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('编辑资料'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share_profile',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 18),
                                SizedBox(width: 8),
                                Text('分享资料'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'qr_code',
                            child: Row(
                              children: [
                                Icon(Icons.qr_code, size: 18),
                                SizedBox(width: 8),
                                Text('我的二维码'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _currentUser != null
                          ? ProfileHeader(user: _currentUser!)
                          : const SizedBox(),
                    ),
                  ),
                  
                  // Profile stats
                  if (_currentUser != null)
                    SliverToBoxAdapter(
                      child: ProfileStats(user: _currentUser!),
                    ),
                  
                  // Tab bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurface.withOpacity(0.6),
                        indicatorColor: theme.colorScheme.primary,
                        tabs: const [
                          Tab(text: '动态'),
                          Tab(text: '收藏'),
                          Tab(text: '关于'),
                        ],
                        onTap: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  // Tab content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Posts tab
                        RecentPosts(userId: _currentUser?.id ?? ''),
                        
                        // Favorites tab
                        _buildFavoritesTab(),
                        
                        // About tab
                        _buildAboutTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFavoritesTab() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收藏内容',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '收藏的内容会显示在这里',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal info
          _buildInfoSection(
            theme,
            '个人信息',
            [
              _buildInfoItem(theme, Icons.person, '用户名', _currentUser?.username ?? ''),
              _buildInfoItem(theme, Icons.email, '邮箱', _currentUser?.email ?? ''),
              _buildInfoItem(theme, Icons.calendar_today, '加入时间',
                  _formatDate(_currentUser?.createdAt ?? DateTime.now())),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bio
          if (_currentUser?.bio?.isNotEmpty == true) ...[
            _buildInfoSection(
              theme,
              '个人简介',
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentUser!.bio ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          // Account settings
          _buildInfoSection(
            theme,
            '账户设置',
            [
              _buildActionItem(theme, Icons.edit, '编辑资料', () => _editProfile()),
              _buildActionItem(theme, Icons.privacy_tip, '隐私设置', () => _showPrivacySettings()),
              _buildActionItem(theme, Icons.security, '账户安全', () => _showSecuritySettings()),
              _buildActionItem(theme, Icons.notifications, '通知设置', () => _showNotificationSettings()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // App settings
          _buildInfoSection(
            theme,
            '应用设置',
            [
              _buildActionItem(theme, Icons.palette, '主题设置', () => _showThemeSettings()),
              _buildActionItem(theme, Icons.language, '语言设置', () => _showLanguageSettings()),
              _buildActionItem(theme, Icons.storage, '存储管理', () => _showStorageSettings()),
              _buildActionItem(theme, Icons.help, '帮助与反馈', () => _showHelpAndFeedback()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Logout
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // App info
          Center(
            child: Column(
              children: [
                Text(
                  'SocialLife v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 SocialLife Team',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit_profile':
        _editProfile();
        break;
      case 'share_profile':
        _shareProfile();
        break;
      case 'qr_code':
        _showQRCode();
        break;
    }
  }

  void _showSettings() {
    // Navigate to settings page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置功能开发中...')),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑资料功能开发中...')),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享资料功能开发中...')),
    );
  }

  void _showQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('二维码功能开发中...')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私设置功能开发中...')),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('账户安全功能开发中...')),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中...')),
    );
  }

  void _showThemeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('主题设置功能开发中...')),
    );
  }

  void _showLanguageSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语言设置功能开发中...')),
    );
  }

  void _showStorageSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('存储管理功能开发中...')),
    );
  }

  void _showHelpAndFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('帮助与反馈功能开发中...')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('退出登录失败: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  UserModel _generateMockUser() {
    return UserModel(
      id: 'current_user',
      username: 'john_doe',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      bio: '热爱生活，喜欢分享美好时光。欢迎大家关注我的动态！',
      avatarUrl: 'https://picsum.photos/200/200?random=100',
      coverUrl: 'https://picsum.photos/800/400?random=101',
      followersCount: 1234,
      followingCount: 567,
      postsCount: 89,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}