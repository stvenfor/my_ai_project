import 'package:get/get.dart';

/// 全局 Loading / Toast 抽象，业务模块只依赖此接口。
abstract class AppLoading extends GetxService {
  void show([String? message]);

  void dismiss();

  void showSuccess(String message);

  void showError(String message);

  void showInfo(String message);

  void showToast(String message);

  /// 执行任务并自动展示/关闭 Loading。
  Future<T> run<T>(
    Future<T> Function() task, {
    String? message,
  });
}
