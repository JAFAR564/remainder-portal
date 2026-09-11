/// Persistent domain model for Sanctuary Social Posts.
class SocialPostEntry {
  final String id;
  final String authorId;
  final String authorName;
  final String authorTitle;
  final String avatarPath;
  final String content;
  final bool isIC;
  final int laurelsCount;
  final int commentsCount;
  final DateTime createdAt;

  const SocialPostEntry({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorTitle,
    required this.avatarPath,
    required this.content,
    this.isIC = true,
    this.laurelsCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  SocialPostEntry copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorTitle,
    String? avatarPath,
    String? content,
    bool? isIC,
    int? laurelsCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return SocialPostEntry(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorTitle: authorTitle ?? this.authorTitle,
      avatarPath: avatarPath ?? this.avatarPath,
      content: content ?? this.content,
      isIC: isIC ?? this.isIC,
      laurelsCount: laurelsCount ?? this.laurelsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'author_name': authorName,
      'author_title': authorTitle,
      'avatar_path': avatarPath,
      'content': content,
      'is_ic': isIC ? 1 : 0,
      'laurels_count': laurelsCount,
      'comments_count': commentsCount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SocialPostEntry.fromJson(Map<String, dynamic> json) {
    return SocialPostEntry(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorTitle: json['author_title'] as String,
      avatarPath: json['avatar_path'] as String? ?? 'assets/icon/app_icon.png',
      content: json['content'] as String,
      isIC: json['is_ic'] == 1 || json['is_ic'] == true,
      laurelsCount: (json['laurels_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : DateTime.now(),
    );
  }
}

/// Persistent domain model for Sanctuary Post Comments.
class SocialCommentEntry {
  final String id;
  final String postId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const SocialCommentEntry({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_name': authorName,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SocialCommentEntry.fromJson(Map<String, dynamic> json) {
    return SocialCommentEntry(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorName: json['author_name'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : DateTime.now(),
    );
  }
}
