import 'package:get/get.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:module_home/home/repository/used_car_order_repository.dart';

class UsedCarDetailController extends GetxController {
  UsedCarDetailController({UsedCarOrderRepository? repository})
      : _repository = repository ?? Get.find<UsedCarOrderRepository>();

  final UsedCarOrderRepository _repository;

  final order = Rxn<UsedCarOrderItem>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    orderId = args is String
        ? args
        : args is int
            ? '$args'
            : '';
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (orderId.isEmpty) {
      errorMessage.value = '无效的业务单 ID';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      order.value = await _repository.fetchById(orderId);
    } catch (error) {
      errorMessage.value = formatUsedCarLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }
}
