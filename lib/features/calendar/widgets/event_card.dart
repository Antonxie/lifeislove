import 'package:flutter/material.dart';
import '../../../core/models/calendar_model.dart';

class EventCard extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCategoryColor(theme).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Category indicator
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(theme),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatEventTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // More options button
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('编辑'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('删除', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Description
                if (event.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Location and category
                if (event.location?.isNotEmpty == true || event.type != EventType.personal) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Location
                      if (event.location?.isNotEmpty == true) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (event.type != EventType.personal) ...[
                          const SizedBox(width: 16),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                      
                      // Category
                      if (event.type != EventType.personal) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(theme).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryDisplayName(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(theme),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                
                // Reminders
                if (event.reminder != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatReminders(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ThemeData theme) {
    switch (event.type.toString().split('.').last.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'health':
        return Colors.red;
      case 'social':
        return Colors.purple;
      case 'travel':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getCategoryDisplayName() {
    switch (event.type.toString().split('.').last.toLowerCase()) {
      case 'work':
        return '工作';
      case 'personal':
        return '个人';
      case 'reminder':
        return '提醒';
      case 'health':
        return '健康';
      case 'social':
        return '社交';
      case 'travel':
        return '旅行';
      case 'education':
        return '学习';
      default:
        return event.type.toString().split('.').last;
    }
  }

  String _formatEventTime() {
    if (event.isAllDay) {
      return '全天';
    }
    
    final startTime = event.startTime;
    final endTime = event.endTime;
    
    // Same day
    if (startTime.year == endTime.year &&
        startTime.month == endTime.month &&
        startTime.day == endTime.day) {
      return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
    }
    
    // Different days
    return '${_formatDateTime(startTime)} - ${_formatDateTime(endTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${_formatTime(dateTime)}';
  }

  String _formatReminders() {
    if (event.reminder == null) return '';
    
    final minutes = event.reminder!.minutesBefore.first;
    String reminderText;
    if (minutes < 60) {
      reminderText = '${minutes}分钟前';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      reminderText = '${hours}小时前';
    } else {
      final days = minutes ~/ 1440;
      reminderText = '${days}天前';
    }
    
    return reminderText;
  }
}