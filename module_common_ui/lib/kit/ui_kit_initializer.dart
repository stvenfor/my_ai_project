import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/kit/easy_loading_service.dart';
import 'package:module_common_ui/kit/ui_kit_config.dart';
import 'package:module_core/core.dart';

/// UI 公共能力入口：Loading 注册 + EasyLoading.init 包裹。
class UiKitInitializer {
  UiKitInitializer._();

  static bool _initialized = false;
  static AppLoading _loading = _NoopAppLoading();

  static bool get isInitialized => _initialized;

  /// 当前 Loading 能力（优先 GetX 注册实例）。
  static AppLoading get loading =>
      Get.isRegistered<AppLoading>() ? Get.find<AppLoading>() : _loading;

  /// 注册 [AppLoading] 并配置 EasyLoading 样式（幂等）。
  static Future<AppLoading> initialize({
    UiKitConfig config = const UiKitConfig(),
    bool permanent = true,
  }) async {
    if (Get.isRegistered<AppLoading>()) {
      _initialized = true;
      return Get.find<AppLoading>();
    }

    applyEasyLoadingConfig(config);
    final service = EasyLoadingAppLoading();
    _loading = service;
    Get.put<AppLoading>(service, permanent: permanent);
    _initialized = true;
    return service;
  }

  /// 供 GetMaterialApp.builder 使用，EasyLoading 置于最外层。
  static TransitionBuilder appBuilder({
    required TransitionBuilder inner,
  }) {
    _ensureInitialized();
    return EasyLoading.init(builder: inner);
  }

  /// 独立运行时在 [ModuleStandaloneConfig.innerAppBuilder] 中包裹子树。
  static Widget wrapChild(BuildContext context, Widget? child) {
    _ensureInitialized();
    final builder = EasyLoading.init();
    return builder(context, child) ?? const SizedBox.shrink();
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'UiKitInitializer 未初始化，请在 main() 中先调用 initialize()',
      );
    }
  }
}

class _NoopAppLoading extends AppLoading {
  @override
  void dismiss() {}

  @override
  void show([String? message]) {}

  @override
  void showError(String message) {}

  @override
  void showInfo(String message) {}

  @override
  void showSuccess(String message) {}

  @override
  void showToast(String message) {}

  @override
  Future<T> run<T>(
    Future<T> Function() task, {
    String? message,
  }) =>
      task();
}
