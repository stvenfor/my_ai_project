import 'package:flutter/material.dart';
import 'package:module_utils/module_utils.dart';

/// 屏幕适配初始化，委托 [ModuleUtilsInitializer] 统一配置。
class AppScreenUtilInit extends StatelessWidget {
  const AppScreenUtilInit({
    super.key,
    required this.builder,
    this.designSize,
  });

  final Widget Function(BuildContext context, Widget? child) builder;
  final Size? designSize;

  @override
  Widget build(BuildContext context) {
    if (!ModuleUtilsInitializer.isInitialized) {
      return ScreenUtilUtils.init(
        designSize: designSize ?? ScreenUtilUtils.defaultDesignSize,
        builder: builder,
      );
    }
    return ModuleUtilsInitializer.wrapApp(
      config: designSize == null
          ? null
          : ModuleUtilsConfig(designSize: designSize!),
      builder: builder,
    );
  }
}
