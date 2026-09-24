import 'package:get/get.dart';
import 'package:module_home/home/controller/analytics_detail_controller.dart';
import 'package:module_home/home/controller/analytics_list_controller.dart';
import 'package:module_home/home/repository/analytics_repository.dart';
import 'package:module_http/module_http.dart';

void _ensureAnalyticsDeps() {
  if (!Get.isRegistered<AnalyticsGrpcApi>()) {
    Get.lazyPut(AnalyticsGrpcApi.new, fenix: true);
  }
  if (!Get.isRegistered<AnalyticsRepository>()) {
    Get.lazyPut(
      () => AnalyticsRepository(api: Get.find<AnalyticsGrpcApi>()),
      fenix: true,
    );
  }
}

class AnalyticsListBinding extends Bindings {
  @override
  void dependencies() {
    _ensureAnalyticsDeps();
    Get.lazyPut<AnalyticsListController>(AnalyticsListController.new, fenix: true);
  }
}

class AnalyticsDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureAnalyticsDeps();
    Get.lazyPut<AnalyticsDetailController>(AnalyticsDetailController.new);
  }
}
