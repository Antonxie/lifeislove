import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showTime;
  final VoidCallback onLongPress;
  final Function(String) onImageTap;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showTime,
    required this.onLongPress,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Time separator
        if (showTime) _buildTimeSeparator(theme),
        
        // Message bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left avatar (for others)
              if (!isMe && showAvatar) ...[
                _buildAvatar(theme),
                const SizedBox(width: 8),
              ] else if (!isMe) ...[
                const SizedBox(width: 40),
              ],
              
              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Sender name (for group chats)
                    if (!isMe && showAvatar) _buildSenderName(theme),
                    
                    // Message bubble
                    GestureDetector(
                      onLongPress: onLongPress,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: _getMessagePadding(),
                        decoration: _buildBubbleDecoration(theme),
                        child: _buildMessageContent(theme),
                      ),
                    ),
                    
                    // Message status (for sent messages)
                    if (isMe) _buildMessageStatus(theme),
                  ],
                ),
              ),
              
              // Right avatar (for me)
              if (isMe && showAvatar) ...[
                const SizedBox(width: 8),
                _buildAvatar(theme),
              ] else if (isMe) ...[
                const SizedBox(width: 40),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
              thickness: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatTime(message.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.surfaceVariant,
      backgroundImage: _getAvatarImage(),
      child: _getAvatarImage() == null
          ? Text(
              _getSenderName().isNotEmpty
                  ? _getSenderName()[0].toUpperCase()
                  : '?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );
  }

  Widget _buildSenderName(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        _getSenderName(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(theme);
      case MessageType.image:
        return _buildImageMessage(theme);
      case MessageType.video:
        return _buildVideoMessage(theme);
      case MessageType.audio:
        return _buildAudioMessage(theme);
      case MessageType.file:
        return _buildFileMessage(theme);
      case MessageType.location:
        return _buildLocationMessage(theme);
      case MessageType.sticker:
        return _buildStickerMessage(theme);
      case MessageType.system:
        return _buildSystemMessage(theme);
    }
  }

  Widget _buildTextMessage(ThemeData theme) {
    return SelectableText(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isMe
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage(ThemeData theme) {
    return GestureDetector(
      onTap: () => onImageTap(message.content),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: Image.network(
            message.content,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 150,
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: theme.colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '图片加载失败',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(ThemeData theme) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '00:30',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(ThemeData theme) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: (isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface)
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0:15',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary.withOpacity(0.8)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isMe
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '文档.pdf',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '2.5 MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary.withOpacity(0.8)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '我的位置',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '地图预览',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerMessage(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: message.mediaUrl != null
            ? DecorationImage(
                image: NetworkImage(message.mediaUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: message.mediaUrl == null
          ? Center(
              child: Icon(
                Icons.emoji_emotions,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }

  Widget _buildSystemMessage(ThemeData theme) {
    return Text(
      message.content,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessageStatus(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime(message.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          _buildStatusIcon(theme),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = theme.colorScheme.onSurface.withOpacity(0.4);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = theme.colorScheme.onSurface.withOpacity(0.6);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = theme.colorScheme.onSurface.withOpacity(0.6);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = theme.colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }
    
    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  EdgeInsets _getMessagePadding() {
    switch (message.type) {
      case MessageType.text:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case MessageType.image:
      case MessageType.video:
      case MessageType.location:
      case MessageType.sticker:
        return const EdgeInsets.all(4);
      case MessageType.audio:
      case MessageType.file:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
      case MessageType.system:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  BoxDecoration _buildBubbleDecoration(ThemeData theme) {
    if (message.type == MessageType.system) {
      return BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      );
    }
    
    return BoxDecoration(
      color: isMe
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceVariant,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isMe ? 16 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 16),
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  String _getSenderName() {
    // Mock names - replace with actual user data
    final mockNames = {
      'user1': '张三',
      'user2': '李四',
      'user3': '王五',
      'user4': '赵六',
      'user5': '钱七',
      'user6': '孙八',
    };
    
    return mockNames[message.senderId] ?? '未知用户';
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
    
    final avatarUrl = mockAvatars[message.senderId];
    return avatarUrl != null ? NetworkImage(avatarUrl) : null;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}