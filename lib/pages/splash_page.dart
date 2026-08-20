import 'package:flutter/material.dart';
import 'package:module_sample/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_linking/linking_initializer.dart';
import 'package:module_linking/privacy/privacy_consent_dialog.dart';
import 'package:module_utils/module_utils.dart';
import 'package:wys_router/src/module/module_registry.dart';
import 'package:wys_router/src/route/route_path.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _busy = true;
  var _denied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeByAuth());
  }

  Future<void> _routeByAuth() async {
    setState(() {
      _busy = true;
      _denied = false;
    });
    ModuleRegistry.ensureBindings();

    LogUtils.i('[Splash] checking privacy consent');
    final granted = await PrivacyConsentDialog.showIfNeeded(context);
    if (!mounted) return;
    if (!granted) {
      LogUtils.w('[Splash] privacy denied, stay on splash');
      setState(() {
        _busy = false;
        _denied = true;
      });
      return;
    }

    LogUtils.i('[Splash] privacy granted, go main');
    Get.offNamed(RoutePath.main);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await LinkingInitializer.flushPendingNavigation();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      body: Center(
        child: _denied
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '需同意隐私政策后才能继续使用',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _routeByAuth,
                    child: const Text('重新选择'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_busy) const CircularProgressIndicator(),
                  if (_busy) const SizedBox(height: 16),
                  Text(l10n.splashLoading),
                ],
              ),
      ),
    );
  }
}
