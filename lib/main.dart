import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_core/service/environment_service_impl.dart';
import 'package:module_global_cache/module_global_cache.dart';
import 'package:module_http/module_http.dart';
import 'package:module_repository/repository/app_http_bootstrap.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/app/app_binding.dart';
import 'package:module_sample/app/app_controller.dart';
import 'package:module_sample/config/module_manifest.dart';
import 'package:module_utils/module_utils.dart';

class AppInitializer {
  static Future<void> init() async {
    await ModuleUtilsInitializer.initialize(
      config: ModuleUtilsConfig(
        enableLog: kDebugMode,
        logTag: 'module_sample',
      ),
    );

    await SpManager.init();
    await AppDatabase.init();

    await AuthSession.register();

    await UiKitInitializer.initialize();

    await Get.putAsync<EnvironmentService>(
      EnvironmentServiceImpl.create,
      permanent: true,
    );
    _wireEnvironmentHttpRefresh();

    ModuleRegistry.registerAll(buildEnabledModules());

    final hostContext = ModuleHostContext.integrated(
      enableHttpLog: kDebugMode,
      httpMaxRetries: 3,
    );
    await ModuleRegistry.bootstrap(hostContext);

    if (!HttpManager.instance.isInitialized) {
      AppHttpBootstrap.initialize(
        enableLog: hostContext.enableHttpLog,
        maxRetries: hostContext.httpMaxRetries,
      );
    }

    AppBinding().dependencies();
    for (final binding in ModuleRegistry.collectBindings()) {
      binding.dependencies();
    }
    await Get.find<AppController>().loadSettings();

    LogUtils.i(
      '[App] 应用初始化完成 env=${Get.find<EnvironmentService>().config.label}',
    );
  }

  static void _wireEnvironmentHttpRefresh() {
    Get.find<EnvironmentService>().onEnvChanged = (_) async {
      AppHttpBootstrap.reinitialize(
        enableLog: kDebugMode,
        maxRetries: 3,
      );
    };
  }
}

Future<void> main() async {
  await AppInitializer.init();
  runApp(const App());
}
