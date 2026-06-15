import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:module_core/core.dart';
import 'package:module_common_ui/kit/ui_kit_config.dart';

/// [AppLoading] 的 EasyLoading 实现（唯一依赖 flutter_easyloading 的文件）。
class EasyLoadingAppLoading extends AppLoading {
  @override
  void show([String? message]) {
    EasyLoading.show(status: message);
  }

  @override
  void dismiss() {
    EasyLoading.dismiss();
  }

  @override
  void showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }

  @override
  void showError(String message) {
    EasyLoading.showError(message);
  }

  @override
  void showInfo(String message) {
    EasyLoading.showInfo(message);
  }

  @override
  void showToast(String message) {
    EasyLoading.showToast(message);
  }

  @override
  Future<T> run<T>(
    Future<T> Function() task, {
    String? message,
  }) async {
    show(message);
    try {
      return await task();
    } finally {
      dismiss();
    }
  }
}

void applyEasyLoadingConfig([UiKitConfig config = const UiKitConfig()]) {
  EasyLoading.instance
    ..displayDuration = config.displayDuration
    ..indicatorType = config.indicatorType
    ..loadingStyle = config.loadingStyle
    ..indicatorSize = config.indicatorSize
    ..radius = config.radius
    ..userInteractions = config.userInteractions
    ..dismissOnTap = config.dismissOnTap;

  if (config.progressColor != null) {
    EasyLoading.instance.progressColor = config.progressColor!;
  }
  if (config.backgroundColor != null) {
    EasyLoading.instance.backgroundColor = config.backgroundColor!;
  }
  if (config.indicatorColor != null) {
    EasyLoading.instance.indicatorColor = config.indicatorColor!;
  }
  if (config.textColor != null) {
    EasyLoading.instance.textColor = config.textColor!;
  }
  if (config.maskColor != null) {
    EasyLoading.instance.maskColor = config.maskColor!;
  }
}
