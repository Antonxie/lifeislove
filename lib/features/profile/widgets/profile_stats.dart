import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class ProfileStats extends StatelessWidget {
  final UserModel user;

  const ProfileStats({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '帖子',
            user.postsCount,
            Icons.article_outlined,
            () => _onStatTap(context, 'posts'),
          ),
          _buildDivider(theme),
          _buildStatItem(
            context,
            '关注者',
            user.followersCount,
            Icons.people_outline,
            () => _onStatTap(context, 'followers'),
          ),
          _buildDivider(theme),
          _buildStatItem(
            context,
            '关注中',
            user.followingCount,
            Icons.person_add_outlined,
            () => _onStatTap(context, 'following'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Count
                Text(
                  _formatCount(count),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Label
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.colorScheme.outline.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  void _onStatTap(BuildContext context, String type) {
    String message;
    switch (type) {
      case 'posts':
        message = '查看所有帖子功能开发中...';
        break;
      case 'followers':
        message = '查看关注者列表功能开发中...';
        break;
      case 'following':
        message = '查看关注中列表功能开发中...';
        break;
      default:
        message = '功能开发中...';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}