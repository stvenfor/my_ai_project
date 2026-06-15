/// 模块独立运行配置。
import 'package:flutter/widgets.dart';
import 'package:module_core/env/app_env.dart';

class ModuleStandaloneConfig {
  const ModuleStandaloneConfig({
    this.enableHttpLog = true,
    this.httpMaxRetries = 1,
    this.injectMockUser = false,
    this.injectDefaultEnvironment = false,
    this.initialRoute,
    this.resolveInitialRoute,
    this.onSetup,
    this.onEnvironmentChanged,
    this.innerAppBuilder,
  });

  final bool enableHttpLog;
  final int httpMaxRetries;
  final bool injectMockUser;
  final bool injectDefaultEnvironment;

  /// 固定初始路由；若 [resolveInitialRoute] 有返回值则优先使用。
  final String? initialRoute;

  /// 在 [FeatureModule.onRegister] 之后解析初始路由（如根据登录态跳转）。
  final String? Function()? resolveInitialRoute;

  /// 注册 MockUserService、AuthController.standaloneMode 等模块特有初始化。
  final Future<void> Function()? onSetup;

  /// 环境切换后重建 HTTP（独立运行时在 main_dev 中传入 AppHttpBootstrap.reinitialize）。
  final Future<void> Function(AppEnv env)? onEnvironmentChanged;

  /// 在 ScreenUtil 之内追加一层 App builder（如 EasyLoading.init）。
  final Widget Function(BuildContext context, Widget? child)? innerAppBuilder;
}
