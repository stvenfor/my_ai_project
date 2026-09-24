import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_home/after_sales/model/after_sales_models.dart';

/// 售后专区 SessionAuth API。
class AfterSalesApi {
  static const _base = '/api/v1/after-sales';

  Future<AfterSalesListResult> fetchRecords({
    required int page,
    int size = 10,
  }) {
    return _guarded(() async {
      final result =
          await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
        '$_base/records',
        queryParameters: {'page': page, 'size': size},
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => Map<String, dynamic>.from(data as Map),
        ),
      );
      final data = _data(result.data, '加载列表失败');
      final rawList = (data['list'] as List?) ?? const [];
      final list = rawList
          .whereType<Map>()
          .map((e) => AfterSalesRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>?;
      final total = _asInt(pagination?['total']) ?? list.length;
      final canCreate = data['can_create'] == true;
      return AfterSalesListResult(
        list: list,
        hasMore: page * size < total,
        canCreate: canCreate,
      );
    });
  }

  Future<AfterSalesRecord> fetchDetail(int recordId) {
    return _guarded(() async {
      final result =
          await HttpManager.instance.get<ResultModel<AfterSalesRecord>>(
        '$_base/records/$recordId',
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => AfterSalesRecord.fromJson(data as Map<String, dynamic>),
        ),
      );
      return _data(result.data, '加载详情失败');
    });
  }

  Future<AfterSalesRecord> create({
    required String serviceKind,
    required String title,
    required String serviceDate,
    String? customerName,
    String? customerPhone,
    int? appointmentId,
    String? plateNo,
    int? mileage,
    String? content,
  }) {
    return _guarded(() async {
      final body = <String, dynamic>{
        'service_kind': serviceKind,
        'title': title,
        'service_date': serviceDate,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      };
      if (appointmentId != null) body['appointment_id'] = appointmentId;
      if (plateNo != null && plateNo.trim().isNotEmpty) {
        body['plate_no'] = plateNo.trim();
      }
      if (mileage != null) body['mileage'] = mileage;
      if (content != null && content.trim().isNotEmpty) {
        body['content'] = content.trim();
      }
      final result =
          await HttpManager.instance.post<ResultModel<AfterSalesRecord>>(
        '$_base/records',
        data: body,
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => AfterSalesRecord.fromJson(data as Map<String, dynamic>),
        ),
      );
      return _data(result.data, '新建失败');
    });
  }

  Future<List<AfterSalesAppointment>> fetchPendingAppointments() {
    return _guarded(() async {
      final result =
          await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
        '$_base/pending-appointments',
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => Map<String, dynamic>.from(data as Map),
        ),
      );
      final data = _data(result.data, '加载预约失败');
      final rawList = (data['list'] as List?) ?? const [];
      return rawList
          .whereType<Map>()
          .map(
            (e) => AfterSalesAppointment.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    });
  }

  Future<T> _guarded<T>(Future<T> Function() action) async {
    AuthHttpConfig.ensureInitialized();
    return action();
  }

  T _data<T>(ResultModel<T>? result, String fallback) {
    if (result == null || !result.isSuccess || result.data == null) {
      throw Exception(result?.message ?? fallback);
    }
    return result.data as T;
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }
}
