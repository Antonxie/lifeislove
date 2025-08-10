import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/database_service.dart';
import '../../discover/widgets/post_card.dart';
import '../widgets/story_list.dart';
import '../widgets/quick_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<PostModel> _posts = [];
  List<UserModel> _followingUsers = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _loadPosts();
    _loadFollowingUsers();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadMorePosts();
        }
      }
    });
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _currentPage = 0;
        _hasMore = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      // 模拟获取推荐帖子数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      final newPosts = await _generateMockPosts(_currentPage, _pageSize);
      
      setState(() {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        
        _hasMore = newPosts.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      _showErrorMessage('加载失败: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    await _loadPosts();
  }

  Future<void> _loadFollowingUsers() async {
    try {
      // 模拟获取关注用户数据
      _followingUsers = await _generateMockUsers();
      setState(() {});
    } catch (e) {
      print('加载关注用户失败: $e');
    }
  }

  Future<List<PostModel>> _generateMockPosts(int page, int size) async {
    final List<PostModel> posts = [];
    final startIndex = page * size;
    
    for (int i = 0; i < size; i++) {
      final index = startIndex + i;
      posts.add(PostModel(
        id: 'post_$index',
        userId: 'user_${index % 5}',
        authorDisplayName: '用户${index % 5 + 1}',
        authorAvatarUrl: 'https://picsum.photos/100/100?random=$index',
        content: '这是第${index + 1}条动态内容，分享生活中的美好时刻 ✨',
        imageUrls: index % 3 == 0 ? [
          'https://picsum.photos/400/300?random=${index * 2}',
          'https://picsum.photos/400/300?random=${index * 2 + 1}',
        ] : [],
        location: index % 4 == 0 ? '北京·朝阳区' : null,
        tags: ['生活', '分享', '美好'],
        likesCount: (index * 7) % 100,
        commentsCount: (index * 3) % 20,
        sharesCount: (index * 2) % 10,
        isLiked: index % 5 == 0,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      ));
    }
    
    return posts;
  }

  Future<List<UserModel>> _generateMockUsers() async {
    return List.generate(8, (index) => UserModel(
      id: 'story_user_$index',
      username: 'user$index',
      email: 'user$index@example.com',
      displayName: '用户$index',
      avatarUrl: 'https://picsum.photos/80/80?random=${index + 100}',
      isVerified: index % 3 == 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await _loadPosts(refresh: true);
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
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            _buildSliverAppBar(theme),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: QuickActions(
                onCreatePost: () => _navigateToCreatePost(),
                onStartLive: () => _showComingSoon('直播功能'),
                onScanQR: () => _showComingSoon('扫码功能'),
                onNearby: () => _showComingSoon('附近功能'),
              ),
            ),
            
            // Stories
            if (_followingUsers.isNotEmpty)
              SliverToBoxAdapter(
                child: StoryList(
                  users: _followingUsers,
                  onStoryTap: (user) => _showComingSoon('动态故事'),
                  onAddStory: () => _showComingSoon('添加动态'),
                ),
              ),
            
            // Posts List
            if (_isLoading && _posts.isEmpty)
              SliverFillRemaining(
                child: _buildLoadingWidget(),
              )
            else if (_posts.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyWidget(theme),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _posts.length) {
                      return PostCard(
                        post: _posts[index],
                        onLike: (post) => _handleLike(post),
                        onComment: (post) => _handleComment(post),
                        onShare: (post) => _handleShare(post),
                        onUserTap: (userId) => _navigateToProfile(userId),
                      );
                    } else if (_hasMore) {
                      return _buildLoadMoreWidget();
                    }
                    return null;
                  },
                  childCount: _posts.length + (_hasMore ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Text(
        'SocialLife',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showComingSoon('搜索功能'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showComingSoon('通知功能'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无动态',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '关注更多朋友，发现精彩内容',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _navigateToCreatePost() {
    _showComingSoon('发布动态');
  }

  void _navigateToProfile(String userId) {
    _showComingSoon('用户资料');
  }

  void _handleLike(PostModel post) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          isLiked: !_posts[index].isLiked,
          likesCount: _posts[index].isLiked 
              ? _posts[index].likesCount - 1
              : _posts[index].likesCount + 1,
        );
      }
    });
  }

  void _handleComment(PostModel post) {
    _showComingSoon('评论功能');
  }

  void _handleShare(PostModel post) {
    _showComingSoon('分享功能');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 即将上线'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}