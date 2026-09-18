import 'package:get/get.dart';
import 'package:module_home/home/model/analytics_record_model.dart';
import 'package:module_home/home/repository/analytics_repository.dart';

class AnalyticsDetailController extends GetxController {
  AnalyticsDetailController({AnalyticsRepository? repository})
      : _repository = repository ?? Get.find<AnalyticsRepository>();

  final AnalyticsRepository _repository;

  final record = Rxn<AnalyticsRecordModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final int recordId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      recordId = args;
    } else if (args is String) {
      recordId = int.tryParse(args) ?? 0;
    } else {
      recordId = 0;
    }
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (recordId <= 0) {
      errorMessage.value = '无效的记录 ID';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      record.value = await _repository.fetchById(recordId);
    } catch (error) {
      errorMessage.value = formatAnalyticsLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }
}
