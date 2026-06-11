import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/auth_module.dart';
import 'package:module_auth/dev/mock_user_service.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_core/core.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ModuleUtilsInitializer.initialize(
    config: ModuleUtilsConfig(
      enableLog: kDebugMode,
      logTag: 'auth',
    ),
  );

  AuthController.standaloneMode = true;
  Get.put<UserService>(MockUserService(), permanent: true);

  final module = AuthModule();
  await module.onRegister(ModuleHostContext.standalone());
  module.createBinding()?.dependencies();

  final routes = module.routes();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Dev',
      initialRoute: RoutePath.login,
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

class _RouteHost extends StatelessWidget {
  const _RouteHost({required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
