import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_home/home/model/home_todo_models.dart';
import 'package:module_http/module_http.dart';

/// 首页待办 SessionAuth API。
class HomeTodoApi {
  static const todoCardsPath = '/api/v1/home/todo-cards';
  static const joinApplicationsPath = '/api/v1/home/join-applications';
  static const followUpPath = '/api/v1/home/follow-up-customers';
  static const appointmentsPath = '/api/v1/home/after-sales-appointments';
  static const reviewOrdersPath = '/api/v1/home/store-review-orders';

  Future<List<HomeTodoCard>> fetchTodoCards() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<List<HomeTodoCard>>>(
      todoCardsPath,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => _parseItems(data, HomeTodoCard.fromJson),
      ),
    );
    return _data(result.data, '加载待办卡失败');
  }

  Future<List<HomeTodoJoinApplication>> fetchJoinApplications() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance
        .get<ResultModel<List<HomeTodoJoinApplication>>>(
      joinApplicationsPath,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => _parseItems(data, HomeTodoJoinApplication.fromJson),
      ),
    );
    return _data(result.data, '加载入店申请失败');
  }

  Future<void> approveJoin(int applicationId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<Object?>>(
      '$joinApplicationsPath/$applicationId/approve',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (_) => null,
      ),
    );
    _ensureOk(result.data, '确认失败');
  }

  Future<void> rejectJoin(int applicationId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<Object?>>(
      '$joinApplicationsPath/$applicationId/reject',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (_) => null,
      ),
    );
    _ensureOk(result.data, '拒绝失败');
  }

  Future<List<Map<String, dynamic>>> fetchFollowUpCustomers() =>
      _fetchMaps(followUpPath, '加载待跟进客户失败');

  Future<List<Map<String, dynamic>>> fetchAppointments() =>
      _fetchMaps(appointmentsPath, '加载售后预约失败');

  Future<List<Map<String, dynamic>>> fetchReviewOrders() =>
      _fetchMaps(reviewOrdersPath, '加载店务审核单失败');

  Future<List<Map<String, dynamic>>> _fetchMaps(String path, String err) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<List<Map<String, dynamic>>>>(
      path,
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => _parseItems(data, (m) => m),
      ),
    );
    return _data(result.data, err);
  }

  List<T> _parseItems<T>(
    dynamic data,
    T Function(Map<String, dynamic>) map,
  ) {
    if (data is Map<String, dynamic>) {
      final raw = data['items'] as List<dynamic>? ?? const [];
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) map(item),
      ];
    }
    if (data is List) {
      return [
        for (final item in data)
          if (item is Map<String, dynamic>) map(item),
      ];
    }
    return const [];
  }

  T _data<T>(ResultModel<T>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data as T;
  }

  void _ensureOk(ResultModel<Object?>? model, String fallback) {
    if (model == null || !model.isSuccess) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
  }
}
