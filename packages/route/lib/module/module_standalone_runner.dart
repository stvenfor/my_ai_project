import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_core/dev/default_environment_service.dart';
import 'package:module_core/dev/mock_user_service.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_utils/module_utils.dart';

/// 模块独立运行入口：在模块目录执行 `flutter run -t lib/main_dev.dart`
class ModuleStandaloneRunner {
  ModuleStandaloneRunner._();

  static Future<void> run(
    FeatureModule module, {
    ModuleStandaloneConfig config = const ModuleStandaloneConfig(),
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    await ModuleUtilsInitializer.initialize(
      config: ModuleUtilsConfig(
        enableLog: kDebugMode,
        logTag: module.moduleId,
      ),
    );

    if (config.injectMockUser && !Get.isRegistered<UserService>()) {
      Get.put<UserService>(MockUserService(), permanent: true);
    }

    if (config.injectDefaultEnvironment &&
        !Get.isRegistered<EnvironmentService>()) {
      final envService = DefaultEnvironmentService();
      if (config.onEnvironmentChanged != null) {
        envService.onEnvChanged = config.onEnvironmentChanged;
      }
      Get.put<EnvironmentService>(envService, permanent: true);
    }

    await config.onSetup?.call();

    final context = ModuleHostContext.standalone(
      enableHttpLog: config.enableHttpLog,
      httpMaxRetries: config.httpMaxRetries,
    );
    await module.onRegister(context);

    final binding = module.createBinding();
    binding?.dependencies();

    final tab = module.mainTab;
    final routes = module.routes();
    final initialRoute = config.resolveInitialRoute?.call() ??
        config.initialRoute ??
        (tab == null && routes.isNotEmpty ? routes.keys.first : null);

    runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: '${module.moduleId} (dev)',
        home: tab != null ? tab.pageBuilder() : null,
        initialRoute: tab == null ? initialRoute : null,
        getPages: routes.entries
            .map(
              (entry) => GetPage<dynamic>(
                name: entry.key,
                page: () => _RouteHost(builder: entry.value),
              ),
            )
            .toList(),
        builder: (context, child) {
          return ModuleUtilsInitializer.wrapApp(
            builder: (_, innerChild) {
              final content = innerChild ?? const SizedBox.shrink();
              if (config.innerAppBuilder != null) {
                return config.innerAppBuilder!(context, content);
              }
              return content;
            },
          );
        },
      ),
    );
  }
}

class _RouteHost extends StatelessWidget {
  const _RouteHost({required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
