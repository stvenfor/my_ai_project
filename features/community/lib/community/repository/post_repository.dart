import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> fetchPosts({required int page, int pageSize = 10});

  Future<List<CommentModel>> fetchComments(String postId);

  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? replyToNickname,
  });

  Future<PostModel> toggleLike(String postId, bool liked);

  Future<void> deletePost(String postId);
}
