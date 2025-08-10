import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../discover/widgets/post_card.dart';

class RecentPosts extends StatefulWidget {
  final String userId;

  const RecentPosts({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<RecentPosts> createState() => _RecentPostsState();
}

class _RecentPostsState extends State<RecentPosts>
    with AutomaticKeepAliveClientMixin {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      final newPosts = _generateMockPosts(10);
      
      setState(() {
        _posts = newPosts;
        _page = 1;
        _hasMore = newPosts.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载帖子失败: $e')),
        );
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final newPosts = _generateMockPosts(10, startIndex: _posts.length);
      
      setState(() {
        _posts.addAll(newPosts);
        _page++;
        _hasMore = newPosts.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载更多失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _posts.length) {
            return _buildLoadingIndicator();
          }

          final post = _posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              post: post,
              onLike: (post) => _onLike(post),
              onComment: (post) => _onComment(post),
              onShare: (post) => _onShare(post),
              onUserTap: (userId) => _onUserTap(userId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有发布任何动态',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '分享你的第一条动态吧',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('发布动态功能开发中...')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('发布动态'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  void _onLike(PostModel post) {
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

  void _onComment(PostModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('评论功能开发中...')),
    );
  }

  void _onShare(PostModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中...')),
    );
  }

  void _onBookmark(PostModel post) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          isBookmarked: !_posts[index].isBookmarked,
        );
      }
    });
  }

  void _onMore(PostModel post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMoreOptionsSheet(post),
    );
  }

  void _onUserTap(String userId) {
    // 导航到用户资料页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户资料页面开发中...')),
    );
  }

  Widget _buildMoreOptionsSheet(PostModel post) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Options
          _buildSheetOption(
            theme,
            Icons.edit,
            '编辑',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('编辑功能开发中...')),
              );
            },
          ),
          _buildSheetOption(
            theme,
            Icons.link,
            '复制链接',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('链接已复制')),
              );
            },
          ),
          _buildSheetOption(
            theme,
            Icons.visibility_off,
            '隐藏',
            () {
              Navigator.pop(context);
              setState(() {
                _posts.removeWhere((p) => p.id == post.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已隐藏该动态')),
              );
            },
          ),
          _buildSheetOption(
            theme,
            Icons.delete,
            '删除',
            () {
              Navigator.pop(context);
              _showDeleteDialog(post);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSheetOption(
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动态'),
        content: const Text('确定要删除这条动态吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _posts.removeWhere((p) => p.id == post.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('动态已删除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  List<PostModel> _generateMockPosts(int count, {int startIndex = 0}) {
    final posts = <PostModel>[];
    final mockUser = UserModel(
      id: widget.userId,
      username: 'john_doe',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      bio: '热爱生活，喜欢分享美好时光',
      avatarUrl: 'https://picsum.photos/200/200?random=100',
      coverUrl: '',
      followersCount: 1234,
      followingCount: 567,
      postsCount: 89,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    final contents = [
      '今天天气真好，出门走走心情都变好了 ☀️',
      '分享一下今天做的美食，第一次尝试做意大利面 🍝',
      '周末和朋友们一起去爬山，风景超美的！',
      '读完了一本很棒的书，推荐给大家 📚',
      '新买的相机拍照效果真不错 📸',
      '今天学会了一个新技能，很有成就感',
      '和家人一起度过了愉快的晚餐时光',
      '工作虽然忙碌，但很充实',
      '发现了一家很棒的咖啡店 ☕',
      '生活中的小确幸总是让人开心',
    ];

    final locations = [
      '北京·朝阳区',
      '上海·浦东新区',
      '广州·天河区',
      '深圳·南山区',
      '杭州·西湖区',
      '成都·锦江区',
      '武汉·江汉区',
      '南京·鼓楼区',
    ];

    final tags = [
      ['生活', '日常'],
      ['美食', '料理'],
      ['旅行', '户外'],
      ['读书', '学习'],
      ['摄影', '艺术'],
      ['技能', '成长'],
      ['家庭', '温馨'],
      ['工作', '职场'],
      ['咖啡', '休闲'],
      ['心情', '感悟'],
    ];

    for (int i = 0; i < count; i++) {
      final index = (startIndex + i) % contents.length;
      final imageCount = (i % 4) + 1;
      final images = List.generate(
        imageCount,
        (imgIndex) => 'https://picsum.photos/400/300?random=${startIndex + i + imgIndex + 200}',
      );

      posts.add(PostModel(
          id: 'user_post_${startIndex + i}',
          userId: mockUser.id,
          content: contents[index],
        imageUrls: images,
        videoUrl: '',
        location: locations[index % locations.length],
        tags: tags[index],
        likesCount: (startIndex + i) * 12 + 45,
        commentsCount: (startIndex + i) * 3 + 8,
        sharesCount: (startIndex + i) * 2 + 3,
        isLiked: (startIndex + i) % 3 == 0,
        isBookmarked: (startIndex + i) % 5 == 0,
        createdAt: DateTime.now().subtract(Duration(
          hours: (startIndex + i) * 2 + 1,
          minutes: (startIndex + i) * 15,
        )),
        updatedAt: DateTime.now().subtract(Duration(
          hours: (startIndex + i) * 2,
          minutes: (startIndex + i) * 10,
        )),
      ));
    }

    return posts;
  }
}