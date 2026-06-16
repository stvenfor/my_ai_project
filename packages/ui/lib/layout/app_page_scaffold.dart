import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_common_ui/layout/app_page_layout.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_common_ui/theme/app_theme.dart';

/// 统一页面容器：沉浸式 + 自定义 NavBar + 安全区。
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.body,
    this.layout = AppPageLayout.standard,
    this.navBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget body;
  final AppPageLayout layout;
  final Widget? navBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  bool get _showNavBar =>
      navBar != null &&
      layout != AppPageLayout.edgeToEdge &&
      layout != AppPageLayout.mainTabRoot;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return ImmersiveAnnotated(
      child: Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: true,
        extendBodyBehindAppBar: layout == AppPageLayout.fullBleed,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (layout) {
      case AppPageLayout.fullBleed:
        return Stack(
          fit: StackFit.expand,
          children: [
            body,
            if (_showNavBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: navBar!,
              ),
          ],
        );
      case AppPageLayout.standard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showNavBar) navBar!,
            Expanded(child: body),
          ],
        );
      case AppPageLayout.edgeToEdge:
      case AppPageLayout.mainTabRoot:
        return body;
    }
  }
}

/// 为子树应用沉浸式 SystemUiOverlayStyle。
class ImmersiveAnnotated extends StatelessWidget {
  const ImmersiveAnnotated({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ImmersiveHelper.overlayStyle(
        brightness: brightness,
        immersive: true,
      ),
      child: child,
    );
  }
}

/// 仅处理底部安全区（Tab 根页 / 全屏页正文底部）。
class AppBottomSafe extends StatelessWidget {
  const AppBottomSafe({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSafeInsets.bottom(context)),
      child: child,
    );
  }
}
