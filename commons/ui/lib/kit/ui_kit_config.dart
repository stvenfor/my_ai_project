import 'package:flutter/material.dart';

/// BotToast / AppLoading 全局样式配置。
class UiKitConfig {
  const UiKitConfig({
    this.displayDuration = const Duration(milliseconds: 2000),
    this.indicatorSize = 40.0,
    this.radius = 10.0,
    this.loadingBackgroundColor = const Color(0xCC000000),
    this.toastBackgroundColor = const Color(0xCC000000),
    this.indicatorColor = Colors.white,
    this.textColor = Colors.white,
    this.maskColor,
    this.userInteractions = false,
    this.dismissOnTap = false,
  });

  final Duration displayDuration;
  final double indicatorSize;
  final double radius;
  final Color loadingBackgroundColor;
  final Color toastBackgroundColor;
  final Color indicatorColor;
  final Color textColor;
  final Color? maskColor;
  final bool userInteractions;
  final bool dismissOnTap;
}
