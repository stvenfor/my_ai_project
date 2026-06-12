import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_sample/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_sample/app/app_controller.dart';
import 'package:module_sample/app/app_pages.dart';
import 'package:module_utils/module_utils.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Obx(
      () {
        final brightness = controller.themeMode == ThemeMode.dark
            ? Brightness.dark
            : controller.themeMode == ThemeMode.light
                ? Brightness.light
                : WidgetsBinding.instance.platformDispatcher.platformBrightness;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: ImmersiveHelper.overlayStyle(
            brightness: brightness,
            immersive: controller.immersiveMode,
          ),
          child: GetMaterialApp(
            title: 'Flutter Module Sample',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: controller.themeMode,
            locale: controller.locale,
            fallbackLocale: const Locale('zh'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            initialRoute: RoutePath.splash,
            getPages: AppPages.routes(),
            builder: UiKitInitializer.appBuilder(
              inner: (context, child) => ModuleUtilsInitializer.wrapApp(
                builder: (_, __) => child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
