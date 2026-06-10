import 'package:flutter/material.dart';

enum AppScreenType { phone, tablet }

class AppBreakpoints {
  static const double tabletMinWidth = 600;
  static const double contentMaxWidth = 960;

  static AppScreenType screenTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMinWidth ? AppScreenType.tablet : AppScreenType.phone;
  }

  static bool isTablet(BuildContext context) {
    return screenTypeOf(context) == AppScreenType.tablet;
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.builder,
    this.tabletPadding = const EdgeInsets.symmetric(horizontal: 32),
    this.phonePadding = EdgeInsets.zero,
  });

  final Widget Function(BuildContext context, AppScreenType screenType) builder;
  final EdgeInsets tabletPadding;
  final EdgeInsets phonePadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = constraints.maxWidth >= AppBreakpoints.tabletMinWidth
            ? AppScreenType.tablet
            : AppScreenType.phone;
        final padding =
            screenType == AppScreenType.tablet ? tabletPadding : phonePadding;
        return Padding(
          padding: padding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: builder(context, screenType),
            ),
          ),
        );
      },
    );
  }
}

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.phone,
    this.tablet,
  });

  final Widget phone;
  final Widget? tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            constraints.maxWidth >= AppBreakpoints.tabletMinWidth;
        if (isTablet && tablet != null) return tablet!;
        return phone;
      },
    );
  }
}
