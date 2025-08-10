import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      bio: map['bio'],
      avatarUrl: map['avatarUrl'],
      coverUrl: map['coverUrl'],
      followersCount: map['followersCount']?.toInt() ?? 0,
      followingCount: map['followingCount']?.toInt() ?? 0,
      postsCount: map['postsCount']?.toInt() ?? 0,
      isVerified: (map['isVerified'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, coverUrl: $coverUrl, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.username == username &&
      other.email == email &&
      other.displayName == displayName &&
      other.bio == bio &&
      other.avatarUrl == avatarUrl &&
      other.coverUrl == coverUrl &&
      other.followersCount == followersCount &&
      other.followingCount == followingCount &&
      other.postsCount == postsCount &&
      other.isVerified == isVerified &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      bio.hashCode ^
      avatarUrl.hashCode ^
      coverUrl.hashCode ^
      followersCount.hashCode ^
      followingCount.hashCode ^
      postsCount.hashCode ^
      isVerified.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}