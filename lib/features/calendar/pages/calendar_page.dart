import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/calendar_model.dart';
import '../../../core/services/database_service.dart';
import '../widgets/event_card.dart';
import '../widgets/add_event_dialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late final ValueNotifier<List<CalendarEventModel>> _selectedEvents;
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  List<CalendarEventModel> _events = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadEvents();
    _animationController.forward();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load events from database
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      _events = _generateMockEvents();
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载事件失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return isSameDay(event.startTime, day);
    }).toList();
  }

  List<CalendarEventModel> _getEventsForRange(DateTime start, DateTime end) {
    return _events.where((event) {
      return event.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
          event.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else {
      _selectedEvents.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('日历'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: theme.colorScheme.onSurface,
            ),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              _selectedEvents.value = _getFilteredEvents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('全部事件'),
              ),
              const PopupMenuItem(
                value: 'work',
                child: Text('工作'),
              ),
              const PopupMenuItem(
                value: 'personal',
                child: Text('个人'),
              ),
              const PopupMenuItem(
                value: 'reminder',
                child: Text('提醒'),
              ),
            ],
          ),
          // View mode button
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.month
                  ? Icons.view_week
                  : Icons.view_module,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
          // Search button
          IconButton(
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Calendar widget
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TableCalendar<CalendarEventModel>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      rangeSelectionMode: _rangeSelectionMode,
                      eventLoader: _getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                        holidayTextStyle: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        rangeHighlightColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        markerDecoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: theme.colorScheme.onSurface,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      onDaySelected: _onDaySelected,
                      onRangeSelected: _onRangeSelected,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                  
                  // Events list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getEventsTitle(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showAddEventDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('添加事件'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Events list
                          Expanded(
                            child: ValueListenableBuilder<List<CalendarEventModel>>(
                              valueListenable: _selectedEvents,
                              builder: (context, events, _) {
                                if (events.isEmpty) {
                                  return _buildEmptyState(theme);
                                }
                                
                                return ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    final event = events[index];
                                    return EventCard(
                                      event: event,
                                      onTap: () => _showEventDetails(event),
                                      onEdit: () => _editEvent(event),
                                      onDelete: () => _deleteEvent(event),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无事件',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加新事件',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventsTitle() {
    if (_rangeStart != null && _rangeEnd != null) {
      return '选中时间段的事件';
    } else if (_selectedDay != null) {
      final today = DateTime.now();
      if (isSameDay(_selectedDay!, today)) {
        return '今天的事件';
      } else if (isSameDay(_selectedDay!, today.add(const Duration(days: 1)))) {
        return '明天的事件';
      } else {
        return '${_selectedDay!.month}月${_selectedDay!.day}日的事件';
      }
    }
    return '事件';
  }

  List<CalendarEventModel> _getFilteredEvents() {
    List<CalendarEventModel> baseEvents;
    
    if (_rangeStart != null && _rangeEnd != null) {
      baseEvents = _getEventsForRange(_rangeStart!, _rangeEnd!);
    } else if (_selectedDay != null) {
      baseEvents = _getEventsForDay(_selectedDay!);
    } else {
      baseEvents = [];
    }
    
    if (_selectedFilter == 'all') {
      return baseEvents;
    }
    
    return baseEvents.where((event) {
      return event.type.toString().split('.').last.toLowerCase() == _selectedFilter;
    }).toList();
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: _selectedDay ?? DateTime.now(),
        onEventAdded: (event) {
          setState(() {
            _events.add(event);
            _selectedEvents.value = _getFilteredEvents();
          });
        },
      ),
    );
  }

  void _showEventDetails(CalendarEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventDetailsSheet(event),
    );
  }

  Widget _buildEventDetailsSheet(CalendarEventModel event) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Time
                  _buildDetailRow(
                    theme,
                    Icons.access_time,
                    '时间',
                    '${_formatDateTime(event.startTime)} - ${_formatDateTime(event.endTime)}',
                  ),
                  
                  // Location
                  if (event.location?.isNotEmpty == true)
                    _buildDetailRow(
                      theme,
                      Icons.location_on,
                      '地点',
                      event.location!,
                    ),
                  
                  // Category
                  _buildDetailRow(
                    theme,
                    Icons.category,
                    '分类',
                    event.type.toString().split('.').last,
                  ),
                  
                  // Description
                  if (event.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      '描述',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _editEvent(event);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('编辑'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteEvent(event);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('删除'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent(CalendarEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: event.startTime,
        event: event,
        onEventAdded: (updatedEvent) {
          setState(() {
            final index = _events.indexWhere((e) => e.id == event.id);
            if (index != -1) {
              _events[index] = updatedEvent;
              _selectedEvents.value = _getFilteredEvents();
            }
          });
        },
      ),
    );
  }

  void _deleteEvent(CalendarEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除事件'),
        content: Text('确定要删除事件"${event.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _events.removeWhere((e) => e.id == event.id);
                _selectedEvents.value = _getFilteredEvents();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('事件已删除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索事件'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '输入关键词搜索事件...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            _searchEvents(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _searchEvents(String query) {
    final results = _events.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
          (event.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (event.location?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
    
    _selectedEvents.value = results;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('找到 ${results.length} 个相关事件')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<CalendarEventModel> _generateMockEvents() {
    final now = DateTime.now();
    return [
      CalendarEventModel(
        id: '1',
        userId: 'current_user_id',
        title: '团队会议',
        description: '讨论项目进度和下周计划',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        location: '会议室A',
        type: EventType.work,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEventModel(
        id: '2',
        userId: 'current_user_id',
        title: '健身',
        description: '晚上去健身房锻炼',
        startTime: now.add(const Duration(days: 1, hours: 19)),
        endTime: now.add(const Duration(days: 1, hours: 21)),
        location: '健身房',
        type: EventType.personal,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEventModel(
        id: '3',
        userId: 'current_user_id',
        title: '生日聚会',
        description: '朋友生日聚会',
        startTime: DateTime(now.year, now.month, now.day + 2, 18, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 22, 0),
        location: '餐厅',
        type: EventType.personal,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEventModel(
        id: '4',
        userId: 'current_user_id',
        title: '项目截止日',
        description: '完成项目并提交',
        startTime: DateTime(now.year, now.month, now.day + 5),
        endTime: DateTime(now.year, now.month, now.day + 5),
        location: '',
        type: EventType.work,
        isAllDay: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}