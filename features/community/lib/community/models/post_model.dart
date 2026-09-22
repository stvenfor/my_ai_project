import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/topic_model.dart';

class PostModel {
  PostModel({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.avatar,
    required this.content,
    required this.publishTime,
    this.source = '来自 iPhone',
    this.images = const [],
    this.videoUrl,
    this.videoCoverUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isMine = false,
    this.previewComments = const [],
    this.mediaType,
    this.isAskEveryone = false,
    this.topic,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final topicJson = json['topic'];
    TopicModel? topic;
    if (topicJson is Map<String, dynamic>) {
      topic = TopicModel.fromJson(topicJson);
    }

    final imagesRaw = json['images'] ?? json['image_urls'];
    final images = imagesRaw is List
        ? imagesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final mediaType = json['media_type']?.toString();

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      publishTime:
          DateTime.tryParse(json['publish_time']?.toString() ?? '') ??
              DateTime.now(),
      source: json['source']?.toString() ?? '来自 iPhone',
      images: images,
      videoUrl: json['video_url']?.toString(),
      videoCoverUrl: json['video_cover_url']?.toString(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true,
      isMine: json['is_mine'] == true,
      previewComments: _parseComments(json['preview_comments']),
      mediaType: mediaType,
      isAskEveryone: json['is_ask_everyone'] == true ||
          (topic?.isAskEveryone ?? false),
      topic: topic,
    );
  }

  /// 点赞接口片段：仅含 id / like_count / is_liked。
  factory PostModel.fromLikeFragment(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: '',
      nickname: '',
      avatar: '',
      content: '',
      publishTime: DateTime.now(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true,
    );
  }

  static List<CommentModel> _parseComments(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromJson)
        .toList();
  }

  final String id;
  final String userId;
  final String nickname;
  final String avatar;
  final String content;
  final DateTime publishTime;
  final String source;
  final List<String> images;
  final String? videoUrl;
  final String? videoCoverUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isMine;
  final List<CommentModel> previewComments;

  /// `none` | `image` | `video`（读模型可选）
  final String? mediaType;
  final bool isAskEveryone;
  final TopicModel? topic;

  bool get hasImages => images.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  PostModel copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? avatar,
    String? content,
    DateTime? publishTime,
    String? source,
    List<String>? images,
    String? videoUrl,
    String? videoCoverUrl,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isMine,
    List<CommentModel>? previewComments,
    String? mediaType,
    bool? isAskEveryone,
    TopicModel? topic,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      publishTime: publishTime ?? this.publishTime,
      source: source ?? this.source,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      videoCoverUrl: videoCoverUrl ?? this.videoCoverUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine ?? this.isMine,
      previewComments: previewComments ?? this.previewComments,
      mediaType: mediaType ?? this.mediaType,
      isAskEveryone: isAskEveryone ?? this.isAskEveryone,
      topic: topic ?? this.topic,
    );
  }
}
