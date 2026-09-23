import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/community_search_models.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_http/module_http.dart';

abstract class PostRepository {
  /// [page] 为 Flutter 0-based 页码。
  /// [tab]：`latest` | `hot` | `following`（对齐社区顶栏）。
  Future<List<PostModel>> fetchPosts({
    required int page,
    int pageSize = 10,
    String tab = 'latest',
  });

  Future<List<CommentModel>> fetchComments(String postId);

  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? replyToNickname,
  });

  Future<PostModel> toggleLike(String postId, bool liked);

  Future<void> deletePost(String postId);

  Future<PostModel> createPost({
    required String content,
    String mediaType = 'none',
    String? topicId,
    bool isAskEveryone = false,
    String source = '来自 iPhone',
  });

  /// [page] 为 Flutter 0-based 页码。
  Future<List<TopicModel>> fetchTopics({int page = 0, int pageSize = 20});

  Future<List<TopicModel>> searchTopics(
    String query, {
    int page = 0,
    int pageSize = 20,
  });

  /// 关注 / 取消关注作者（关注 Tab 数据源）。
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);

  /// 社区综合搜索 `GET /community/search?type=all`。
  Future<CommunitySearchAllResult> searchAll({
    required String q,
    int page = 0,
    int pageSize = 5,
  });

  Future<PageResult<PostModel>> searchPosts({
    required String q,
    int page = 0,
    int pageSize = 10,
  });

  Future<PageResult<TopicModel>> searchTopicsPage({
    required String q,
    int page = 0,
    int pageSize = 10,
  });

  Future<PageResult<CommunityUserHit>> searchUsers({
    required String q,
    int page = 0,
    int pageSize = 10,
  });
}
