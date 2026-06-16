import 'package:flutter/material.dart';

/// 安全区与导航栏高度工具（沉浸式 edgeToEdge 下统一使用）。
class AppSafeInsets {
  AppSafeInsets._();

  static double top(BuildContext context) => MediaQuery.paddingOf(context).top;

  static double bottom(BuildContext context) => MediaQuery.paddingOf(context).bottom;

  static double keyboardBottom(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  static const toolbarHeight = kToolbarHeight;

  /// 状态栏 + 标准工具栏高度。
  static double navBarHeight(BuildContext context) =>
      top(context) + toolbarHeight;

  static EdgeInsets navBarPadding(BuildContext context) =>
      EdgeInsets.only(top: top(context));

  static EdgeInsets contentPadding(BuildContext context, {bool bottom = true}) {
    return EdgeInsets.only(
      top: top(context),
      bottom: bottom ? bottomOf(context) : 0,
    );
  }

  static double bottomOf(BuildContext context) {
    final viewBottom = keyboardBottom(context);
    if (viewBottom > 0) return viewBottom;
    return bottom(context);
  }
}
