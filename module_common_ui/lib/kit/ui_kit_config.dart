import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// EasyLoading 全局样式配置。
class UiKitConfig {
  const UiKitConfig({
    this.displayDuration = const Duration(milliseconds: 2000),
    this.indicatorType = EasyLoadingIndicatorType.fadingCircle,
    this.loadingStyle = EasyLoadingStyle.dark,
    this.indicatorSize = 40.0,
    this.radius = 10.0,
    this.progressColor,
    this.backgroundColor,
    this.indicatorColor,
    this.textColor,
    this.maskColor,
    this.userInteractions = false,
    this.dismissOnTap = false,
  });

  final Duration displayDuration;
  final EasyLoadingIndicatorType indicatorType;
  final EasyLoadingStyle loadingStyle;
  final double indicatorSize;
  final double radius;
  final Color? progressColor;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? textColor;
  final Color? maskColor;
  final bool userInteractions;
  final bool dismissOnTap;
}
