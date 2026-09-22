enum ShortVideoCellType { publish, video }

enum ShortVideoStatus { normal, reviewing, uploading }

class ShortVideoTopicBrief {
  const ShortVideoTopicBrief({required this.id, required this.name});

  factory ShortVideoTopicBrief.fromJson(Map<String, dynamic> json) {
    return ShortVideoTopicBrief(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;

  String get displayName => '#$name';
}

class ShortVideoItemModel {
  const ShortVideoItemModel({
    required this.type,
    this.id,
    this.title,
    this.coverUrl,
    this.videoUrl,
    this.viewCount,
    this.likeCount,
    this.duration,
    this.aspectRatio = 1.25,
    this.status = ShortVideoStatus.normal,
    this.isLiked = false,
    this.isMine = false,
    this.userId,
    this.nickname,
    this.avatar,
    this.topic,
    this.publishTime,
  });

  factory ShortVideoItemModel.fromJson(Map<String, dynamic> json) {
    return ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      viewCount: (json['view_count'] as num?)?.toInt(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      duration: json['duration']?.toString(),
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1.25,
      status: _parseStatus(json['status']?.toString()),
      isLiked: json['is_liked'] == true,
      isMine: json['is_mine'] == true,
      userId: json['user_id']?.toString(),
      nickname: json['nickname']?.toString(),
      avatar: json['avatar']?.toString(),
      topic: json['topic'] is Map<String, dynamic>
          ? ShortVideoTopicBrief.fromJson(
              json['topic'] as Map<String, dynamic>,
            )
          : null,
      publishTime: json['publish_time']?.toString(),
    );
  }

  /// 点赞接口片段：`{ id, like_count, is_liked }`。
  factory ShortVideoItemModel.fromLikeFragment(Map<String, dynamic> json) {
    return ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: json['id']?.toString(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true,
    );
  }

  static const publishTile = ShortVideoItemModel(
    type: ShortVideoCellType.publish,
    aspectRatio: 1.0,
  );

  final ShortVideoCellType type;
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? videoUrl;
  final int? viewCount;
  final int? likeCount;
  final String? duration;
  final double aspectRatio;
  final ShortVideoStatus status;
  final bool isLiked;
  final bool isMine;
  final String? userId;
  final String? nickname;
  final String? avatar;
  final ShortVideoTopicBrief? topic;
  final String? publishTime;

  bool get isPublish => type == ShortVideoCellType.publish;

  ShortVideoItemModel copyWith({
    int? viewCount,
    int? likeCount,
    bool? isLiked,
    ShortVideoStatus? status,
  }) {
    return ShortVideoItemModel(
      type: type,
      id: id,
      title: title,
      coverUrl: coverUrl,
      videoUrl: videoUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      duration: duration,
      aspectRatio: aspectRatio,
      status: status ?? this.status,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine,
      userId: userId,
      nickname: nickname,
      avatar: avatar,
      topic: topic,
      publishTime: publishTime,
    );
  }

  static ShortVideoStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'reviewing':
        return ShortVideoStatus.reviewing;
      case 'uploading':
        return ShortVideoStatus.uploading;
      default:
        return ShortVideoStatus.normal;
    }
  }
}

class ShortVideoStatsModel {
  const ShortVideoStatsModel({
    required this.videoCount,
    required this.viewCount,
    required this.likeCount,
  });

  factory ShortVideoStatsModel.fromJson(Map<String, dynamic> json) {
    return ShortVideoStatsModel(
      videoCount: _n(json['video_count']),
      viewCount: _n(json['view_count']),
      likeCount: _n(json['like_count']),
    );
  }

  final String videoCount;
  final String viewCount;
  final String likeCount;

  static const empty = ShortVideoStatsModel(
    videoCount: '0',
    viewCount: '0',
    likeCount: '0',
  );

  static String _n(dynamic v) => ((v as num?)?.toInt() ?? 0).toString();
}

class ShortVideoProfileModel {
  const ShortVideoProfileModel({
    required this.displayName,
    required this.avatarUrl,
    required this.roleBadge,
    required this.storeName,
    required this.stats,
    this.userId,
    this.isMe = true,
  });

  factory ShortVideoProfileModel.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    return ShortVideoProfileModel(
      userId: json['user_id']?.toString(),
      displayName: json['display_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      roleBadge: json['role_badge']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      isMe: json['is_me'] == true,
      stats: statsRaw is Map<String, dynamic>
          ? ShortVideoStatsModel.fromJson(statsRaw)
          : ShortVideoStatsModel.empty,
    );
  }

  final String? userId;
  final String displayName;
  final String? avatarUrl;
  final String roleBadge;
  final String storeName;
  final bool isMe;
  final ShortVideoStatsModel stats;
}
