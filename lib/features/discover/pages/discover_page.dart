import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/models/post_model.dart';
import '../../../core/services/database_service.dart';
import '../widgets/discover_post_card.dart';
import '../widgets/category_tabs.dart';
import '../widgets/create_post_fab.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  late TabController _tabController;
  
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String _selectedCategory = '推荐';

  final List<String> _categories = [
    '推荐', '关注', '美食', '旅行', '时尚', '摄影', '生活', '科技', '运动', '音乐'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPosts();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newCategory = _categories[_tabController.index];
        if (newCategory != _selectedCategory) {
          setState(() {
            _selectedCategory = newCategory;
          });
          _loadPosts(refresh: true);
        }
      }
    });
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

  Future<List<PostModel>> _generateMockPosts(int page, int size) async {
    final List<PostModel> posts = [];
    final startIndex = page * size;
    
    for (int i = 0; i < size; i++) {
      final index = startIndex + i;
      final imageCount = (index % 4) + 1; // 1-4张图片
      
      posts.add(PostModel(
          id: 'discover_post_$index',
          userId: 'user_${index % 10}',
        authorDisplayName: '用户${index % 10 + 1}',
        authorAvatarUrl: 'https://picsum.photos/100/100?random=${index + 200}',
        content: _generateRandomContent(index),
        imageUrls: List.generate(
          imageCount,
          (imgIndex) => 'https://picsum.photos/${300 + (index % 3) * 100}/${200 + (imgIndex % 4) * 50}?random=${index * 10 + imgIndex}',
        ),
        location: index % 5 == 0 ? _getRandomLocation(index) : null,
        tags: _getRandomTags(index),
        likesCount: (index * 13) % 1000,
        commentsCount: (index * 7) % 100,
        sharesCount: (index * 3) % 50,
        isLiked: index % 7 == 0,
        createdAt: DateTime.now().subtract(Duration(hours: index % 48)),
        updatedAt: DateTime.now().subtract(Duration(hours: index % 48)),
      ));
    }
    
    return posts;
  }

  String _generateRandomContent(int index) {
    final contents = [
      '今天的阳光特别好，心情也跟着明朗起来 ☀️',
      '分享一下最近的生活小确幸 ✨',
      '这个地方真的太美了，推荐给大家！',
      '今日穿搭分享，简约而不简单 👗',
      '美食探店，这家店真的绝了！',
      '周末时光，慢下来享受生活 🌸',
      '旅行中的美好瞬间，值得记录',
      '新技能get！分享给同样在学习的朋友们',
      '运动打卡，健康生活从今天开始 💪',
      '音乐推荐，这首歌单曲循环了一整天 🎵',
    ];
    return contents[index % contents.length];
  }

  String _getRandomLocation(int index) {
    final locations = [
      '北京·三里屯',
      '上海·外滩',
      '深圳·海岸城',
      '杭州·西湖',
      '成都·春熙路',
      '广州·珠江新城',
      '南京·夫子庙',
      '武汉·江汉路',
    ];
    return locations[index % locations.length];
  }

  List<String> _getRandomTags(int index) {
    final allTags = [
      '生活', '美食', '旅行', '时尚', '摄影', '健身', '音乐', '读书',
      '电影', '咖啡', '甜品', '日常', '分享', '心情', '风景', '街拍'
    ];
    
    final tagCount = (index % 3) + 2; // 2-4个标签
    final selectedTags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[(index + i) % allTags.length];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
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

  void _handleCreatePost() {
    // 显示创建帖子的底部弹窗
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreatePostSheet(),
    );
  }

  Widget _buildCreatePostSheet() {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildCreateOption(
                  icon: Icons.camera_alt_outlined,
                  label: '拍照',
                  color: Colors.blue,
                  onTap: () => _showComingSoon('拍照功能'),
                ),
                _buildCreateOption(
                  icon: Icons.photo_library_outlined,
                  label: '相册',
                  color: Colors.green,
                  onTap: () => _showComingSoon('相册功能'),
                ),
                _buildCreateOption(
                  icon: Icons.videocam_outlined,
                  label: '视频',
                  color: Colors.red,
                  onTap: () => _showComingSoon('视频功能'),
                ),
                _buildCreateOption(
                  icon: Icons.article_outlined,
                  label: '文字',
                  color: Colors.orange,
                  onTap: () => _showComingSoon('文字发布'),
                ),
                _buildCreateOption(
                  icon: Icons.live_tv_outlined,
                  label: '直播',
                  color: Colors.purple,
                  onTap: () => _showComingSoon('直播功能'),
                ),
                _buildCreateOption(
                  icon: Icons.more_horiz,
                  label: '更多',
                  color: Colors.grey,
                  onTap: () => _showComingSoon('更多功能'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 即将上线'),
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              title: Text(
                '发现',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showComingSoon('搜索功能'),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: CategoryTabs(
                  controller: _tabController,
                  categories: _categories,
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: _buildPostsGrid(),
        ),
      ),
      floatingActionButton: CreatePostFAB(
        onPressed: _handleCreatePost,
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_posts.isEmpty) {
      return _buildEmptyWidget();
    }

    return MasonryGridView.count(
      controller: _scrollController,
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _posts.length) {
          return DiscoverPostCard(
            post: _posts[index],
            onTap: () => _handlePostTap(_posts[index]),
            onLike: () => _handleLike(_posts[index]),
            onUserTap: () => _handleUserTap(_posts[index].userId),
          );
        } else {
          return _buildLoadMoreWidget();
        }
      },
    );
  }

  Widget _buildEmptyWidget() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无内容',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成为第一个分享的人吧',
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
      height: 100,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  void _handlePostTap(PostModel post) {
    _showComingSoon('帖子详情');
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

  void _handleUserTap(String userId) {
    _showComingSoon('用户资料');
  }
}