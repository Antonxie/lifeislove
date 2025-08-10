class RagDataModel {
  final int? id;
  final String content;
  final String type; // 'post', 'message', 'event', 'user_data'
  final String? metadata; // JSON string for additional data
  final List<double> embedding; // Vector embedding for RAG
  final DateTime createdAt;
  final DateTime updatedAt;

  RagDataModel({
    this.id,
    required this.content,
    required this.type,
    this.metadata,
    required this.embedding,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'metadata': metadata,
      'embedding': embedding.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory RagDataModel.fromMap(Map<String, dynamic> map) {
    return RagDataModel(
      id: map['id']?.toInt(),
      content: map['content'] ?? '',
      type: map['type'] ?? 'unknown',
      metadata: map['metadata'],
      embedding: map['embedding'] != null && map['embedding'].isNotEmpty
          ? map['embedding'].split(',').map((e) => double.tryParse(e) ?? 0.0).toList()
          : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  RagDataModel copyWith({
    int? id,
    String? content,
    String? type,
    String? metadata,
    List<double>? embedding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RagDataModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      embedding: embedding ?? this.embedding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RagDataModel(id: $id, content: $content, type: $type, embeddingLength: ${embedding.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RagDataModel &&
        other.id == id &&
        other.content == content &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        type.hashCode;
  }
}