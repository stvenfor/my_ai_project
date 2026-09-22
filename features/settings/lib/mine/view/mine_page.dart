import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_settings/mine/widgets/mine_function_section_widget.dart';
import 'package:module_settings/mine/widgets/mine_header_widget.dart';
import 'package:module_settings/mine/widgets/mine_menu_list_widget.dart';
import 'package:module_settings/mine/widgets/mine_quick_services_widget.dart';

class MinePage extends StatefulWidget {
  const MinePage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  /// 滚动这段距离后导航栏 opacity 到 1，之后常显。
  static const _navFadeExtent = 72.0;

  final _navOpacity = ValueNotifier<double>(0);

  MineController get controller => Get.find<MineController>();

  @override
  void dispose() {
    _navOpacity.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is! ScrollUpdateNotification &&
        notification is! OverscrollNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }

    final next =
        (notification.metrics.pixels / _navFadeExtent).clamp(0.0, 1.0);
    if ((next - _navOpacity.value).abs() >= 0.01) {
      _navOpacity.value = next;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.mainTabRoot,
      backgroundColor: MineTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 840
              ? MineTheme.contentMaxWidth
              : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: MineHeaderWidget(
                            showBackButton: widget.showBackButton,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MineQuickServicesWidget(
                            onTap: controller.onQuickServiceTap,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: MineFunctionSectionWidget(),
                        ),
                        SliverToBoxAdapter(
                          child: MineMenuListWidget(
                            onTap: controller.onMenuTap,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: AppSafeInsets.bottom(context) + 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _navOpacity,
                      builder: (context, opacity, _) {
                        return IgnorePointer(
                          ignoring: opacity < 0.05,
                          child: Opacity(
                            opacity: opacity,
                            child: _MineCollapsedNavBar(
                              showBackButton: widget.showBackButton,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 上滑渐显的吸顶导航栏：标题 + 与 Header 同款操作图标。
class _MineCollapsedNavBar extends StatelessWidget {
  const _MineCollapsedNavBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    final top = AppSafeInsets.top(context);

    return Material(
      color: MineTheme.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MineTheme.surface,
          border: Border(
            bottom: BorderSide(color: MineTheme.separator),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: top),
          child: SizedBox(
            height: AppSafeInsets.toolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (showBackButton)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Get.back<void>(),
                        child: const Icon(
                          CupertinoIcons.back,
                          size: 22,
                          color: MineTheme.accent,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      '我的',
                      textAlign:
                          showBackButton ? TextAlign.center : TextAlign.left,
                      style: MineTheme.headline,
                    ),
                  ),
                  _CollapsedIcon(
                    icon: CupertinoIcons.info,
                    onTap: controller.onInfoTap,
                  ),
                  _CollapsedIcon(
                    icon: CupertinoIcons.calendar,
                    onTap: controller.onCalendarTap,
                  ),
                  _CollapsedIcon(
                    icon: CupertinoIcons.settings,
                    onTap: controller.openSettings,
                  ),
                  Obx(() {
                    final loggedIn = Get.find<UserService>().isLoggedIn;
                    return _CollapsedIcon(
                      icon: loggedIn
                          ? CupertinoIcons.person_crop_circle
                          : CupertinoIcons.person_crop_circle_badge_plus,
                      onTap: controller.openProfile,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedIcon extends StatelessWidget {
  const _CollapsedIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 44,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Icon(icon, size: 22, color: MineTheme.accent),
      ),
    );
  }
}
