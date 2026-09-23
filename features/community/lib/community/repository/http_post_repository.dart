import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_community/community/models/comment_model.dart';
import 'package:module_community/community/models/community_search_models.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_http/module_http.dart';

/// 社区动态 HTTP 实现，路径前缀 `/api/v1/community`。
class HttpPostRepository implements PostRepository {
  static const _prefix = '/api/v1/community';

  @override
  Future<List<PostModel>> fetchPosts({
    required int page,
    int pageSize = 10,
    String tab = 'latest',
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<PostModel>>>(
      '$_prefix/posts',
      queryParameters: {
        'page': page + 1,
        'size': pageSize,
        'tab': tab,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        PostModel.fromJson,
      ),
    );
    return _list(result.data, '加载动态失败');
  }

  @override
  Future<List<CommentModel>> fetchComments(String postId) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<CommentModel>>>(
      '$_prefix/posts/$postId/comments',
      queryParameters: const {'page': 1, 'size': 50},
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        CommentModel.fromJson,
      ),
    );
    return _list(result.data, '加载评论失败');
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? replyToNickname,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<CommentModel>>(
      '$_prefix/posts/$postId/comments',
      data: {
        'content': content,
        if (replyToNickname != null) 'reply_to_nickname': replyToNickname,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        CommentModel.fromJson,
      ),
    );
    return _data(result.data, '评论失败');
  }

  @override
  Future<PostModel> toggleLike(String postId, bool liked) async {
    AuthHttpConfig.ensureInitialized();
    final path = '$_prefix/posts/$postId/like';
    final HttpResult<ResultModel<PostModel>> result;
    if (liked) {
      result = await HttpManager.instance.post<ResultModel<PostModel>>(
        path,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          PostModel.fromLikeFragment,
        ),
      );
    } else {
      result = await HttpManager.instance.delete<ResultModel<PostModel>>(
        path,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          PostModel.fromLikeFragment,
        ),
      );
    }
    return _data(result.data, '操作失败');
  }

  @override
  Future<void> deletePost(String postId) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.delete<ResultModel<Map<String, dynamic>>>(
      '$_prefix/posts/$postId',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _dataAllowEmpty(result.data, '删除失败');
  }

  @override
  Future<PostModel> createPost({
    required String content,
    String mediaType = 'none',
    String? topicId,
    bool isAskEveryone = false,
    String source = '来自 iPhone',
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<PostModel>>(
      '$_prefix/posts',
      data: {
        'content': content,
        'media_type': mediaType,
        'image_urls': <String>[],
        'video_url': null,
        'video_cover_url': null,
        'topic_id': topicId,
        'is_ask_everyone': isAskEveryone,
        'source': source,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        PostModel.fromJson,
      ),
    );
    return _data(result.data, '发布失败');
  }

  @override
  Future<List<TopicModel>> fetchTopics({
    int page = 0,
    int pageSize = 20,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<TopicModel>>>(
      '$_prefix/topics',
      queryParameters: {
        'page': page + 1,
        'size': pageSize,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        TopicModel.fromJson,
      ),
    );
    return _list(result.data, '加载话题失败');
  }

  @override
  Future<List<TopicModel>> searchTopics(
    String query, {
    int page = 0,
    int pageSize = 20,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<TopicModel>>>(
      '$_prefix/topics/search',
      queryParameters: {
        'q': query,
        'page': page + 1,
        'size': pageSize,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        TopicModel.fromJson,
      ),
    );
    return _list(result.data, '搜索话题失败');
  }

  static List<T> _list<T>(ResultModel<ListData<T>>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data!.list;
  }

  static T _data<T>(ResultModel<T>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data as T;
  }

  static void _dataAllowEmpty(
    ResultModel<Map<String, dynamic>>? model,
    String fallback,
  ) {
    if (model == null || !model.isSuccess) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
  }

  @override
  Future<void> followUser(String userId) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '$_prefix/users/$userId/follow',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _dataAllowEmpty(result.data, '关注失败');
  }

  @override
  Future<void> unfollowUser(String userId) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.delete<ResultModel<Map<String, dynamic>>>(
      '$_prefix/users/$userId/follow',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _dataAllowEmpty(result.data, '取消关注失败');
  }

  @override
  Future<CommunitySearchAllResult> searchAll({
    required String q,
    int page = 0,
    int pageSize = 5,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<CommunitySearchAllResult>>(
      '$_prefix/search',
      queryParameters: {
        'q': q,
        'type': 'all',
        'page': page + 1,
        'size': pageSize,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        CommunitySearchAllResult.fromJson,
      ),
    );
    return _data(result.data, '搜索失败');
  }

  @override
  Future<PageResult<PostModel>> searchPosts({
    required String q,
    int page = 0,
    int pageSize = 10,
  }) {
    return _searchPage(
      q: q,
      type: 'post',
      page: page,
      pageSize: pageSize,
      fromJson: PostModel.fromJson,
      fallback: '搜索动态失败',
    );
  }

  @override
  Future<PageResult<TopicModel>> searchTopicsPage({
    required String q,
    int page = 0,
    int pageSize = 10,
  }) {
    return _searchPage(
      q: q,
      type: 'topic',
      page: page,
      pageSize: pageSize,
      fromJson: TopicModel.fromJson,
      fallback: '搜索话题失败',
    );
  }

  @override
  Future<PageResult<CommunityUserHit>> searchUsers({
    required String q,
    int page = 0,
    int pageSize = 10,
  }) {
    return _searchPage(
      q: q,
      type: 'user',
      page: page,
      pageSize: pageSize,
      fromJson: CommunityUserHit.fromJson,
      fallback: '搜索用户失败',
    );
  }

  Future<PageResult<T>> _searchPage<T>({
    required String q,
    required String type,
    required int page,
    required int pageSize,
    required T Function(Map<String, dynamic> json) fromJson,
    required String fallback,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<T>>>(
      '$_prefix/search',
      queryParameters: {
        'q': q,
        'type': type,
        'page': page + 1,
        'size': pageSize,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        fromJson,
      ),
    );
    final data = _listData(result.data, fallback);
    return PageResult.fromListData(data, pageSize: pageSize);
  }

  static ListData<T> _listData<T>(
    ResultModel<ListData<T>>? model,
    String fallback,
  ) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data!;
  }
}
