import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';

/// 首页功能格入口页：标题 + 可滚动内容体。
class HomeFeatureContentPage extends StatelessWidget {
  const HomeFeatureContentPage({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: HomeDashboardTheme.background,
      navBar: AppNavBar(title: title, showBackButton: true),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        children: [child],
      ),
    );
  }
}
