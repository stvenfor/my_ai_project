import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:module_utils/config/module_utils_config.dart';
import 'package:module_utils/utils/log_utils.dart';
import 'package:module_utils/utils/screen_util_utils.dart';
import 'package:module_utils/utils/sp_utils.dart';

/// 工具模块统一初始化入口，需在 App / 模块独立运行启动最早阶段调用。
class ModuleUtilsInitializer {
  ModuleUtilsInitializer._();

  static bool _initialized = false;
  static ModuleUtilsConfig _config = const ModuleUtilsConfig();

  static bool get isInitialized => _initialized;

  static ModuleUtilsConfig get config => _config;

  /// 注册并初始化无 BuildContext 依赖的工具（日志、SP 等）。
  static Future<void> initialize({
    ModuleUtilsConfig config = const ModuleUtilsConfig(),
  }) async {
    if (_initialized) return;

    _ensureWidgetsBinding();
    _config = config;

    await SpUtils.init();
    LogUtils.setup(
      level: config.resolvedLogLevel,
      enableColors: !kIsWeb,
      tag: config.logTag,
    );

    _initialized = true;
    LogUtils.i('[ModuleUtils] 工具模块初始化完成');
  }

  /// 在 MaterialApp / GetMaterialApp.builder 中包裹 ScreenUtil。
  static Widget wrapApp({
    required Widget Function(BuildContext context, Widget? child) builder,
    ModuleUtilsConfig? config,
  }) {
    _ensureInitialized();
    final effective = config ?? _config;
    return ScreenUtilUtils.init(
      designSize: effective.designSize,
      minTextAdapt: effective.minTextAdapt,
      splitScreenMode: effective.splitScreenMode,
      builder: builder,
    );
  }

  /// 快捷包裹单个子组件。
  static Widget wrapChild(Widget? child) {
    return wrapApp(builder: (_, __) => child ?? const SizedBox.shrink());
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'ModuleUtilsInitializer 未初始化，请在 main() 中先调用 initialize()',
      );
    }
  }

  static void _ensureWidgetsBinding() {
    try {
      WidgetsBinding.instance;
    } catch (_) {
      WidgetsFlutterBinding.ensureInitialized();
    }
  }
}
