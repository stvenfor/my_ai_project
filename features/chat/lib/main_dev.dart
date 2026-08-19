import 'package:module_chat/chat_module.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_route/module/module_standalone_runner.dart';

Future<void> main() => ModuleStandaloneRunner.run(
      ChatModule(),
      config: ModuleStandaloneConfig(
        injectMockUser: true,
        onSetup: () async {
          await UiKitInitializer.initialize();
        },
        innerAppBuilder: UiKitInitializer.wrapChild,
        navigatorObservers: UiKitInitializer.navigatorObservers,
      ),
    );
