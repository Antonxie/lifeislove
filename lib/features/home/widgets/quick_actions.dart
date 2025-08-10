import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onCreatePost;
  final VoidCallback onStartLive;
  final VoidCallback onScanQR;
  final VoidCallback onNearby;

  const QuickActions({
    Key? key,
    required this.onCreatePost,
    required this.onStartLive,
    required this.onScanQR,
    required this.onNearby,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          Text(
            '快速操作',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                icon: Icons.add_circle_outline,
                label: '发布',
                color: theme.colorScheme.primary,
                onTap: onCreatePost,
                theme: theme,
              ),
              _buildActionItem(
                icon: Icons.videocam_outlined,
                label: '直播',
                color: Colors.red,
                onTap: onStartLive,
                theme: theme,
              ),
              _buildActionItem(
                icon: Icons.qr_code_scanner_outlined,
                label: '扫码',
                color: Colors.orange,
                onTap: onScanQR,
                theme: theme,
              ),
              _buildActionItem(
                icon: Icons.location_on_outlined,
                label: '附近',
                color: Colors.green,
                onTap: onNearby,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}