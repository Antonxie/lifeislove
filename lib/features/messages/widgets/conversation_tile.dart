import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ConversationTile({
    Key? key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(theme),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getDisplayName(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastMessageTime ?? DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Last message and unread count
                  Row(
                    children: [
                      Expanded(
                        child: _buildLastMessage(theme),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        _buildUnreadBadge(theme),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (conversation.type == ConversationType.group) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: conversation.avatarUrl != null
            ? NetworkImage(conversation.avatarUrl!)
                : null,
            child: conversation.avatarUrl == null
                ? Icon(
                    Icons.group,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  )
                : null,
          ),
          if (conversation.participantIds.length > 2)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${conversation.participantIds.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    
    // Single chat avatar
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.surfaceVariant,
          backgroundImage: _getAvatarImage(),
          child: _getAvatarImage() == null
              ? Text(
                  _getDisplayName().isNotEmpty
                      ? _getDisplayName()[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        // Online status indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
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
    );
  }

  Widget _buildLastMessage(ThemeData theme) {
    if (conversation.lastMessageContent == null) {
      return Text(
        '暂无消息',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lastMessageContent = conversation.lastMessageContent!;
    String displayText = lastMessageContent;
    IconData? prefixIcon;
    
    // Add sender name for group chats
    if (conversation.type == ConversationType.group && conversation.lastMessageSenderName != null) {
      displayText = '${conversation.lastMessageSenderName}: $lastMessageContent';
    }

    return Row(
      children: [
        // Message type icon
        if (prefixIcon != null) ...[
          Icon(
            prefixIcon,
            size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
        ],
        
        // Message content
        Expanded(
          child: Text(
            displayText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: conversation.unreadCount > 0
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: conversation.unreadCount > 0
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }



  Widget _buildUnreadBadge(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getDisplayName() {
    if (conversation.type == ConversationType.group) {
      return conversation.name ?? '群聊';
    }
    
    // For single chat, get the other participant's name
    // In real implementation, you would fetch user details from database
    final otherParticipant = conversation.participantIds
        .firstWhere((id) => id != 'current_user_id', orElse: () => '');
    
    // Mock names - replace with actual user data
    final mockNames = {
      'user1': '张三',
      'user2': '李四',
      'user3': '王五',
      'user4': '赵六',
      'user5': '钱七',
      'user6': '孙八',
    };
    
    return mockNames[otherParticipant] ?? '未知用户';
  }

  ImageProvider? _getAvatarImage() {
    // Mock avatar URLs - replace with actual user data
    final mockAvatars = {
      'user1': 'https://picsum.photos/100/100?random=1',
      'user2': 'https://picsum.photos/100/100?random=2',
      'user3': 'https://picsum.photos/100/100?random=3',
      'user4': 'https://picsum.photos/100/100?random=4',
      'user5': 'https://picsum.photos/100/100?random=5',
      'user6': 'https://picsum.photos/100/100?random=6',
    };
    
    if (conversation.type == ConversationType.group) {
      return null; // Use default group icon
    }
    
    final otherParticipant = conversation.participantIds
        .firstWhere((id) => id != 'current_user_id', orElse: () => '');
    
    final avatarUrl = mockAvatars[otherParticipant];
    return avatarUrl != null ? NetworkImage(avatarUrl) : null;
  }



  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}