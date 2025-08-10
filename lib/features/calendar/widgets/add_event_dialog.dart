import 'package:flutter/material.dart';
import '../../../core/models/calendar_model.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarEventModel? event;
  final Function(CalendarEventModel) onEventAdded;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    this.event,
    required this.onEventAdded,
  }) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  
  bool _isAllDay = false;
  String _selectedCategory = 'personal';
  List<int> _reminders = [15]; // Default 15 minutes before
  
  final List<String> _categories = [
    'personal',
    'work',
    'reminder',
    'health',
    'social',
    'travel',
    'education',
  ];
  
  final Map<String, String> _categoryNames = {
    'personal': '个人',
    'work': '工作',
    'reminder': '提醒',
    'health': '健康',
    'social': '社交',
    'travel': '旅行',
    'education': '学习',
  };
  
  final List<int> _reminderOptions = [0, 5, 15, 30, 60, 120, 1440]; // minutes
  final Map<int, String> _reminderNames = {
    0: '准时',
    5: '5分钟前',
    15: '15分钟前',
    30: '30分钟前',
    60: '1小时前',
    120: '2小时前',
    1440: '1天前',
  };

  @override
  void initState() {
    super.initState();
    
    if (widget.event != null) {
      // Edit mode
      final event = widget.event!;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _locationController.text = event.location ?? '';
      _startDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = DateTime(
        event.endTime.year,
        event.endTime.month,
        event.endTime.day,
      );
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _isAllDay = event.isAllDay;
      _selectedCategory = event.type.toString().split('.').last;
      _reminders = event.reminder != null ? event.reminder!.minutesBefore : [];
    } else {
      // Add mode
      _startDate = widget.selectedDate;
      _startTime = TimeOfDay.now();
      _endDate = widget.selectedDate;
      _endTime = TimeOfDay(
        hour: TimeOfDay.now().hour + 1,
        minute: TimeOfDay.now().minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.event != null ? '编辑事件' : '添加事件',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '事件标题',
                          hintText: '输入事件标题',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入事件标题';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '分类',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_categoryNames[category] ?? category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // All day toggle
                      SwitchListTile(
                        title: const Text('全天事件'),
                        subtitle: const Text('事件持续整天'),
                        value: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      
                      // Start date and time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectStartDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '开始日期',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_startDate)),
                              ),
                            ),
                          ),
                          if (!_isAllDay) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: '开始时间',
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_startTime.format(context)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // End date and time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectEndDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '结束日期',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_endDate)),
                              ),
                            ),
                          ),
                          if (!_isAllDay) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _selectEndTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: '结束时间',
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_endTime.format(context)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: '地点 (可选)',
                          hintText: '输入事件地点',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述 (可选)',
                          hintText: '输入事件描述',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Reminders
                      Text(
                        '提醒',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _reminderOptions.map((minutes) {
                          final isSelected = _reminders.contains(minutes);
                          return FilterChip(
                            label: Text(_reminderNames[minutes] ?? '${minutes}分钟前'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _reminders.add(minutes);
                                } else {
                                  _reminders.remove(minutes);
                                }
                                _reminders.sort();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      child: Text(widget.event != null ? '保存' : '添加'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
        // Ensure end date is not before start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    
    if (time != null) {
      setState(() {
        _startTime = time;
        // Ensure end time is after start time on the same day
        if (_startDate.isAtSameMomentAs(_endDate)) {
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          if (endMinutes <= startMinutes) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate time logic
    final startDateTime = _isAllDay
        ? DateTime(_startDate.year, _startDate.month, _startDate.day)
        : DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          );
    
    final endDateTime = _isAllDay
        ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59)
        : DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
    
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('结束时间不能早于开始时间')),
      );
      return;
    }
    
    final now = DateTime.now();
    final event = CalendarEventModel(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.event?.userId ?? 'current_user_id', // TODO: Replace with actual user ID
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim(),
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedCategory,
        orElse: () => EventType.personal,
      ),
      isAllDay: _isAllDay,
      reminder: _reminders.isNotEmpty ? ReminderSettings(minutesBefore: _reminders) : null,
      createdAt: widget.event?.createdAt ?? now,
      updatedAt: now,
    );
    
    widget.onEventAdded(event);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.event != null ? '事件已更新' : '事件已添加'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}