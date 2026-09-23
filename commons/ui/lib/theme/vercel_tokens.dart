import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/config/app_config_controller.dart';

/// Vercel Token API — Design Source of Truth colors for light/dark.
///
/// Prefer `VercelTokens.of(context)` in widgets. Use [current] only from
/// legacy feature `*Theme` getters that lack a [BuildContext].
@immutable
class VercelTokens extends ThemeExtension<VercelTokens> {
  const VercelTokens({
    required this.primary,
    required this.onPrimary,
    required this.ink,
    required this.body,
    required this.mute,
    required this.hairline,
    required this.hairlineStrong,
    required this.canvas,
    required this.canvasSoft,
    required this.canvasSoft2,
    required this.link,
    required this.linkDeep,
    required this.linkBgSoft,
    required this.success,
    required this.error,
    required this.errorSoft,
    required this.errorDeep,
    required this.warning,
    required this.warningSoft,
    required this.warningDeep,
    required this.violet,
    required this.cyan,
    required this.highlightPink,
    required this.selectionBg,
    required this.selectionFg,
    required this.tabBarBackground,
  });

  final Color primary;
  final Color onPrimary;
  final Color ink;
  final Color body;
  final Color mute;
  final Color hairline;
  final Color hairlineStrong;
  final Color canvas;
  final Color canvasSoft;
  final Color canvasSoft2;
  final Color link;
  final Color linkDeep;
  final Color linkBgSoft;
  final Color success;
  final Color error;
  final Color errorSoft;
  final Color errorDeep;
  final Color warning;
  final Color warningSoft;
  final Color warningDeep;
  final Color violet;
  final Color cyan;
  final Color highlightPink;
  final Color selectionBg;
  final Color selectionFg;
  final Color tabBarBackground;

  /// DESIGN.md light palette.
  static const light = VercelTokens(
    primary: Color(0xFF171717),
    onPrimary: Color(0xFFFFFFFF),
    ink: Color(0xFF171717),
    body: Color(0xFF4D4D4D),
    mute: Color(0xFF888888),
    hairline: Color(0xFFEBEBEB),
    hairlineStrong: Color(0xFFA1A1A1),
    canvas: Color(0xFFFFFFFF),
    canvasSoft: Color(0xFFFAFAFA),
    canvasSoft2: Color(0xFFF5F5F5),
    link: Color(0xFF0070F3),
    linkDeep: Color(0xFF0761D1),
    linkBgSoft: Color(0xFFD3E5FF),
    success: Color(0xFF0070F3),
    error: Color(0xFFEE0000),
    errorSoft: Color(0xFFF7D4D6),
    errorDeep: Color(0xFFC50000),
    warning: Color(0xFFF5A623),
    warningSoft: Color(0xFFFFEFCF),
    warningDeep: Color(0xFFAB570A),
    violet: Color(0xFF7928CA),
    cyan: Color(0xFF50E3C2),
    highlightPink: Color(0xFFFF0080),
    selectionBg: Color(0xFF171717),
    selectionFg: Color(0xFFF2F2F2),
    tabBarBackground: Color(0xF2FFFFFF),
  );

  /// Dark palette aligned with DESIGN.md / preview-dark semantics.
  static const dark = VercelTokens(
    primary: Color(0xFFEDEDED),
    onPrimary: Color(0xFF0A0A0A),
    ink: Color(0xFFEDEDED),
    body: Color(0xFFA1A1A1),
    mute: Color(0xFF666666),
    hairline: Color(0xFF2E2E2E),
    hairlineStrong: Color(0xFF4D4D4D),
    canvas: Color(0xFF000000),
    canvasSoft: Color(0xFF0A0A0A),
    canvasSoft2: Color(0xFF111111),
    link: Color(0xFF0070F3),
    linkDeep: Color(0xFF3291FF),
    linkBgSoft: Color(0xFF0B1A33),
    success: Color(0xFF0070F3),
    error: Color(0xFFFF3333),
    errorSoft: Color(0xFF3B1214),
    errorDeep: Color(0xFFFF6666),
    warning: Color(0xFFF5A623),
    warningSoft: Color(0xFF2A1F0A),
    warningDeep: Color(0xFFFFCC66),
    violet: Color(0xFF8A63D2),
    cyan: Color(0xFF50E3C2),
    highlightPink: Color(0xFFFF0080),
    selectionBg: Color(0xFFEDEDED),
    selectionFg: Color(0xFF0A0A0A),
    tabBarBackground: Color(0xE60A0A0A),
  );

  static VercelTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<VercelTokens>();
    assert(tokens != null, 'VercelTokens missing from ThemeData.extensions');
    return tokens ?? VercelTokens.light;
  }

  /// Active palette for feature `*Theme` getters and shared chrome.
  ///
  /// **AppConfig first** — [Get.context] Theme can lag behind [GetMaterialApp]
  /// rebuilds and desync NavBar (`Theme.of`) from page body (`current()`).
  static VercelTokens current() {
    if (Get.isRegistered<AppConfigController>()) {
      return _forThemeMode(Get.find<AppConfigController>().themeMode);
    }
    final context = Get.context;
    if (context != null) {
      final tokens = Theme.of(context).extension<VercelTokens>();
      if (tokens != null) return tokens;
      return Theme.of(context).brightness == Brightness.dark ? dark : light;
    }
    return light;
  }

  /// Widgets with [BuildContext]: same palette as [current] when config exists,
  /// otherwise [of]. Keeps NavBar / Scaffold / TabBar aligned with feature themes.
  static VercelTokens resolve(BuildContext context) {
    if (Get.isRegistered<AppConfigController>()) return current();
    return of(context);
  }

  static VercelTokens _forThemeMode(ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    return brightness == Brightness.dark ? dark : light;
  }

  @override
  VercelTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? ink,
    Color? body,
    Color? mute,
    Color? hairline,
    Color? hairlineStrong,
    Color? canvas,
    Color? canvasSoft,
    Color? canvasSoft2,
    Color? link,
    Color? linkDeep,
    Color? linkBgSoft,
    Color? success,
    Color? error,
    Color? errorSoft,
    Color? errorDeep,
    Color? warning,
    Color? warningSoft,
    Color? warningDeep,
    Color? violet,
    Color? cyan,
    Color? highlightPink,
    Color? selectionBg,
    Color? selectionFg,
    Color? tabBarBackground,
  }) {
    return VercelTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      ink: ink ?? this.ink,
      body: body ?? this.body,
      mute: mute ?? this.mute,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      canvas: canvas ?? this.canvas,
      canvasSoft: canvasSoft ?? this.canvasSoft,
      canvasSoft2: canvasSoft2 ?? this.canvasSoft2,
      link: link ?? this.link,
      linkDeep: linkDeep ?? this.linkDeep,
      linkBgSoft: linkBgSoft ?? this.linkBgSoft,
      success: success ?? this.success,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      errorDeep: errorDeep ?? this.errorDeep,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      warningDeep: warningDeep ?? this.warningDeep,
      violet: violet ?? this.violet,
      cyan: cyan ?? this.cyan,
      highlightPink: highlightPink ?? this.highlightPink,
      selectionBg: selectionBg ?? this.selectionBg,
      selectionFg: selectionFg ?? this.selectionFg,
      tabBarBackground: tabBarBackground ?? this.tabBarBackground,
    );
  }

  @override
  VercelTokens lerp(ThemeExtension<VercelTokens>? other, double t) {
    if (other is! VercelTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return VercelTokens(
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      ink: mix(ink, other.ink),
      body: mix(body, other.body),
      mute: mix(mute, other.mute),
      hairline: mix(hairline, other.hairline),
      hairlineStrong: mix(hairlineStrong, other.hairlineStrong),
      canvas: mix(canvas, other.canvas),
      canvasSoft: mix(canvasSoft, other.canvasSoft),
      canvasSoft2: mix(canvasSoft2, other.canvasSoft2),
      link: mix(link, other.link),
      linkDeep: mix(linkDeep, other.linkDeep),
      linkBgSoft: mix(linkBgSoft, other.linkBgSoft),
      success: mix(success, other.success),
      error: mix(error, other.error),
      errorSoft: mix(errorSoft, other.errorSoft),
      errorDeep: mix(errorDeep, other.errorDeep),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      warningDeep: mix(warningDeep, other.warningDeep),
      violet: mix(violet, other.violet),
      cyan: mix(cyan, other.cyan),
      highlightPink: mix(highlightPink, other.highlightPink),
      selectionBg: mix(selectionBg, other.selectionBg),
      selectionFg: mix(selectionFg, other.selectionFg),
      tabBarBackground: mix(tabBarBackground, other.tabBarBackground),
    );
  }
}
