import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_video/short_video/model/short_video_models.dart';
import 'package:module_video/short_video/repository/short_video_repository.dart';

/// 小视频 HTTP，前缀 `/api/v1/short-videos`。
class HttpShortVideoRepository implements ShortVideoRepository {
  static const _prefix = '/api/v1/short-videos';

  @override
  Future<ShortVideoProfileModel> fetchProfile({String? userId}) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.get<ResultModel<ShortVideoProfileModel>>(
      '$_prefix/profile',
      queryParameters: {
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        ShortVideoProfileModel.fromJson,
      ),
    );
    return _data(result.data, '加载资料失败');
  }

  @override
  Future<ShortVideoListPage> fetchList({
    required String scope,
    String? userId,
    int page = 0,
    int pageSize = 5,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance
        .get<ResultModel<ListData<ShortVideoItemModel>>>(
      _prefix,
      queryParameters: {
        'scope': scope,
        'page': page + 1,
        'size': pageSize,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        ShortVideoItemModel.fromJson,
      ),
    );
    final data = _listData(result.data, '加载小视频失败');
    return ShortVideoListPage(
      list: data.list,
      hasMore: data.pagination?.hasMore ?? (data.list.length >= pageSize),
    );
  }

  @override
  Future<ShortVideoItemModel> create({
    required String title,
    String? topicId,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.post<ResultModel<ShortVideoItemModel>>(
      _prefix,
      data: {
        'title': title,
        'video_url': null,
        'cover_url': null,
        'duration': null,
        'aspect_ratio': null,
        'topic_id': topicId,
      },
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        ShortVideoItemModel.fromJson,
      ),
    );
    return _data(result.data, '发布失败');
  }

  @override
  Future<void> delete(String id) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.delete<ResultModel<Map<String, dynamic>>>(
      '$_prefix/$id',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data as Map),
      ),
    );
    _dataAllowEmpty(result.data, '删除失败');
  }

  @override
  Future<ShortVideoItemModel> toggleLike(String id, bool liked) async {
    AuthHttpConfig.ensureInitialized();
    final path = '$_prefix/$id/like';
    final HttpResult<ResultModel<ShortVideoItemModel>> result;
    if (liked) {
      result = await HttpManager.instance.post<ResultModel<ShortVideoItemModel>>(
        path,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          ShortVideoItemModel.fromLikeFragment,
        ),
      );
    } else {
      result =
          await HttpManager.instance.delete<ResultModel<ShortVideoItemModel>>(
        path,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          ShortVideoItemModel.fromLikeFragment,
        ),
      );
    }
    return _data(result.data, '操作失败');
  }

  @override
  Future<int> reportView(String id) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '$_prefix/$id/view',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data as Map),
      ),
    );
    final data = _data(result.data, '上报播放失败');
    return (data['view_count'] as num?)?.toInt() ?? 0;
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
}
