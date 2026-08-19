import 'package:module_auth/auth_module.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_route/module/module_standalone_runner.dart';
import 'package:module_route/route/route_path.dart';

Future<void> main() => ModuleStandaloneRunner.run(
      AuthModule(),
      config: ModuleStandaloneConfig(
        initialRoute: RoutePath.login,
        resolveInitialRoute: () =>
            AuthSession.isLoggedIn ? RoutePath.authDevHome : RoutePath.login,
        onSetup: () async {
          await UiKitInitializer.initialize();
        },
        innerAppBuilder: UiKitInitializer.wrapChild,
        navigatorObservers: UiKitInitializer.navigatorObservers,
      ),
    );
