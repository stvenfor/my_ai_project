import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_sample/app/app_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final controller = AppController();
    Get.put<AppController>(controller, permanent: true);
    Get.put<AppConfigController>(controller, permanent: true);
  }
}
