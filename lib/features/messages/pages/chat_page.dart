import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;

  const ChatPage({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
    });

    // Mock messages - replace with actual database calls
    _messages = [
      MessageModel(
        id: 'msg1',
        conversationId: widget.conversation.id,
        senderId: 'user2',
        receiverId: 'current_user_id',
        content: '你好！最近怎么样？',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'msg2',
        conversationId: widget.conversation.id,
        senderId: 'current_user_id',
        receiverId: 'user2',
        content: '还不错，你呢？工作忙吗？',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageModel(
        id: 'msg3',
        conversationId: widget.conversation.id,
        senderId: 'user2',
        receiverId: 'current_user_id',
        content: '还好，最近在做一个新项目',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      MessageModel(
        id: 'msg4',
        conversationId: widget.conversation.id,
        senderId: 'user2',
        receiverId: 'current_user_id',
        content: 'https://picsum.photos/300/200?random=1',
        type: MessageType.image,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      ),
      MessageModel(
        id: 'msg5',
        conversationId: widget.conversation.id,
        senderId: 'current_user_id',
        receiverId: 'user2',
        content: '哇，看起来很棒！',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: 'msg6',
        conversationId: widget.conversation.id,
        senderId: 'user2',
        receiverId: 'current_user_id',
        content: '谢谢！周末有空一起出来玩吗？',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    setState(() {
      _isLoading = false;
    });

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more messages when scrolled to top
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    // TODO: Implement pagination for loading older messages
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  void _sendMessage(String content, MessageType type) {
    if (content.trim().isEmpty && type == MessageType.text) return;

    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: 'current_user_id',
      receiverId: widget.conversation.participantIds
          .firstWhere((id) => id != 'current_user_id'),
      content: content,
      type: type,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate message sending
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
        }
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(status: MessageStatus.delivered);
        }
      });
    });

    // Simulate auto-reply for demo
    if (type == MessageType.text) {
      _simulateReply();
    }
  }

  void _simulateReply() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isTyping = true;
      });
    });

    Future.delayed(const Duration(seconds: 5), () {
      final replies = [
        '好的！',
        '听起来不错',
        '我也这么想',
        '哈哈，有意思',
        '确实如此',
        '让我想想',
      ];

      final reply = MessageModel(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: widget.conversation.id,
        senderId: widget.conversation.participantIds
            .firstWhere((id) => id != 'current_user_id'),
        receiverId: 'current_user_id',
        content: replies[DateTime.now().millisecond % replies.length],
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now(),
      );

      setState(() {
        _isTyping = false;
        _messages.add(reply);
      });

      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _buildMessagesList(theme),
          ),
          
          // Typing indicator
          if (_isTyping) _buildTypingIndicator(theme),
          
          // Input area
          ChatInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onSendImage: () => _handleSendImage(),
            onSendVoice: () => _handleSendVoice(),
            onSendFile: () => _handleSendFile(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: _getAvatarImage(),
            child: _getAvatarImage() == null
                ? Text(
                    _getDisplayName().isNotEmpty
                        ? _getDisplayName()[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayName(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.conversation.type == ConversationType.group
                      ? '${widget.conversation.participantIds.length}人'
                      : '在线',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.conversation.type == ConversationType.group)
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _startGroupVideoCall,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: _startVoiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _startVideoCall,
          ),
        ],
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildMessagesList(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '开始聊天吧！',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        final isMe = message.senderId == 'current_user_id';
        final showAvatar = _shouldShowAvatar(index);
        final showTime = _shouldShowTime(index);
        
        return MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar,
          showTime: showTime,
          onLongPress: () => _showMessageOptions(message),
          onImageTap: (imageUrl) => _showImageViewer(imageUrl),
        );
      },
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: _getAvatarImage(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '正在输入',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(int index) {
    if (widget.conversation.type == ConversationType.group) {
      final message = _messages[_messages.length - 1 - index];
      if (index == 0) return true;
      
      final nextMessage = _messages[_messages.length - index];
      return message.senderId != nextMessage.senderId;
    }
    return false;
  }

  bool _shouldShowTime(int index) {
    final message = _messages[_messages.length - 1 - index];
    if (index == 0) return true;
    
    final nextMessage = _messages[_messages.length - index];
    final timeDiff = message.createdAt.difference(nextMessage.createdAt);
    
    return timeDiff.inMinutes > 5;
  }

  String _getDisplayName() {
    if (widget.conversation.type == ConversationType.group) {
      return widget.conversation.name ?? '群聊';
    }
    
    // Mock names - replace with actual user data
    final mockNames = {
      'user1': '张三',
      'user2': '李四',
      'user3': '王五',
      'user4': '赵六',
      'user5': '钱七',
      'user6': '孙八',
    };
    
    final otherParticipant = widget.conversation.participantIds
        .firstWhere((id) => id != 'current_user_id', orElse: () => '');
    
    return mockNames[otherParticipant] ?? '未知用户';
  }

  ImageProvider? _getAvatarImage() {
    if (widget.conversation.type == ConversationType.group) {
      return widget.conversation.avatarUrl != null
          ? NetworkImage(widget.conversation.avatarUrl!)
          : null;
    }
    
    // Mock avatar URLs
    final mockAvatars = {
      'user2': 'https://picsum.photos/100/100?random=2',
      'user3': 'https://picsum.photos/100/100?random=3',
    };
    
    final otherParticipant = widget.conversation.participantIds
        .firstWhere((id) => id != 'current_user_id', orElse: () => '');
    
    final avatarUrl = mockAvatars[otherParticipant];
    return avatarUrl != null ? NetworkImage(avatarUrl) : null;
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音通话功能开发中...')),
    );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('视频通话功能开发中...')),
    );
  }

  void _startGroupVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('群视频通话功能开发中...')),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(widget.conversation.type == ConversationType.group ? '群聊信息' : '聊天信息'),
              onTap: () {
                Navigator.pop(context);
                _showChatInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('搜索聊天记录'),
              onTap: () {
                Navigator.pop(context);
                _searchMessages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('消息免打扰'),
              onTap: () {
                Navigator.pop(context);
                _toggleMute();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('清空聊天记录'),
              onTap: () {
                Navigator.pop(context);
                _clearMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    final isMe = message.senderId == 'current_user_id';
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == MessageType.text) ...[
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('复制'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('回复'),
              onTap: () {
                Navigator.pop(context);
                _replyToMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('转发'),
              onTap: () {
                Navigator.pop(context);
                _forwardMessage(message);
              },
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSendImage() {
    // TODO: Implement image picker and send
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片发送功能开发中...')),
    );
  }

  void _handleSendVoice() {
    // TODO: Implement voice recording and send
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音发送功能开发中...')),
    );
  }

  void _handleSendFile() {
    // TODO: Implement file picker and send
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文件发送功能开发中...')),
    );
  }

  void _showImageViewer(String imageUrl) {
    // TODO: Implement image viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片查看功能开发中...')),
    );
  }

  void _showChatInfo() {
    // TODO: Implement chat info page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('聊天信息功能开发中...')),
    );
  }

  void _searchMessages() {
    // TODO: Implement message search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('消息搜索功能开发中...')),
    );
  }

  void _toggleMute() {
    // TODO: Implement mute toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('免打扰功能开发中...')),
    );
  }

  void _clearMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天记录已清空')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(MessageModel message) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('回复功能开发中...')),
    );
  }

  void _forwardMessage(MessageModel message) {
    // TODO: Implement forward functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('转发功能开发中...')),
    );
  }

  void _editMessage(MessageModel message) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑功能开发中...')),
    );
  }

  void _deleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('确定要删除这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.remove(message);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('消息已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}