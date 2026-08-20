import 'package:flutter/services.dart';

/// 震动工具类，对齐安卓 `VibrateUtils.vibrate(milliseconds)`。
///
/// Flutter 内置 [HapticFeedback] 通过平台通道触发触觉反馈，
/// OHOS 系统原生支持。安卓 `vibrate(30)` 对应 [lightImpact]。
class VibrateUtils {
  VibrateUtils._();

  /// 通用震动，对齐安卓 `VibrateUtils.vibrate(ms)`。
  /// - [milliseconds] ≤ 10 → [HapticFeedback.selectionClick]
  /// - [milliseconds] ≤ 50 → [HapticFeedback.lightImpact]
  /// - [milliseconds] ≤ 200 → [HapticFeedback.mediumImpact]
  /// - 其他 → [HapticFeedback.heavyImpact]
  static Future<void> vibrate([int milliseconds = 30]) async {
    if (milliseconds <= 10) {
      await HapticFeedback.selectionClick();
    } else if (milliseconds <= 50) {
      await HapticFeedback.lightImpact();
    } else if (milliseconds <= 200) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// 轻微震动，对齐安卓 `VibrateUtils.vibrate(30)`。
  static Future<void> light() => HapticFeedback.lightImpact();

  /// 中等震动。
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// 强烈震动。
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// 选择点击震动（极轻）。
  static Future<void> selectionClick() => HapticFeedback.selectionClick();
}
