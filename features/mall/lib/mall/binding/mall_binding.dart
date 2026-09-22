import 'package:get/get.dart';
import 'package:module_mall/mall/controller/mall_controller.dart';

class MallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MallController>(MallController.new);
  }
}
