import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color accent = Color(0xFF007AFF);
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color labelSecondary = Color(0x993C3C43);
  static const Color tabBarBackground = Color(0xF2FFFFFF);

  /// 兼容旧引用
  static const Color seedColor = accent;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          primary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        cardColor: surface,
        dividerColor: separator,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: surface,
          foregroundColor: Color(0xFF000000),
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 49,
          backgroundColor: tabBarBackground,
          indicatorColor: accent.withValues(alpha: 0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22,
              color: selected ? accent : labelSecondary,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? accent : labelSecondary,
            );
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(64, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          primary: accent,
          surface: const Color(0xFF1C1C1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 49,
          backgroundColor: const Color(0xCC1C1C1E),
          indicatorColor: accent.withValues(alpha: 0.24),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? accent : const Color(0xFF8E8E93),
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

  /// 视频播放页：隐藏状态栏时间与系统图标（immersiveSticky）。
  static Future<void> applyPlayback() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// 离开播放页后恢复为应用默认 edgeToEdge 沉浸式。
  static Future<void> restoreFromPlayback({
    required Brightness brightness,
  }) async {
    await apply(brightness: brightness, immersive: true);
  }
}
