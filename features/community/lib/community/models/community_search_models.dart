import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_http/module_http.dart';

class CommunityUserHit {
  const CommunityUserHit({
    required this.userId,
    required this.nickname,
    required this.avatar,
    this.isFollowed = false,
  });

  factory CommunityUserHit.fromJson(Map<String, dynamic> json) {
    return CommunityUserHit(
      userId: json['user_id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      isFollowed: json['is_followed'] == true,
    );
  }

  final String userId;
  final String nickname;
  final String avatar;
  final bool isFollowed;

  CommunityUserHit copyWith({bool? isFollowed}) {
    return CommunityUserHit(
      userId: userId,
      nickname: nickname,
      avatar: avatar,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

class CommunitySearchAllResult {
  const CommunitySearchAllResult({
    required this.q,
    required this.posts,
    required this.topics,
    required this.users,
  });

  factory CommunitySearchAllResult.fromJson(Map<String, dynamic> json) {
    return CommunitySearchAllResult(
      q: json['q']?.toString() ?? '',
      posts: ListData.fromJson(json['posts'], PostModel.fromJson),
      topics: ListData.fromJson(json['topics'], TopicModel.fromJson),
      users: ListData.fromJson(json['users'], CommunityUserHit.fromJson),
    );
  }

  final String q;
  final ListData<PostModel> posts;
  final ListData<TopicModel> topics;
  final ListData<CommunityUserHit> users;
}
