import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// MVVM ViewModel 基类：统一 loading / error 状态。
abstract class BaseViewModel extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @protected
  Future<void> runAsync(Future<void> Function() task) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await task();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() => errorMessage.value = null;
}
