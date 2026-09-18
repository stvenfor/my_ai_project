import 'package:module_home/home/model/analytics_record_model.dart';
import 'package:module_http/module_http.dart';

class AnalyticsRepository {
  AnalyticsRepository({AnalyticsGrpcApi? api})
      : _api = api ?? AnalyticsGrpcApi();

  final AnalyticsGrpcApi _api;

  Future<AnalyticsPageResult> fetchPage({
    required int page,
    int pageSize = 10,
  }) async {
    final resp = await _api.list(page: page, pageSize: pageSize);
    return AnalyticsPageResult(
      items: resp.items.map(AnalyticsRecordModel.fromProto).toList(),
      total: resp.total.toInt(),
      page: resp.page,
      pageSize: resp.pageSize,
    );
  }

  Future<AnalyticsRecordModel> fetchById(int id) async {
    final item = await _api.getById(id);
    return AnalyticsRecordModel.fromProto(item);
  }
}
