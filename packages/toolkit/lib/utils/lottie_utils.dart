import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie 动画工具。
class LottieUtils {
  LottieUtils._();

  /// 加载 assets Lottie。
  static Widget asset(
    String assetName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
    AnimationController? controller,
    String? package,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return Lottie.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
      controller: controller,
      package: package,
      errorBuilder: errorBuilder,
    );
  }

  /// 加载网络 Lottie。
  static Widget network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
    AnimationController? controller,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return Lottie.network(
      url,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
      controller: controller,
      errorBuilder: errorBuilder,
    );
  }

  /// 加载本地文件 Lottie。
  static Widget file(
    String filePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
    AnimationController? controller,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return Lottie.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
      controller: controller,
      errorBuilder: errorBuilder,
    );
  }
}
