import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final Function(PostModel) onLike;
  final Function(PostModel) onComment;
  final Function(PostModel) onShare;
  final Function(String) onUserTap;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme, context),
          
          // Content
          if (post.content.isNotEmpty) _buildContent(theme),
          
          // Images
          if (post.imageUrls.isNotEmpty) _buildImages(theme),
          
          // Location and Tags
          if (post.location != null || post.tags.isNotEmpty)
            _buildLocationAndTags(theme),
          
          // Actions
          _buildActions(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onUserTap(post.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: post.authorAvatarUrl != null
                    ? NetworkImage(post.authorAvatarUrl!)
                  : null,
              backgroundColor: theme.colorScheme.surfaceVariant,
              child: post.authorAvatarUrl == null
                  ? Text(
                      post.authorDisplayName?.isNotEmpty == true
                    ? post.authorDisplayName![0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onUserTap(post.userId),
                  child: Text(
                    post.authorDisplayName ?? post.authorUsername ?? 'Unknown User',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMoreOptions(context),
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImages(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildImageLayout(theme),
    );
  }

  Widget _buildImageLayout(ThemeData theme) {
    if (post.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            post.imageUrls.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: theme.colorScheme.surfaceVariant,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 48,
                ),
              );
            },
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: _buildMultiImageGrid(theme),
      ),
    );
  }

  Widget _buildMultiImageGrid(ThemeData theme) {
    if (post.imageUrls.length == 2) {
      return Row(
        children: post.imageUrls.map((imageUrl) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: imageUrl == post.imageUrls.last ? 0 : 2,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      );
    }
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: post.imageUrls.length == 3 ? 3 : 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: post.imageUrls.length > 4 ? 4 : post.imageUrls.length,
      itemBuilder: (context, index) {
        if (index == 3 && post.imageUrls.length > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                post.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+${post.imageUrls.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        return Image.network(
            post.imageUrls[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.colorScheme.surfaceVariant,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationAndTags(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.location != null)
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  post.location!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          if (post.location != null && post.tags.isNotEmpty)
            const SizedBox(height: 8),
          if (post.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.tags.take(5).map((tag) {
                return Text(
                  '#$tag',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Like
          _buildActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            count: post.likesCount,
            color: post.isLiked ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
            onTap: () => onLike(post),
            theme: theme,
          ),
          const SizedBox(width: 24),
          
          // Comment
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            count: post.commentsCount,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            onTap: () => onComment(post),
            theme: theme,
          ),
          const SizedBox(width: 24),
          
          // Share
          _buildActionButton(
            icon: Icons.share_outlined,
            count: post.sharesCount,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            onTap: () => onShare(post),
            theme: theme,
          ),
          
          const Spacer(),
          
          // Bookmark
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _handleBookmark(),
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            _formatCount(count),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(count / 10000).toStringAsFixed(1)}w';
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('举报'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('屏蔽用户'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('复制链接'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookmark() {
    // TODO: Implement bookmark functionality
  }
}