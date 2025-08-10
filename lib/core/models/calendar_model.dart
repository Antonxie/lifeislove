import 'dart:convert';

class CalendarEventModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final EventType type;
  final EventPriority priority;
  final List<String> tags;
  final String? color; // 事件颜色
  final Map<String, dynamic>? metadata; // 额外数据
  final ReminderSettings? reminder;
  final RecurrenceRule? recurrence;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEventModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.location,
    this.type = EventType.personal,
    this.priority = EventPriority.normal,
    this.tags = const [],
    this.color,
    this.metadata,
    this.reminder,
    this.recurrence,
    required this.createdAt,
    required this.updatedAt,
  });

  CalendarEventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? location,
    EventType? type,
    EventPriority? priority,
    List<String>? tags,
    String? color,
    Map<String, dynamic>? metadata,
    ReminderSettings? reminder,
    RecurrenceRule? recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
      reminder: reminder ?? this.reminder,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'isAllDay': isAllDay ? 1 : 0,
      'location': location,
      'type': type.index,
      'priority': priority.index,
      'tags': json.encode(tags),
      'color': color,
      'metadata': metadata != null ? json.encode(metadata) : null,
      'reminder': reminder?.toJson(),
      'recurrence': recurrence?.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      isAllDay: (map['isAllDay'] ?? 0) == 1,
      location: map['location'],
      type: EventType.values[map['type'] ?? 0],
      priority: EventPriority.values[map['priority'] ?? 1],
      tags: map['tags'] != null 
          ? List<String>.from(json.decode(map['tags']))
          : [],
      color: map['color'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata']))
          : null,
      reminder: map['reminder'] != null 
          ? ReminderSettings.fromJson(map['reminder'])
          : null,
      recurrence: map['recurrence'] != null 
          ? RecurrenceRule.fromJson(map['recurrence'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CalendarEventModel.fromJson(String source) => CalendarEventModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum EventType {
  personal,
  work,
  social,
  health,
  travel,
  reminder,
  birthday,
  anniversary,
}

enum EventPriority {
  low,
  normal,
  high,
  urgent,
}

class ReminderSettings {
  final List<int> minutesBefore; // 提前多少分钟提醒
  final bool isEnabled;

  ReminderSettings({
    required this.minutesBefore,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'minutesBefore': minutesBefore,
      'isEnabled': isEnabled,
    };
  }

  factory ReminderSettings.fromMap(Map<String, dynamic> map) {
    return ReminderSettings(
      minutesBefore: List<int>.from(map['minutesBefore'] ?? [15]),
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReminderSettings.fromJson(String source) => ReminderSettings.fromMap(json.decode(source));
}

class RecurrenceRule {
  final RecurrenceType type;
  final int interval; // 间隔
  final List<int>? daysOfWeek; // 周几重复 (1-7, 1=Monday)
  final int? dayOfMonth; // 每月第几天
  final DateTime? endDate; // 重复结束日期
  final int? count; // 重复次数

  RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.millisecondsSinceEpoch,
      'count': count,
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      type: RecurrenceType.values[map['type'] ?? 0],
      interval: map['interval'] ?? 1,
      daysOfWeek: map['daysOfWeek'] != null 
          ? List<int>.from(map['daysOfWeek'])
          : null,
      dayOfMonth: map['dayOfMonth'],
      endDate: map['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      count: map['count'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RecurrenceRule.fromJson(String source) => RecurrenceRule.fromMap(json.decode(source));
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

// RAG数据模型，用于存储压缩的生活轨迹和对话数据
class RAGDataModel {
  final String id;
  final String userId;
  final RAGDataType type;
  final String title;
  final String content; // 压缩后的内容
  final String summary; // 摘要
  final List<String> keywords; // 关键词
  final Map<String, dynamic> metadata; // 元数据
  final List<double>? embedding; // 向量嵌入
  final DateTime originalDate; // 原始数据日期
  final DateTime createdAt;
  final DateTime updatedAt;
  final double relevanceScore; // 相关性分数

  RAGDataModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.summary,
    this.keywords = const [],
    this.metadata = const {},
    this.embedding,
    required this.originalDate,
    required this.createdAt,
    required this.updatedAt,
    this.relevanceScore = 0.0,
  });

  RAGDataModel copyWith({
    String? id,
    String? userId,
    RAGDataType? type,
    String? title,
    String? content,
    String? summary,
    List<String>? keywords,
    Map<String, dynamic>? metadata,
    List<double>? embedding,
    DateTime? originalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  }) {
    return RAGDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      keywords: keywords ?? this.keywords,
      metadata: metadata ?? this.metadata,
      embedding: embedding ?? this.embedding,
      originalDate: originalDate ?? this.originalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'title': title,
      'content': content,
      'summary': summary,
      'keywords': json.encode(keywords),
      'metadata': json.encode(metadata),
      'embedding': embedding != null ? json.encode(embedding) : null,
      'originalDate': originalDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'relevanceScore': relevanceScore,
    };
  }

  factory RAGDataModel.fromMap(Map<String, dynamic> map) {
    return RAGDataModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: RAGDataType.values[map['type'] ?? 0],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      summary: map['summary'] ?? '',
      keywords: map['keywords'] != null 
          ? List<String>.from(json.decode(map['keywords']))
          : [],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata']))
          : {},
      embedding: map['embedding'] != null 
          ? List<double>.from(json.decode(map['embedding']))
          : null,
      originalDate: DateTime.fromMillisecondsSinceEpoch(map['originalDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      relevanceScore: map['relevanceScore']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory RAGDataModel.fromJson(String source) => RAGDataModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RAGDataModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum RAGDataType {
  conversation, // 对话记录
  activity,     // 活动记录
  location,     // 位置记录
  mood,         // 心情记录
  photo,        // 照片记录
  note,         // 笔记记录
  event,        // 事件记录
  habit,        // 习惯记录
}