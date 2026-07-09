import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_global_cache/module_global_cache.dart';
import 'package:module_http/module_http.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_sample/app/app.dart';
import 'package:module_sample/app/app_binding.dart';
import 'package:module_sample/app/app_controller.dart';
import 'package:module_linking/linking_binding.dart';
import 'package:module_linking/linking_initializer.dart';
import 'package:module_realtime/realtime_initializer.dart';
import 'package:module_rongcloud_im/im_initializer.dart';
import 'package:module_sample/config/module_manifest.dart';
import 'package:module_settings/env/environment_session.dart';
import 'package:module_utils/module_utils.dart';

class AppInitializer {
  static Future<void> init() async {
    await ModuleUtilsInitializer.initialize(
      config: ModuleUtilsConfig(
        enableLog: kDebugMode,
        logTag: 'module_sample',
      ),
    );

    await VideoMockSourceLoader.load();

    await SpManager.init();
    await AppDatabase.init();

    await EnvironmentSession.register();
    _wireEnvironmentHttpRefresh();
    AppHttpBootstrap.initialize(
      headerProvider: const AuthHeaderProvider(),
      responseHook: SessionGuardHook(),
      enableLog: kDebugMode,
      maxRetries: 3,
    );

    await AuthSession.register();

    await UiKitInitializer.initialize();

    final webRegistry = await WebKitInitializer.initialize();
    WebKitCoreHandlers.register(webRegistry);

    ModuleRegistry.registerAll(buildEnabledModules());

    final hostContext = ModuleHostContext.integrated(
      enableHttpLog: kDebugMode,
      httpMaxRetries: 3,
    );
    await ModuleRegistry.bootstrap(hostContext);

    AppBinding().dependencies();
    LinkingBinding().dependencies();
    await ImInitializer.initDeferred();
    for (final binding in ModuleRegistry.collectBindings()) {
      binding.dependencies();
    }
    await Get.find<AppController>().loadSettings();

    await LinkingInitializer.initDeferred();
    await RealtimeInitializer.initDeferred();

    LogUtils.i(
      '[App] 应用初始化完成 env=${Get.find<EnvironmentService>().config.label}',
    );
  }

  static void _wireEnvironmentHttpRefresh() {
    Get.find<EnvironmentService>().onEnvChanged = (_) async {
      AppHttpBootstrap.reinitialize(
        headerProvider: const AuthHeaderProvider(),
        responseHook: SessionGuardHook(),
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
