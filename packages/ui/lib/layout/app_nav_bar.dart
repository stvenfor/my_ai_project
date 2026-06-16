import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_common_ui/layout/app_nav_bar_style.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_common_ui/theme/app_theme.dart';

/// 自定义导航栏（替代 Material [AppBar]，无业务逻辑）。
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.style = AppNavBarStyle.solid,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.overlayStyle,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final AppNavBarStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final SystemUiOverlayStyle? overlayStyle;

  @override
  Widget build(BuildContext context) {
    final top = AppSafeInsets.top(context);
    final theme = Theme.of(context);
    final fg = foregroundColor ?? _defaultForeground(context);
    final bg = backgroundColor ?? _defaultBackground(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle ??
          ImmersiveHelper.overlayStyle(
            brightness: style == AppNavBarStyle.dark
                ? Brightness.dark
                : theme.brightness,
            immersive: true,
          ),
      child: Material(
        color: style == AppNavBarStyle.transparent ? Colors.transparent : bg,
        elevation: 0,
        child: Container(
          decoration: style == AppNavBarStyle.solid
              ? BoxDecoration(
                  color: bg,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                  ),
                )
              : null,
          padding: EdgeInsets.only(top: top),
          child: SizedBox(
            height: AppSafeInsets.toolbarHeight,
            child: NavigationToolbar(
              leading: _buildLeading(context, fg),
              middle: _buildTitle(fg),
              trailing: actions != null
                  ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                  : null,
              centerMiddle: centerTitle,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color fg) {
    if (leading != null) return leading;
    if (!showBackButton) return null;
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: 20, color: fg),
      onPressed: onBack ?? () => Navigator.maybePop(context),
    );
  }

  Widget? _buildTitle(Color fg) {
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;
    return Text(
      title!,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );
  }

  Color _defaultBackground(BuildContext context) {
    return switch (style) {
      AppNavBarStyle.solid => Theme.of(context).cardColor,
      AppNavBarStyle.transparent => Colors.transparent,
      AppNavBarStyle.dark => Colors.black,
    };
  }

  Color _defaultForeground(BuildContext context) {
    if (foregroundColor != null) return foregroundColor!;
    return switch (style) {
      AppNavBarStyle.dark => Colors.white,
      AppNavBarStyle.transparent => Theme.of(context).colorScheme.onSurface,
      AppNavBarStyle.solid => Theme.of(context).colorScheme.onSurface,
    };
  }
}
