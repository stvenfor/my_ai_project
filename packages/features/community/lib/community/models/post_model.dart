import 'package:module_community/community/models/comment_model.dart';

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
  });

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
    );
  }
}
