import 'dart:async';

/// 防抖 / 节流工具。
///
/// - [debounce]：连续触发只执行最后一次（适合搜索输入）。
/// - [throttle]：间隔内最多执行一次，首次立即执行（适合登录等主按钮）。
///
/// 均按 [key] 隔离，避免不同按钮互相抢锁。默认间隔见 [defaultClickInterval]。
class AppDebounce {
  AppDebounce._();

  /// 主按钮防重复点击的默认间隔（可按场景覆盖）。
  static const Duration defaultClickInterval = Duration(seconds: 5);

  static final Map<String, Timer> _debounceTimers = <String, Timer>{};
  static final Map<String, Timer> _throttleTimers = <String, Timer>{};
  static final Set<String> _throttleLocked = <String>{};

  /// 防抖：在 [delay] 内反复调用时，只执行最后一次 [action]。
  static void debounce(
    String key,
    void Function() action, {
    Duration delay = defaultClickInterval,
  }) {
    _debounceTimers.remove(key)?.cancel();
    _debounceTimers[key] = Timer(delay, () {
      _debounceTimers.remove(key);
      action();
    });
  }

  /// 取消指定 key 的防抖计时（未触发则不执行）。
  static void cancelDebounce(String key) {
    _debounceTimers.remove(key)?.cancel();
  }

  /// 节流：若 [key] 未锁定则立即执行 [action]，并在 [interval] 内忽略后续调用。
  ///
  /// 返回是否真正执行了 [action]。
  static bool throttle(
    String key,
    void Function() action, {
    Duration interval = defaultClickInterval,
  }) {
    if (!tryThrottle(key, interval: interval)) {
      return false;
    }
    action();
    return true;
  }

  /// 仅获取节流锁，不执行业务。成功返回 `true`。
  ///
  /// 适合 async：校验通过后再 [tryThrottle]；校验失败可 [releaseThrottle] 立刻放开。
  static bool tryThrottle(
    String key, {
    Duration interval = defaultClickInterval,
  }) {
    if (_throttleLocked.contains(key)) {
      return false;
    }
    _throttleLocked.add(key);
    _throttleTimers.remove(key)?.cancel();
    _throttleTimers[key] = Timer(interval, () {
      _throttleTimers.remove(key);
      _throttleLocked.remove(key);
    });
    return true;
  }

  /// 提前释放节流锁（例如校验失败希望立刻允许再点）。
  static void releaseThrottle(String key) {
    _throttleTimers.remove(key)?.cancel();
    _throttleLocked.remove(key);
  }

  /// 当前 [key] 是否处于节流锁定中。
  static bool isThrottled(String key) => _throttleLocked.contains(key);

  /// 包装同步回调：点击后按 [interval] 节流。
  static void Function() wrapThrottle(
    String key,
    void Function() action, {
    Duration interval = defaultClickInterval,
  }) {
    return () {
      throttle(key, action, interval: interval);
    };
  }

  /// 包装异步回调：节流通过后执行；若 [releaseOnError] 且抛错则立刻解锁。
  static Future<void> Function() wrapThrottleAsync(
    String key,
    Future<void> Function() action, {
    Duration interval = defaultClickInterval,
    bool releaseOnError = false,
  }) {
    return () async {
      if (!tryThrottle(key, interval: interval)) {
        return;
      }
      try {
        await action();
      } catch (_) {
        if (releaseOnError) {
          releaseThrottle(key);
        }
        rethrow;
      }
    };
  }

  /// 测试或页面销毁时清理全部计时器。
  static void clearAll() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _throttleTimers.clear();
    _throttleLocked.clear();
  }
}
