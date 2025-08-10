import 'dart:convert';

class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? location;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isBookmarked;
  final PostType type;
  final PostVisibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 用户信息（用于显示）
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    this.location,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.type = PostType.text,
    this.visibility = PostVisibility.public,
    required this.createdAt,
    required this.updatedAt,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    String? location,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isBookmarked,
    PostType? type,
    PostVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorUsername,
    String? authorDisplayName,
    String? authorAvatarUrl,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrls': json.encode(imageUrls),
      'videoUrl': videoUrl,
      'location': location,
      'tags': json.encode(tags),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLiked': isLiked ? 1 : 0,
      'isBookmarked': isBookmarked ? 1 : 0,
      'type': type.index,
      'visibility': visibility.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorUsername': authorUsername,
      'authorDisplayName': authorDisplayName,
      'authorAvatarUrl': authorAvatarUrl,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(json.decode(map['imageUrls']))
          : [],
      videoUrl: map['videoUrl'],
      location: map['location'],
      tags: map['tags'] != null 
          ? List<String>.from(json.decode(map['tags']))
          : [],
      likesCount: map['likesCount']?.toInt() ?? 0,
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      sharesCount: map['sharesCount']?.toInt() ?? 0,
      isLiked: (map['isLiked'] ?? 0) == 1,
      isBookmarked: (map['isBookmarked'] ?? 0) == 1,
      type: PostType.values[map['type'] ?? 0],
      visibility: PostVisibility.values[map['visibility'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      authorUsername: map['authorUsername'],
      authorDisplayName: map['authorDisplayName'],
      authorAvatarUrl: map['authorAvatarUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) => PostModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PostModel(id: $id, userId: $userId, content: $content, imageUrls: $imageUrls, videoUrl: $videoUrl, location: $location, tags: $tags, likesCount: $likesCount, commentsCount: $commentsCount, sharesCount: $sharesCount, isLiked: $isLiked, isBookmarked: $isBookmarked, type: $type, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum PostType {
  text,
  image,
  video,
  mixed,
}

enum PostVisibility {
  public,
  friends,
  private,
}

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId; // 用于回复评论
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 用户信息
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorUsername,
    String? authorDisplayName,
    String? authorAvatarUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'parentId': parentId,
      'likesCount': likesCount,
      'isLiked': isLiked ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorUsername': authorUsername,
      'authorDisplayName': authorDisplayName,
      'authorAvatarUrl': authorAvatarUrl,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      parentId: map['parentId'],
      likesCount: map['likesCount']?.toInt() ?? 0,
      isLiked: (map['isLiked'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      authorUsername: map['authorUsername'],
      authorDisplayName: map['authorDisplayName'],
      authorAvatarUrl: map['authorAvatarUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) => CommentModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}