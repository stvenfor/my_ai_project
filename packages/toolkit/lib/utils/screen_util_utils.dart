import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ScreenUtil 屏幕适配工具。
class ScreenUtilUtils {
  ScreenUtilUtils._();

  static const Size defaultDesignSize = Size(375, 812);

  /// 初始化 ScreenUtil 并包裹子树。
  static Widget init({
    required Widget Function(BuildContext context, Widget? child) builder,
    Size designSize = defaultDesignSize,
    bool minTextAdapt = true,
    bool splitScreenMode = true,
  }) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      builder: builder,
    );
  }

  /// 当前屏幕宽度（适配后）。
  static double screenWidth() => 1.sw;

  /// 当前屏幕高度（适配后）。
  static double screenHeight() => 1.sh;

  /// 状态栏高度。
  static double statusBarHeight() => ScreenUtil().statusBarHeight;

  /// 底部安全区高度。
  static double bottomBarHeight() => ScreenUtil().bottomBarHeight;
}

/// 适配扩展：100.w / 50.h / 14.sp / 8.r
extension ScreenUtilNumX on num {
  double get w => ScreenUtil().setWidth(toDouble());

  double get h => ScreenUtil().setHeight(toDouble());

  double get sp => ScreenUtil().setSp(toDouble());

  double get r => ScreenUtil().radius(toDouble());
}
