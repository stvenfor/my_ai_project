import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home_module.dart';
import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_route/module/module_standalone_runner.dart';

Future<void> main() => ModuleStandaloneRunner.run(
      HomeModule(),
      config: ModuleStandaloneConfig(
        injectMockUser: true,
        injectDefaultEnvironment: true,
        onSetup: () async {
          await UiKitInitializer.initialize();
          final registry = await WebKitInitializer.initialize();
          WebKitCoreHandlers.register(registry);
        },
        innerAppBuilder: UiKitInitializer.wrapChild,
        navigatorObservers: UiKitInitializer.navigatorObservers,
        extraRoutes: WebKitRoutes.routes(),
      ),
    );
