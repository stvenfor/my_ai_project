import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// Web 公共能力入口：注册 [WebBridgeRegistry]。
class WebKitInitializer {
  WebKitInitializer._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static WebBridgeRegistry get registry {
    if (!Get.isRegistered<WebBridgeRegistry>()) {
      throw StateError(
        'WebBridgeRegistry 未注册，请在 main() 中先调用 WebKitInitializer.initialize()',
      );
    }
    return Get.find<WebBridgeRegistry>();
  }

  /// 注册全局 Bridge 注册表（幂等）。
  static Future<WebBridgeRegistry> initialize({bool permanent = true}) async {
    if (Get.isRegistered<WebBridgeRegistry>()) {
      _initialized = true;
      return Get.find<WebBridgeRegistry>();
    }
    final registry = WebBridgeRegistry();
    Get.put<WebBridgeRegistry>(registry, permanent: permanent);
    _initialized = true;
    return registry;
  }
}
