import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_utils/module_utils.dart';

/// 模块独立运行入口：flutter run -t lib/main_dev.dart
class ModuleStandaloneRunner {
  static Future<void> run(FeatureModule module) async {
    await ModuleUtilsInitializer.initialize(
      config: ModuleUtilsConfig(
        enableLog: kDebugMode,
        logTag: module.moduleId,
      ),
    );

    final context = ModuleHostContext.standalone();
    await module.onRegister(context);
    final binding = module.createBinding();
    binding?.dependencies();

    final tab = module.mainTab;
    final routes = module.routes();

    runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: module.moduleId,
        home: tab != null ? tab.pageBuilder() : null,
        initialRoute: tab == null ? routes.keys.first : null,
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
            builder: (_, __) => child ?? const SizedBox.shrink(),
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
