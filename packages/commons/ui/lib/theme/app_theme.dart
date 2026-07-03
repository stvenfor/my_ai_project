import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF53D65B);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF7F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFEEF5F4),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2B2D31),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: seedColor.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? seedColor : const Color(0xFF8E9197),
            );
          }),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E2126),
        ),
        scaffoldBackgroundColor: const Color(0xFF14171C),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF1E2126),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: const Color(0xFF1E2126),
          indicatorColor: seedColor.withValues(alpha: 0.24),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? seedColor : const Color(0xFF9EA2A8),
            );
          }),
        ),
      );
}

class ImmersiveHelper {
  static SystemUiOverlayStyle overlayStyle({
    required Brightness brightness,
    bool immersive = true,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    if (!immersive) {
      return base.copyWith(
        statusBarColor: isDark ? const Color(0xFF1E2126) : Colors.white,
        systemNavigationBarColor: isDark ? const Color(0xFF1E2126) : Colors.white,
      );
    }
    return base.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  static Future<void> apply({
    required Brightness brightness,
    bool immersive = true,
  }) async {
    await SystemChrome.setEnabledSystemUIMode(
      immersive
          ? SystemUiMode.edgeToEdge
          : SystemUiMode.manual,
      overlays: immersive ? null : SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      overlayStyle(brightness: brightness, immersive: immersive),
    );
  }
}
