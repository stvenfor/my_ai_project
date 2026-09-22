import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';

abstract class PostRepository {
  /// [page] 为 Flutter 0-based 页码。
  Future<List<PostModel>> fetchPosts({required int page, int pageSize = 10});

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
}
