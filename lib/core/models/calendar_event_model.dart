class CalendarEventModel {
  final int? id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String category;
  final bool isAllDay;
  final List<String> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEventModel({
    this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.category,
    this.isAllDay = false,
    this.reminders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'location': location,
      'category': category,
      'isAllDay': isAllDay ? 1 : 0,
      'reminders': reminders.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      location: map['location'],
      category: map['category'] ?? 'general',
      isAllDay: map['isAllDay'] == 1,
      reminders: map['reminders'] != null && map['reminders'].isNotEmpty
          ? map['reminders'].split(',')
          : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  CalendarEventModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? category,
    bool? isAllDay,
    List<String>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CalendarEventModel(id: $id, title: $title, startTime: $startTime, endTime: $endTime, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEventModel &&
        other.id == id &&
        other.title == title &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        startTime.hashCode ^
        endTime.hashCode;
  }
}