import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_home/home/controller/home_controller.dart';

/// Home 模块 Web Bridge 扩展 handler（见 [WebBridgeActions.moduleActions]）。
class HomeWebHandlers {
  HomeWebHandlers._();

  static void register(WebBridgeRegistry registry) {
    registry.registerModule(WebBridgeActions.refreshDashboard, (message) async {
      if (!Get.isRegistered<HomeController>()) {
        return {'ok': false, 'message': 'HomeController 未注册'};
      }
      await Get.find<HomeController>().refreshDashboard();
      return {'ok': true, 'message': '首页数据已刷新'};
    });
  }
}
