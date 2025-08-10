import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class StoryList extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onStoryTap;
  final VoidCallback onAddStory;

  const StoryList({
    Key? key,
    required this.users,
    required this.onStoryTap,
    required this.onAddStory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length + 1, // +1 for add story button
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryItem(theme);
          }
          
          final user = users[index - 1];
          return _buildStoryItem(user, theme);
        },
      ),
    );
  }

  Widget _buildAddStoryItem(ThemeData theme) {
    return GestureDetector(
      onTap: onAddStory,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加动态',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(UserModel user, ThemeData theme) {
    return GestureDetector(
      onTap: () => onStoryTap(user),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: user.avatarUrl == null
                          ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : user.username[0].toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                if (user.isVerified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: theme.colorScheme.onPrimary,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.displayName.isNotEmpty ? user.displayName : user.username,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}