import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';

class DiscoverPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onUserTap;

  const DiscoverPostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images
            if (post.imageUrls.isNotEmpty) _buildImages(theme),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content Text
                  if (post.content.isNotEmpty)
                    Text(
                      post.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Tags
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTags(theme),
                  ],
                  
                  // Location
                  if (post.location != null) ...[
                    const SizedBox(height: 8),
                    _buildLocation(theme),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Bottom Row
                  _buildBottomRow(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages(ThemeData theme) {
    if (post.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: AspectRatio(
          aspectRatio: 3 / 4,
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
    
    // Multiple images
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 200,
        child: _buildImageGrid(theme),
      ),
    );
  }

  Widget _buildImageGrid(ThemeData theme) {
    if (post.imageUrls.length == 2) {
      return Row(
        children: post.imageUrls.map((imageUrl) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: imageUrl == post.imageUrls.last ? 0 : 1,
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
    
    if (post.imageUrls.length == 3) {
      return Column(
        children: [
          Expanded(
            child: Image.network(
              post.imageUrls[0],
              fit: BoxFit.cover,
              width: double.infinity,
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
          const SizedBox(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Image.network(
                    post.imageUrls[1],
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
                const SizedBox(width: 1),
                Expanded(
                  child: Image.network(
                    post.imageUrls[2],
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
              ],
            ),
          ),
        ],
      );
    }
    
    // 4+ images
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
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

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: post.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocation(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            post.location!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(ThemeData theme) {
    return Row(
      children: [
        // User Avatar and Name
        GestureDetector(
          onTap: onUserTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: post.authorAvatarUrl != null
                    ? NetworkImage(post.authorAvatarUrl!)
                    : null,
                backgroundColor: theme.colorScheme.surfaceVariant,
                child: post.authorAvatarUrl == null
                    ? Text(
                        post.authorDisplayName?.isNotEmpty == true
                    ? post.authorDisplayName![0].toUpperCase()
                            : '?',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                post.authorDisplayName ?? post.authorUsername ?? 'Unknown User',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Like Button
        GestureDetector(
          onTap: onLike,
          child: Row(
            children: [
              Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: post.isLiked 
                    ? Colors.red 
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(post.likesCount),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
}