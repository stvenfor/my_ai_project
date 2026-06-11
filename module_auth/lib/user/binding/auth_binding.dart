import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(AuthController.new);
  }
}
