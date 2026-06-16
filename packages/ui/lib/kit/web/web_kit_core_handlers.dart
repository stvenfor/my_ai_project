import 'package:get/get.dart';
import 'package:module_common_ui/kit/ui_kit_initializer.dart';
import 'package:module_core/core.dart';

/// Core 级 Bridge handler，壳工程启动时统一注册（业务模块禁止覆盖）。
class WebKitCoreHandlers {
  WebKitCoreHandlers._();

  static void register(WebBridgeRegistry registry) {
    registry.register(WebBridgeActions.showToast, (message) async {
      final text = message.payload?['text']?.toString() ?? '';
      if (text.isEmpty) {
        return {'ok': false, 'message': 'toast 内容为空'};
      }
      UiKitInitializer.toast(text);
      return {'ok': true};
    });

    registry.register(WebBridgeActions.closeWithResult, (message) async {
      Get.back(result: message.payload);
      return {'ok': true};
    });

    registry.register(WebBridgeActions.getEnvironment, (message) async {
      if (!Get.isRegistered<EnvironmentService>()) {
        return {'ok': false, 'message': 'EnvironmentService 未注册'};
      }
      final env = Get.find<EnvironmentService>();
      return {
        'ok': true,
        'env': env.currentEnv.value.name,
        'label': env.config.label,
        'baseUrl': env.baseUrl,
      };
    });

    registry.register(WebBridgeActions.switchEnvironment, (message) async {
      if (!Get.isRegistered<EnvironmentService>()) {
        return {'ok': false, 'message': 'EnvironmentService 未注册'};
      }
      final raw = message.payload?['env']?.toString();
      if (raw == null || raw.isEmpty) {
        return {'ok': false, 'message': '缺少 payload.env'};
      }
      final target = AppEnv.fromKey(raw);
      await Get.find<EnvironmentService>().setEnv(target);
      return {
        'ok': true,
        'env': target.name,
        'label': target.label,
      };
    });

    registry.register(WebBridgeActions.getUserInfo, (message) async {
      if (!Get.isRegistered<UserService>()) {
        return {'ok': false, 'message': 'UserService 未注册'};
      }
      final user = Get.find<UserService>().currentUser.value;
      if (user == null) {
        return {'ok': true, 'loggedIn': false};
      }
      return {
        'ok': true,
        'loggedIn': true,
        'userId': user.id,
        'name': user.name,
        'avatar': user.avatar,
      };
    });
  }
}
