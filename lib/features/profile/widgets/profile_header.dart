import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Cover image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.primary,
                ],
              ),
            ),
            child: user.coverUrl?.isNotEmpty == true
                ? Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          user.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
          ),
          
          // Profile content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: user.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl?.isEmpty != false
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display name with verification badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.displayName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Username
                        Text(
                          '@${user.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Bio (if available)
                        if (user.bio?.isNotEmpty == true) ...[
                          Text(
                            user.bio!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit profile button
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('编辑资料功能开发中...')),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('编辑'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Share button
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('分享功能开发中...')),
                          );
                        },
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                          padding: const EdgeInsets.all(8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Online status indicator (if applicable)
          Positioned(
            top: 160,
            left: 72,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}