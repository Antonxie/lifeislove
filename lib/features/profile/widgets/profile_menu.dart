import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Quick actions
          _buildMenuSection(
            context,
            '快捷功能',
            [
              _buildMenuItem(
                context,
                Icons.qr_code_scanner,
                '扫一扫',
                '扫描二维码',
                () => _onMenuTap(context, 'scan'),
              ),
              _buildMenuItem(
                context,
                Icons.payment,
                '收付款',
                '转账收款',
                () => _onMenuTap(context, 'payment'),
              ),
              _buildMenuItem(
                context,
                Icons.location_on,
                '附近的人',
                '发现身边朋友',
                () => _onMenuTap(context, 'nearby'),
              ),
              _buildMenuItem(
                context,
                Icons.favorite,
                '我的收藏',
                '查看收藏内容',
                () => _onMenuTap(context, 'favorites'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Social features
          _buildMenuSection(
            context,
            '社交功能',
            [
              _buildMenuItem(
                context,
                Icons.group,
                '我的群聊',
                '管理群聊',
                () => _onMenuTap(context, 'groups'),
              ),
              _buildMenuItem(
                context,
                Icons.event,
                '活动',
                '参与的活动',
                () => _onMenuTap(context, 'events'),
              ),
              _buildMenuItem(
                context,
                Icons.photo_album,
                '相册',
                '我的照片',
                () => _onMenuTap(context, 'album'),
              ),
              _buildMenuItem(
                context,
                Icons.bookmark,
                '书签',
                '保存的链接',
                () => _onMenuTap(context, 'bookmarks'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tools and services
          _buildMenuSection(
            context,
            '工具服务',
            [
              _buildMenuItem(
                context,
                Icons.shopping_bag,
                '购物',
                '我的订单',
                () => _onMenuTap(context, 'shopping'),
              ),
              _buildMenuItem(
                context,
                Icons.local_taxi,
                '出行',
                '打车服务',
                () => _onMenuTap(context, 'travel'),
              ),
              _buildMenuItem(
                context,
                Icons.restaurant,
                '美食',
                '外卖订餐',
                () => _onMenuTap(context, 'food'),
              ),
              _buildMenuItem(
                context,
                Icons.movie,
                '娱乐',
                '电影票务',
                () => _onMenuTap(context, 'entertainment'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) {
              final index = items.indexOf(item);
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuTap(BuildContext context, String action) {
    String message;
    switch (action) {
      case 'scan':
        message = '扫一扫功能开发中...';
        break;
      case 'payment':
        message = '收付款功能开发中...';
        break;
      case 'nearby':
        message = '附近的人功能开发中...';
        break;
      case 'favorites':
        message = '我的收藏功能开发中...';
        break;
      case 'groups':
        message = '我的群聊功能开发中...';
        break;
      case 'events':
        message = '活动功能开发中...';
        break;
      case 'album':
        message = '相册功能开发中...';
        break;
      case 'bookmarks':
        message = '书签功能开发中...';
        break;
      case 'shopping':
        message = '购物功能开发中...';
        break;
      case 'travel':
        message = '出行功能开发中...';
        break;
      case 'food':
        message = '美食功能开发中...';
        break;
      case 'entertainment':
        message = '娱乐功能开发中...';
        break;
      default:
        message = '功能开发中...';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}