enum ShortVideoCellType { publish, video }

enum ShortVideoStatus { normal, reviewing, uploading }

class ShortVideoItemModel {
  const ShortVideoItemModel({
    required this.type,
    this.id,
    this.title,
    this.coverUrl,
    this.videoUrl,
    this.viewCount,
    this.duration,
    this.aspectRatio = 1.25,
    this.status = ShortVideoStatus.normal,
  });

  final ShortVideoCellType type;
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? videoUrl;
  final int? viewCount;
  final String? duration;
  final double aspectRatio;
  final ShortVideoStatus status;

  bool get isPublish => type == ShortVideoCellType.publish;
}

class ShortVideoStatsModel {
  const ShortVideoStatsModel({
    required this.videoCount,
    required this.viewCount,
    required this.likeCount,
  });

  final String videoCount;
  final String viewCount;
  final String likeCount;

  static const empty = ShortVideoStatsModel(
    videoCount: '0',
    viewCount: '0',
    likeCount: '0',
  );

  static const demo = ShortVideoStatsModel(
    videoCount: '105',
    viewCount: '282',
    likeCount: '66',
  );
}

class ShortVideoProfileModel {
  const ShortVideoProfileModel({
    required this.displayName,
    required this.avatarUrl,
    required this.roleBadge,
    required this.storeName,
    required this.stats,
  });

  final String displayName;
  final String? avatarUrl;
  final String roleBadge;
  final String storeName;
  final ShortVideoStatsModel stats;
}
