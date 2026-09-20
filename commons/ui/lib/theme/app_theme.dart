import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vercel_tokens.dart';
import 'vercel_typography.dart';

class AppTheme {
  /// Expand-phase aliases: map legacy iOS names onto Vercel Token API.
  /// Prefer [VercelTokens.of] for new code. Contract in ticket 14.
  static Color get accent => VercelTokens.light.link;
  static Color get background => VercelTokens.light.canvasSoft2;
  static Color get surface => VercelTokens.light.canvas;
  static Color get separator => VercelTokens.light.hairline;
  static Color get labelSecondary => VercelTokens.light.body;
  static Color get tabBarBackground => VercelTokens.light.tabBarBackground;

  /// 兼容旧引用
  static Color get seedColor => accent;

  static ThemeData get light => _build(Brightness.light, VercelTokens.light);

  static ThemeData get dark => _build(Brightness.dark, VercelTokens.dark);

  static ThemeData _build(Brightness brightness, VercelTokens tokens) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.link,
      onSecondary: tokens.onPrimary,
      error: tokens.error,
      onError: tokens.onPrimary,
      surface: tokens.canvas,
      onSurface: tokens.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: VercelTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? tokens.canvasSoft2 : tokens.canvas,
      cardColor: tokens.canvas,
      dividerColor: tokens.hairline,
      textTheme: VercelTypography.textTheme(brightness: brightness),
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.canvas,
        foregroundColor: tokens.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: VercelTypography.textTheme(brightness: brightness)
            .titleMedium
            ?.copyWith(color: tokens.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 49,
        backgroundColor: tokens.tabBarBackground,
        indicatorColor: tokens.link.withValues(alpha: isLight ? 0.12 : 0.24),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? tokens.link : tokens.mute,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: VercelTypography.fontFamily,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? tokens.link : tokens.mute,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          minimumSize: const Size(64, 44),
          textStyle: const TextStyle(
            fontFamily: VercelTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // DESIGN.md pill
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.ink,
          minimumSize: const Size(64, 44),
          side: BorderSide(color: tokens.hairline),
          textStyle: const TextStyle(
            fontFamily: VercelTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.canvas,
        hintStyle: TextStyle(color: tokens.mute),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.link, width: 1.5),
        ),
      ),
    );
  }
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
        statusBarColor: isDark ? VercelTokens.dark.canvasSoft2 : VercelTokens.light.canvas,
        systemNavigationBarColor:
            isDark ? VercelTokens.dark.canvasSoft2 : VercelTokens.light.canvas,
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
    // OHOS Flutter 的 SystemChrome MethodChannel 偶发不回包，await 会卡死启动白屏。
    await _setEnabledSystemUiMode(
      immersive ? SystemUiMode.edgeToEdge : SystemUiMode.manual,
      overlays: immersive ? null : SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      overlayStyle(brightness: brightness, immersive: immersive),
    );
  }

  /// 视频播放页：隐藏状态栏时间与系统图标（immersiveSticky）。
  static Future<void> applyPlayback() async {
    await _setEnabledSystemUiMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static Future<void> _setEnabledSystemUiMode(
    SystemUiMode mode, {
    List<SystemUiOverlay>? overlays,
  }) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        mode,
        overlays: overlays,
      ).timeout(const Duration(milliseconds: 500));
    } catch (_) {
      // Ignore timeout / unimplemented — overlay style still applies.
    }
  }

  /// 离开播放页后恢复为应用默认 edgeToEdge 沉浸式。
  static Future<void> restoreFromPlayback({
    required Brightness brightness,
  }) async {
    await apply(brightness: brightness, immersive: true);
  }
}
