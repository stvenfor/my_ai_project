import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_home/home/model/points_models.dart';
import 'package:module_http/module_http.dart';

/// 签到与积分 SessionAuth API。
class PointsApi {
  static const statusPath = '/api/v1/points/status';
  static const checkInPath = '/api/v1/points/check-in';
  static const tasksPath = '/api/v1/points/tasks';

  Future<PointsStatus> fetchStatus() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<PointsStatus>>(
      statusPath,
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        PointsStatus.fromJson,
      ),
    );
    return _data(result.data, '加载签到状态失败');
  }

  Future<CheckInResult> checkIn() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<CheckInResult>>(
      checkInPath,
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        CheckInResult.fromJson,
      ),
    );
    return _data(result.data, '签到失败');
  }

  Future<List<GrowthTask>> fetchTasks() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<List<GrowthTask>>>(
      tasksPath,
      converter: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        final envelope = data is Map<String, dynamic> ? data : map;
        final items = envelope['items'] as List<dynamic>? ?? const [];
        final tasks = [
          for (final item in items)
            if (item is Map<String, dynamic>) GrowthTask.fromJson(item),
        ];
        if (map.containsKey('code')) {
          return ResultModel(
            code: (map['code'] as num?)?.toInt() ?? 0,
            message: map['message']?.toString() ?? '',
            data: tasks,
          );
        }
        return ResultModel(code: 0, message: 'success', data: tasks);
      },
    );
    return _data(result.data, '加载成长任务失败');
  }

  Future<ClaimTaskResult> claimTask(String code) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<ClaimTaskResult>>(
      '$tasksPath/$code/claim',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        ClaimTaskResult.fromJson,
      ),
    );
    return _data(result.data, '领取失败');
  }

  /// 拉取商城货架并过滤 `price_points > 0`；字段缺失时返回空列表。
  Future<List<PointsGiftItem>> fetchPointsGifts({
    int storeId = 1,
    int page = 1,
    int size = 20,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.get<ResultModel<ListData<PointsGiftItem>>>(
        '/api/v1/mall/stores/$storeId/products',
        queryParameters: {'page': page, 'size': size},
        converter: (json) => ResultModel.listPage(
          json as Map<String, dynamic>,
          PointsGiftItem.fromJson,
        ),
      );
      final pageData = result.data?.data;
      if (pageData == null) return const [];
      return [
        for (final item in pageData.list)
          if (item.pricePoints > 0) item,
      ];
    } catch (_) {
      return const [];
    }
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
}
