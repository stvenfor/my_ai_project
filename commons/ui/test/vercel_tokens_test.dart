import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
