import 'dart:async';

/// 防抖 / 节流。
abstract final class WysDebounce {
  WysDebounce._();

  static Timer? _debounceTimer;

  /// 防抖：连续触发只执行最后一次。
  static void debounce(
    Duration delay,
    void Function() action, {
    void Function()? onCancel,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  static Timer? _throttleTimer;
  static bool _throttleLocked = false;

  /// 节流：间隔内最多执行一次。
  static void throttle(Duration interval, void Function() action) {
    if (_throttleLocked) return;
    _throttleLocked = true;
    action();
    _throttleTimer?.cancel();
    _throttleTimer = Timer(interval, () {
      _throttleLocked = false;
    });
  }
}