import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 防截屏工具 —— 公共 API
///
/// 对齐安卓 `ScreenHandlerUtil.disableScreenShot / enableScreenShot`：
/// - Debug 包跳过（安卓 `if (BuildConfig.DEBUG) return`，避免黑屏影响调试）
/// - Release 包生效，窗口级别防截屏
///
/// **OHOS 实现**（双通道，优先 SDK 内置）：
/// 1. Flutter OHOS SDK 内置 `SensitiveContentChannel`
///    （channel: `flutter/sensitivecontent`，`FlutterAbility` 自动注册）
/// 2. SDK 通道异常时兜底到项目自定义 `ScreenProtectorPlugin`
///    （channel: `com.tf.flutter/screen_protector`，直调 `setWindowPrivacyMode`，
///    在 `WysPluginRegistrant` 注册）
///
/// **Android 实现**：使用 `FLAG_SECURE`（需通过平台通道调用，当前仅 OHOS）。
///
/// 原生侧常量：
/// - `SENSITIVE_CONTENT_SENSITIVITY = 1`（开启防截屏）
/// - `NOT_SENSITIVE_CONTENT_SENSITIVITY = 2`（关闭防截屏）
///
/// ## 使用示例
///
/// ```dart
/// // 进入敏感页面时开启
/// await WysScreenProtector.enable();
///
/// // 离开时关闭
/// await WysScreenProtector.disable();
///
/// // 需要 Debug 包也生效（如真机验证防截屏效果）：
/// await WysScreenProtector.enable(skipInDebug: false);
/// ```
///
/// enable/disable 内部带引用计数：多个场景（Tab 级、预览页级）可同时开启，
/// 只有全部 disable 后才真正关闭防截屏，避免预览页退出时误关 Tab 级保护。
/// 对齐安卓 FLAG_SECURE 的叠加语义。
class WysScreenProtector {
  WysScreenProtector._();

  /// SDK 内置的敏感内容通道（优先）
  static const _sdkChannel = MethodChannel('flutter/sensitivecontent');

  /// 项目自定义兜底通道（见 ohos/entry ScreenProtectorPlugin）
  static const _fallbackChannel = MethodChannel(
    'com.tf.flutter/screen_protector',
  );

  /// SENSITIVE_CONTENT_SENSITIVITY（原生侧常量 = 1）
  static const int _sensitive = 1;

  /// NOT_SENSITIVE_CONTENT_SENSITIVITY（原生侧常量 = 2）
  static const int _notSensitive = 2;

  /// 引用计数：>0 表示当前应处于防截屏状态
  static int _refCount = 0;

  /// 开启防截屏
  ///
  /// 等价于安卓 `ScreenHandlerUtil.disableScreenShot(activity)`。
  /// [skipInDebug] 默认 true，对齐安卓 Debug 包跳过；
  /// 真机验证防截屏效果时传 false。
  static Future<bool> enable({bool skipInDebug = true}) =>
      setPrivacyMode(true, skipInDebug: skipInDebug);

  /// 关闭防截屏
  ///
  /// 等价于安卓 `ScreenHandlerUtil.enableScreenShot(activity)`。
  static Future<bool> disable({bool skipInDebug = true}) =>
      setPrivacyMode(false, skipInDebug: skipInDebug);

  /// 开启/关闭防截屏（底层通用方法，带引用计数）
  ///
  /// [enabled] 为 true 时开启防截屏，false 时关闭。
  /// 只有计数在 0 与 1 之间跨越时才真正调用原生通道。
  static Future<bool> setPrivacyMode(
    bool enabled, {
    bool skipInDebug = true,
  }) async {
    // 对齐安卓 ScreenHandlerUtil：Debug 包跳过，避免页面黑屏影响调试
    if (skipInDebug && kDebugMode) {
      debugPrint('[WysScreenProtector] debug mode, skip');
      return false;
    }
    _refCount = enabled ? _refCount + 1 : (_refCount - 1).clamp(0, 1 << 30);
    final shouldEnable = _refCount > 0;
    debugPrint(
      '[WysScreenProtector] ${enabled ? "enable" : "disable"} '
      'refCount=$_refCount shouldEnable=$shouldEnable',
    );
    return _invoke(shouldEnable);
  }

  /// 真正调用原生通道（SDK 优先，自定义插件兜底）
  static Future<bool> _invoke(bool enabled) async {
    // 1. 优先 Flutter OHOS SDK 内置 SensitiveContentPlugin
    try {
      final arg = enabled ? _sensitive : _notSensitive;
      await _sdkChannel
          .invokeMethod<dynamic>(
            'SensitiveContent.setContentSensitivity',
            arg,
          )
          .timeout(const Duration(seconds: 3));
      debugPrint('[WysScreenProtector] sdk setContentSensitivity($enabled) ok');
    } catch (e) {
      debugPrint('[WysScreenProtector] sdk channel failed: $e');
    }
    // 2. SDK 插件内部错误会被静默吞掉（返回成功但未生效），
    //    因此无论 SDK 通道结果如何，都再走自定义插件直调 setWindowPrivacyMode
    try {
      final ok = await _fallbackChannel
          .invokeMethod<bool>('setPrivacyMode', {'enabled': enabled})
          .timeout(const Duration(seconds: 3));
      debugPrint('[WysScreenProtector] fallback setPrivacyMode($enabled) = $ok');
      return ok ?? false;
    } catch (e) {
      debugPrint('[WysScreenProtector] fallback channel failed: $e');
      return false;
    }
  }
}
