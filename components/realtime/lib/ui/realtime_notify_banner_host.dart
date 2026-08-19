import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/ui/realtime_notify_banner_controller.dart';

/// WebSocket 全局通知 Banner 宿主，挂载于 [GetMaterialApp.builder] 顶层。
///
/// 与 [RealtimeNotifyBannerController.banner] 联动，任意页面收到推送即可实时展示，
/// 不依赖路由切换或 [OverlayEntry]。
class RealtimeNotifyBannerHost extends StatefulWidget {
  const RealtimeNotifyBannerHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<RealtimeNotifyBannerHost> createState() =>
      _RealtimeNotifyBannerHostState();
}

class _RealtimeNotifyBannerHostState extends State<RealtimeNotifyBannerHost>
    with SingleTickerProviderStateMixin {
  RealtimeNotifyBannerController? _controller;
  Worker? _bannerWorker;
  Worker? _dismissWorker;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  RealtimeNotifyBannerData? _visible;
  bool _animatingOut = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: RealtimeConfig.notifyBannerAnimation,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    if (Get.isRegistered<RealtimeNotifyBannerController>()) {
      _bindController(Get.find<RealtimeNotifyBannerController>());
    }
  }

  void _bindController(RealtimeNotifyBannerController controller) {
    _controller = controller;
    _bannerWorker = ever<RealtimeNotifyBannerData?>(
      controller.banner,
      _onBannerChanged,
    );
    _dismissWorker = ever<bool>(
      controller.dismissing,
      _onDismissRequested,
    );

    final pending = controller.banner.value;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _present(pending);
      });
    }
  }

  void _onBannerChanged(RealtimeNotifyBannerData? data) {
    if (data == null || _animatingOut) return;
    if (_visible?.notifyId == data.notifyId && _animationController.isCompleted) {
      return;
    }
    _present(data);
  }

  void _onDismissRequested(bool dismissing) {
    if (!dismissing || _visible == null || _animatingOut) return;
    unawaited(_animateOut());
  }

  void _present(RealtimeNotifyBannerData data) {
    _animatingOut = false;
    setState(() => _visible = data);
    unawaited(_animationController.forward(from: 0));
  }

  Future<void> _animateOut() async {
    if (_animatingOut || _visible == null) return;
    _animatingOut = true;
    await _animationController.reverse();
    if (!mounted) return;
    _controller?.finishDismiss();
    setState(() {
      _visible = null;
      _animatingOut = false;
    });
  }

  void _handleTap() {
    _controller?.handleTap();
  }

  void _handleClose() {
    _controller?.requestDismiss();
  }

  @override
  void dispose() {
    _bannerWorker?.dispose();
    _dismissWorker?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        widget.child,
        if (visible != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            right: 12,
            child: IgnorePointer(
              ignoring: _animatingOut,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surface,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! < -200) {
                        _handleClose();
                      }
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _handleTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    visible.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (visible.body.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      visible.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _handleClose,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
