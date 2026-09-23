import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';

/// 新车跟进档案 SessionAuth API。
class NewCarFollowApi {
  static const _base = '/api/v1/new-car-follow-files';

  Future<NewCarFollowSummary> fetchSummary() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<NewCarFollowSummary>>(
      '$_base/summary',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => NewCarFollowSummary.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '加载摘要失败');
  }

  Future<({List<NewCarFollowFile> list, bool hasMore})> fetchList({
    required NewCarFollowTab tab,
    required int page,
    int size = 10,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final query = <String, dynamic>{'page': page, 'size': size};
    query.addAll(tab.query);
    final result = await HttpManager.instance
        .get<ResultModel<ListData<NewCarFollowFile>>>(
      _base,
      queryParameters: query,
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        NewCarFollowFile.fromJson,
      ),
    );
    final listData = _data(result.data, '加载列表失败');
    final total = listData.pagination?.total ?? listData.list.length;
    final hasMore = page * size < total;
    return (list: listData.list, hasMore: hasMore);
  }

  Future<NewCarFollowFile> fetchDetail(String fileId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<NewCarFollowFile>>(
      '$_base/$fileId',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => NewCarFollowFile.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '加载详情失败');
  }

  Future<NewCarFollowFile> create({
    required String followLevel,
    int? customerId,
    String? displayName,
    String? phone,
    String? vehicleInterest,
    String? nextFollowUpAt,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final body = <String, dynamic>{'follow_level': followLevel};
    if (customerId != null && customerId > 0) {
      body['customer_id'] = customerId;
    } else {
      body['display_name'] = displayName;
      body['phone'] = phone;
    }
    if (vehicleInterest != null && vehicleInterest.trim().isNotEmpty) {
      body['vehicle_interest'] = vehicleInterest.trim();
    }
    if (nextFollowUpAt != null && nextFollowUpAt.isNotEmpty) {
      body['next_follow_up_at'] = nextFollowUpAt;
    }
    final result = await HttpManager.instance.post<ResultModel<NewCarFollowFile>>(
      _base,
      data: body,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => NewCarFollowFile.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '建档失败');
  }

  Future<NewCarFollowFile> patch({
    required String fileId,
    String? followLevel,
    String? stage,
    String? nextFollowUpAt,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final body = <String, dynamic>{};
    if (followLevel != null) body['follow_level'] = followLevel;
    if (stage != null) body['stage'] = stage;
    if (nextFollowUpAt != null) body['next_follow_up_at'] = nextFollowUpAt;
    final result = await HttpManager.instance.patch<ResultModel<NewCarFollowFile>>(
      '$_base/$fileId',
      data: body,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => NewCarFollowFile.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '更新失败');
  }

  Future<({List<NewCarFollowLog> list, bool hasMore})> fetchLogs({
    required String fileId,
    int page = 1,
    int size = 20,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance
        .get<ResultModel<ListData<NewCarFollowLog>>>(
      '$_base/$fileId/logs',
      queryParameters: {'page': page, 'size': size},
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        NewCarFollowLog.fromJson,
      ),
    );
    final listData = _data(result.data, '加载流水失败');
    final total = listData.pagination?.total ?? listData.list.length;
    final hasMore = page * size < total;
    return (list: listData.list, hasMore: hasMore);
  }

  Future<NewCarFollowLog> createLog({
    required String fileId,
    required String body,
    String? followLevel,
    String? nextFollowUpAt,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final data = <String, dynamic>{'body': body};
    if (followLevel != null && followLevel.isNotEmpty) {
      data['follow_level'] = followLevel;
    }
    if (nextFollowUpAt != null) {
      data['next_follow_up_at'] = nextFollowUpAt;
    }
    final result = await HttpManager.instance.post<ResultModel<NewCarFollowLog>>(
      '$_base/$fileId/logs',
      data: data,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => NewCarFollowLog.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '写流水失败');
  }

  T _data<T>(ResultModel<T>? result, String fallback) {
    if (result == null || !result.isSuccess || result.data == null) {
      throw Exception(result?.message ?? fallback);
    }
    return result.data as T;
  }
}
