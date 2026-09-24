import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:module_http/module_http.dart';

class UsedCarOrderApi {
  static const _base = '/api/v1/used-car-orders';

  Future<UsedCarOrderSummary> fetchSummary() {
    return _guarded(() async {
      final result =
          await HttpManager.instance.get<ResultModel<UsedCarOrderSummary>>(
        '$_base/summary',
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => UsedCarOrderSummary.fromJson(data as Map<String, dynamic>),
        ),
      );
      return _data(result.data, '加载摘要失败');
    });
  }

  Future<({List<UsedCarOrderItem> list, bool hasMore})> fetchList({
    required UsedCarStatusTab statusTab,
    required UsedCarKindFilter kindFilter,
    required int page,
    int size = 10,
  }) {
    return _guarded(() async {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
        'status': statusTab.apiStatus,
      };
      final kind = kindFilter.apiKind;
      if (kind != null) query['kind'] = kind;
      final result = await HttpManager.instance
          .get<ResultModel<ListData<UsedCarOrderItem>>>(
        _base,
        queryParameters: query,
        converter: (json) => ResultModel.listPage(
          json as Map<String, dynamic>,
          UsedCarOrderItem.fromJson,
        ),
      );
      final listData = _data(result.data, '加载列表失败');
      final total = listData.pagination?.total ?? listData.list.length;
      final hasMore = page * size < total;
      return (list: listData.list, hasMore: hasMore);
    });
  }

  Future<UsedCarOrderItem> fetchDetail(String orderId) {
    return _guarded(() async {
      final result =
          await HttpManager.instance.get<ResultModel<UsedCarOrderItem>>(
        '$_base/$orderId',
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => UsedCarOrderItem.fromJson(data as Map<String, dynamic>),
        ),
      );
      return _data(result.data, '加载详情失败');
    });
  }

  Future<List<UsedCarCustomer>> fetchCustomers({
    int page = 1,
    int size = 50,
    String? q,
  }) {
    return _guarded(() async {
      final query = <String, dynamic>{'page': page, 'size': size};
      if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();
      final result = await HttpManager.instance
          .get<ResultModel<ListData<UsedCarCustomer>>>(
        '$_base/customers',
        queryParameters: query,
        converter: (json) => ResultModel.listPage(
          json as Map<String, dynamic>,
          UsedCarCustomer.fromJson,
        ),
      );
      return _data(result.data, '加载客户失败').list;
    });
  }

  Future<UsedCarOrderItem> create({
    required String kind,
    required int customerId,
    required String vehicleModel,
    required String plateNo,
    required String vin,
    required int mileageKm,
    required int modelYear,
    required double amount,
    String? imageUrl,
  }) {
    return _guarded(() async {
      final result =
          await HttpManager.instance.post<ResultModel<UsedCarOrderItem>>(
        _base,
        data: {
          'kind': kind,
          'customer_id': customerId,
          'vehicle_model': vehicleModel,
          'plate_no': plateNo,
          'vin': vin,
          'mileage_km': mileageKm,
          'model_year': modelYear,
          'amount': amount,
          'image_url': imageUrl,
        },
        converter: (json) => ResultModel.fromJson(
          json as Map<String, dynamic>,
          (data) => UsedCarOrderItem.fromJson(data as Map<String, dynamic>),
        ),
      );
      return _data(result.data, '提交失败');
    });
  }

  Future<T> _guarded<T>(Future<T> Function() action) async {
    HomeHttpConfig.ensureInitialized();
    return action();
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
}
