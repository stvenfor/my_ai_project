class CommentModel {
  CommentModel({
    required this.id,
    required this.postId,
    required this.nickname,
    required this.avatar,
    required this.content,
    required this.createTime,
    this.replyToNickname,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createTime: DateTime.tryParse(json['create_time']?.toString() ?? '') ??
          DateTime.now(),
      replyToNickname: json['reply_to_nickname']?.toString(),
    );
  }

  final String id;
  final String postId;
  final String nickname;
  final String avatar;
  final String content;
  final DateTime createTime;
  final String? replyToNickname;

  CommentModel copyWith({
    String? id,
    String? postId,
    String? nickname,
    String? avatar,
    String? content,
    DateTime? createTime,
    String? replyToNickname,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      createTime: createTime ?? this.createTime,
      replyToNickname: replyToNickname ?? this.replyToNickname,
    );
  }
}
