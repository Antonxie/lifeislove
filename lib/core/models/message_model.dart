import 'dart:convert';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId; // null for group messages
  final String content;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata; // 额外数据，如文件大小、时长等
  final String? replyToId; // 回复的消息ID
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  
  // 发送者信息（用于显示）
  final String? senderUsername;
  final String? senderDisplayName;
  final String? senderAvatarUrl;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.type,
    this.status = MessageStatus.sending,
    this.mediaUrl,
    this.thumbnailUrl,
    this.metadata,
    this.replyToId,
    required this.createdAt,
    this.readAt,
    this.deliveredAt,
    this.senderUsername,
    this.senderDisplayName,
    this.senderAvatarUrl,
  });

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    String? replyToId,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? deliveredAt,
    String? senderUsername,
    String? senderDisplayName,
    String? senderAvatarUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      replyToId: replyToId ?? this.replyToId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      senderUsername: senderUsername ?? this.senderUsername,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.index,
      'status': status.index,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata != null ? json.encode(metadata) : null,
      'replyToId': replyToId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'readAt': readAt?.millisecondsSinceEpoch,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'senderUsername': senderUsername,
      'senderDisplayName': senderDisplayName,
      'senderAvatarUrl': senderAvatarUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      content: map['content'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      status: MessageStatus.values[map['status'] ?? 0],
      mediaUrl: map['mediaUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata']))
          : null,
      replyToId: map['replyToId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      readAt: map['readAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['readAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'])
          : null,
      senderUsername: map['senderUsername'],
      senderDisplayName: map['senderDisplayName'],
      senderAvatarUrl: map['senderAvatarUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  sticker,
  system, // 系统消息
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ConversationModel {
  final String id;
  final String name;
  final ConversationType type;
  final List<String> participantIds;
  final String? lastMessageId;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 最后一条消息的发送者信息
  final String? lastMessageSenderName;

  ConversationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.participantIds,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageSenderName,
  });

  ConversationModel copyWith({
    String? id,
    String? name,
    ConversationType? type,
    List<String>? participantIds,
    String? lastMessageId,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageSenderName,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageSenderName: lastMessageSenderName ?? this.lastMessageSenderName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'participantIds': json.encode(participantIds),
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'isMuted': isMuted ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastMessageSenderName': lastMessageSenderName,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ConversationType.values[map['type'] ?? 0],
      participantIds: List<String>.from(json.decode(map['participantIds'] ?? '[]')),
      lastMessageId: map['lastMessageId'],
      lastMessageContent: map['lastMessageContent'],
      lastMessageTime: map['lastMessageTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      unreadCount: map['unreadCount']?.toInt() ?? 0,
      isMuted: (map['isMuted'] ?? 0) == 1,
      isPinned: (map['isPinned'] ?? 0) == 1,
      avatarUrl: map['avatarUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      lastMessageSenderName: map['lastMessageSenderName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ConversationModel.fromJson(String source) => ConversationModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ConversationType {
  direct, // 私聊
  group,  // 群聊
}