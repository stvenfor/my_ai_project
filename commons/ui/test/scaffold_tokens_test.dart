import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_common_ui/layout/app_nav_bar.dart';
import 'package:module_common_ui/layout/app_page_scaffold.dart';
import 'package:module_common_ui/theme/app_theme.dart';
import 'package:module_common_ui/theme/vercel_tokens.dart';
import 'package:module_common_ui/widgets/ios_tab_bar.dart';

/// Legacy iOS system blue — must not appear in shared chrome defaults.
const _legacyIosBlue = Color(0xFF007AFF);

Widget _wrap({required ThemeData theme, required Widget child}) {
  return MaterialApp(
    theme: theme,
    home: child,
  );
}

void main() {
  group('Shared scaffolds (secondary seam)', () {
    testWidgets('AppPageScaffold background resolves from VercelTokens (light)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.light,
          child: const AppPageScaffold(body: SizedBox.shrink()),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, VercelTokens.light.canvasSoft2);
      expect(scaffold.backgroundColor, isNot(_legacyIosBlue));
    });

    testWidgets('AppPageScaffold background resolves from VercelTokens (dark)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.dark,
          child: const AppPageScaffold(body: SizedBox.shrink()),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, VercelTokens.dark.canvas);
      expect(scaffold.backgroundColor, isNot(_legacyIosBlue));
    });

    testWidgets('AppNavBar solid uses token canvas / ink / hairline',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.light,
          child: const Scaffold(
            body: AppNavBar(title: 'Settings'),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.color, VercelTokens.light.canvas);
      expect(material.color, isNot(_legacyIosBlue));

      final title = tester.widget<Text>(find.text('Settings'));
      expect(title.style?.color, VercelTokens.light.ink);

      final decoration = tester
          .widget<DecoratedBox>(
            find.descendant(
              of: find.byType(AppNavBar),
              matching: find.byType(DecoratedBox),
            ),
          )
          .decoration as BoxDecoration;
      expect(
        (decoration.border as Border).bottom.color,
        VercelTokens.light.hairline,
      );
    });

    testWidgets('IosTabBar selected color is token link, not legacy iOS blue',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.light,
          child: Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: IosTabBar(
              selectedIndex: 0,
              onTap: (_) {},
              items: const [
                IosTabBarItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                ),
                IosTabBarItem(
                  label: 'Mine',
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                ),
              ],
            ),
          ),
        ),
      );

      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, VercelTokens.light.link);
      expect(homeLabel.style?.color, isNot(_legacyIosBlue));

      final mineLabel = tester.widget<Text>(find.text('Mine'));
      expect(mineLabel.style?.color, VercelTokens.light.mute);
    });

    testWidgets('IosTabBar dark mode uses dark token tabBarBackground',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.dark,
          child: Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: IosTabBar(
              selectedIndex: 0,
              onTap: (_) {},
              items: const [
                IosTabBarItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                ),
              ],
            ),
          ),
        ),
      );

      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(IosTabBar),
          matching: find.byType(DecoratedBox),
        ),
      );
      final tabBg = decorated
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .firstWhere((c) => c == VercelTokens.dark.tabBarBackground);
      expect(tabBg, VercelTokens.dark.tabBarBackground);

      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, VercelTokens.dark.link);
      expect(homeLabel.style?.color, isNot(_legacyIosBlue));
    });

    testWidgets('Theme filled/outlined buttons and inputs use Token API',
        (tester) async {
      late ColorScheme scheme;
      await tester.pumpWidget(
        _wrap(
          theme: AppTheme.light,
          child: Builder(
            builder: (context) {
              scheme = Theme.of(context).colorScheme;
              return Scaffold(
                body: Column(
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('Go')),
                    OutlinedButton(onPressed: () {}, child: const Text('More')),
                    const TextField(
                      decoration: InputDecoration(hintText: 'Email'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(scheme.primary, VercelTokens.light.primary);
      expect(scheme.primary, isNot(_legacyIosBlue));
      expect(scheme.secondary, VercelTokens.light.link);
      expect(scheme.secondary, isNot(_legacyIosBlue));

      final theme = AppTheme.light;
      expect(
        theme.filledButtonTheme.style?.backgroundColor?.resolve({}),
        VercelTokens.light.primary,
      );
      final focused =
          theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, VercelTokens.light.link);
      expect(focused.borderSide.color, isNot(_legacyIosBlue));
    });
  });
}
