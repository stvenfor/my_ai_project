import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/config/app_config_controller.dart';
import 'package:module_common_ui/theme/app_theme.dart';
import 'package:module_common_ui/theme/vercel_tokens.dart';
import 'package:module_common_ui/theme/vercel_typography.dart';

void main() {
  group('Vercel Token API (primary seam)', () {
    test('light tokens match DESIGN.md semantic colors', () {
      const t = VercelTokens.light;
      expect(t.ink, const Color(0xFF171717));
      expect(t.canvas, const Color(0xFFFFFFFF));
      expect(t.canvasSoft, const Color(0xFFFAFAFA));
      expect(t.canvasSoft2, const Color(0xFFF5F5F5));
      expect(t.body, const Color(0xFF4D4D4D));
      expect(t.mute, const Color(0xFF888888));
      expect(t.hairline, const Color(0xFFEBEBEB));
      expect(t.link, const Color(0xFF0070F3));
      expect(t.primary, const Color(0xFF171717));
      expect(t.error, const Color(0xFFEE0000));
    });

    test('dark tokens invert canvas/ink while keeping link role', () {
      const t = VercelTokens.dark;
      expect(t.canvas, const Color(0xFF000000));
      expect(t.ink, const Color(0xFFEDEDED));
      expect(t.link, const Color(0xFF0070F3));
      expect(t.primary, const Color(0xFFEDEDED));
    });

    test('AppTheme.light mounts VercelTokens and Mobile Type Scale', () {
      final theme = AppTheme.light;
      final tokens = theme.extension<VercelTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.ink, VercelTokens.light.ink);
      expect(theme.scaffoldBackgroundColor, VercelTokens.light.canvasSoft2);
      expect(theme.textTheme.displayLarge?.fontSize, 32);
      expect(theme.textTheme.bodyLarge?.fontSize, 16);
      expect(theme.textTheme.bodyMedium?.fontSize, 14);
      expect(theme.textTheme.bodySmall?.fontSize, 12);
      expect(theme.textTheme.displayLarge?.fontFamily, VercelTypography.fontFamily);
      expect(theme.colorScheme.primary, VercelTokens.light.primary);
    });

    test('AppTheme.dark mounts dark VercelTokens', () {
      final theme = AppTheme.dark;
      final tokens = theme.extension<VercelTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.canvas, VercelTokens.dark.canvas);
      expect(theme.scaffoldBackgroundColor, VercelTokens.dark.canvas);
      expect(theme.colorScheme.primary, VercelTokens.dark.primary);
      expect(theme.textTheme.displayLarge?.fontSize, 32);
    });

    test('legacy AppTheme color aliases resolve to Vercel light tokens', () {
      expect(AppTheme.accent, VercelTokens.light.link);
      expect(AppTheme.surface, VercelTokens.light.canvas);
      expect(AppTheme.separator, VercelTokens.light.hairline);
      expect(AppTheme.background, VercelTokens.light.canvasSoft2);
    });

    testWidgets('VercelTokens.current prefers AppConfig over Theme.of',
        (tester) async {
      final config = _FakeAppConfig(ThemeMode.dark);
      Get.put<AppConfigController>(config);

      late VercelTokens fromCurrent;
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // ThemeMode.light on purpose — config says dark; current must follow config.
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              fromCurrent = VercelTokens.current();
              expect(VercelTokens.resolve(context).canvas, VercelTokens.dark.canvas);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(fromCurrent.canvas, VercelTokens.dark.canvas);
      expect(fromCurrent.ink, VercelTokens.dark.ink);
      Get.reset();
    });

    testWidgets('VercelTokens.current follows GetMaterialApp themeMode',
        (tester) async {
      Get.reset();
      late VercelTokens darkCurrent;
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              darkCurrent = VercelTokens.current();
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(darkCurrent.canvas, VercelTokens.dark.canvas);
      expect(darkCurrent.ink, VercelTokens.dark.ink);
      expect(darkCurrent.canvasSoft2, VercelTokens.dark.canvasSoft2);
    });
  });
}

class _FakeAppConfig extends AppConfigController {
  _FakeAppConfig(ThemeMode mode) : themeModeRx = mode.obs;

  @override
  final Rx<ThemeMode> themeModeRx;

  @override
  ThemeMode get themeMode => themeModeRx.value;

  @override
  Locale get locale => const Locale('zh');

  @override
  bool get immersiveMode => true;

  @override
  Future<void> toggleTheme() async {}

  @override
  Future<void> setThemeMode(ThemeMode mode) async => themeModeRx.value = mode;

  @override
  Future<void> setLocale(Locale locale) async {}

  @override
  Future<void> toggleImmersive() async {}

  @override
  Future<void> setImmersive(bool enabled) async {}
}
