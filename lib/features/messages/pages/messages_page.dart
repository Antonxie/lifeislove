import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/conversation_tile.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<ConversationModel> _conversations = [];
  List<ConversationModel> _filteredConversations = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    // Mock data - replace with actual database calls
    _conversations = [
      ConversationModel(
        id: '1',
        name: 'User 2',
        type: ConversationType.direct,
        participantIds: ['user1', 'user2'],
        lastMessageId: 'msg1',
        lastMessageContent: '你好，最近怎么样？',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        lastMessageSenderName: 'User 2',
      ),
      ConversationModel(
        id: '2',
        name: 'User 3',
        type: ConversationType.direct,
        participantIds: ['user1', 'user3'],
        lastMessageId: 'msg2',
        lastMessageContent: '好的，明天见！',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessageSenderName: 'User 1',
      ),
      ConversationModel(
        id: '3',
        name: '周末聚会群',
        type: ConversationType.group,
        participantIds: ['user1', 'user4', 'user5', 'user6'],
        lastMessageId: 'msg3',
        lastMessageContent: '大家周末有空吗？',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        lastMessageSenderName: 'User 4',
      ),
    ];
    
    _filteredConversations = List.from(_conversations);
    setState(() {});
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredConversations = _conversations.where((conversation) {
          // Search in group name or participant names (mock implementation)
          if (conversation.type == ConversationType.group && conversation.name != null) {
            return conversation.name!.toLowerCase().contains(query);
          }
          // In real implementation, you would search participant names
          return conversation.lastMessageContent?.toLowerCase().contains(query) ?? false;
        }).toList();
      } else {
        _filteredConversations = List.from(_conversations);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('消息'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _showNewChatOptions,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索聊天记录',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '全部'),
                  Tab(text: '未读'),
                  Tab(text: '群聊'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationList(_filteredConversations),
          _buildConversationList(
            _filteredConversations.where((c) => c.unreadCount > 0).toList(),
          ),
          _buildConversationList(
            _filteredConversations.where((c) => c.type == ConversationType.group).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatOptions,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildConversationList(List<ConversationModel> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? '没有找到相关聊天' : '暂无聊天记录',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadConversations();
      },
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () => _openChat(conversation),
            onLongPress: () => _showConversationOptions(conversation),
          );
        },
      ),
    );
  }

  void _openChat(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversation: conversation,
        ),
      ),
    ).then((_) {
      // Refresh conversations when returning from chat
      _loadConversations();
    });
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('发起单聊'),
              onTap: () {
                Navigator.pop(context);
                _showContactPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('发起群聊'),
              onTap: () {
                Navigator.pop(context);
                _showGroupChatCreator();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_outlined),
              title: const Text('扫一扫'),
              onTap: () {
                Navigator.pop(context);
                _openQRScanner();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read_outlined),
              title: const Text('标记全部已读'),
              onTap: () {
                Navigator.pop(context);
                _markAllAsRead();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('聊天设置'),
              onTap: () {
                Navigator.pop(context);
                _openChatSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(ConversationModel conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                conversation.unreadCount > 0
                    ? Icons.mark_email_read_outlined
                    : Icons.mark_email_unread_outlined,
              ),
              title: Text(
                conversation.unreadCount > 0 ? '标记已读' : '标记未读',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleReadStatus(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('置顶聊天'),
              onTap: () {
                Navigator.pop(context);
                _pinConversation(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('消息免打扰'),
              onTap: () {
                Navigator.pop(context);
                _muteConversation(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除聊天', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactPicker() {
    // TODO: Implement contact picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('联系人选择功能开发中...')),
    );
  }

  void _showGroupChatCreator() {
    // TODO: Implement group chat creator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('群聊创建功能开发中...')),
    );
  }

  void _openQRScanner() {
    // TODO: Implement QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫码功能开发中...')),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _conversations.length; i++) {
        _conversations[i] = _conversations[i].copyWith(unreadCount: 0);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已标记全部为已读')),
    );
  }

  void _openChatSettings() {
    // TODO: Implement chat settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('聊天设置功能开发中...')),
    );
  }

  void _toggleReadStatus(ConversationModel conversation) {
    setState(() {
      final index = _conversations.indexOf(conversation);
      if (index != -1) {
        _conversations[index] = conversation.copyWith(
          unreadCount: conversation.unreadCount > 0 ? 0 : 1,
        );
      }
    });
  }

  void _pinConversation(ConversationModel conversation) {
    // TODO: Implement pin functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('置顶功能开发中...')),
    );
  }

  void _muteConversation(ConversationModel conversation) {
    // TODO: Implement mute functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('免打扰功能开发中...')),
    );
  }

  void _deleteConversation(ConversationModel conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除聊天'),
        content: const Text('确定要删除这个聊天吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _conversations.remove(conversation);
                _filteredConversations.remove(conversation);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}