import 'package:module_home/home/api/used_car_order_api.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_http/module_http.dart';

class UsedCarOrderRepository {
  UsedCarOrderRepository({UsedCarOrderApi? api}) : _api = api ?? UsedCarOrderApi();

  final UsedCarOrderApi _api;

  static const pageSize = 10;

  Future<UsedCarOrderSummary> fetchSummary() => _api.fetchSummary();

  Future<PageResult<UsedCarOrderItem>> fetchPage({
    required UsedCarStatusTab statusTab,
    required UsedCarKindFilter kindFilter,
    required int page,
  }) async {
    final result = await _api.fetchList(
      statusTab: statusTab,
      kindFilter: kindFilter,
      page: page,
      size: pageSize,
    );
    return PageResult(list: result.list, hasMore: result.hasMore);
  }

  Future<UsedCarOrderItem> fetchById(String orderId) => _api.fetchDetail(orderId);

  Future<List<UsedCarCustomer>> fetchCustomers({String? q}) =>
      _api.fetchCustomers(q: q);

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
    return _api.create(
      kind: kind,
      customerId: customerId,
      vehicleModel: vehicleModel,
      plateNo: plateNo,
      vin: vin,
      mileageKm: mileageKm,
      modelYear: modelYear,
      amount: amount,
      imageUrl: imageUrl,
    );
  }
}

String formatUsedCarLoadError(Object error) => formatTransactionLoadError(error);
