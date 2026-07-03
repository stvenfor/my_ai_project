import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/model/mine_profile_model.dart';
import 'package:module_settings/mine/widgets/mine_stats_bar_widget.dart';
import 'package:module_utils/module_utils.dart';

class MineHeaderWidget extends StatelessWidget {
  const MineHeaderWidget({super.key, required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();

    return Obx(() {
      final data = controller.profile.value;
      if (data == null) {
        return const SizedBox(height: 220);
      }
      return _HeaderBody(data: data, showBackButton: showBackButton);
    });
  }
}

class _HeaderBody extends StatelessWidget {
  const _HeaderBody({
    required this.data,
    required this.showBackButton,
  });

  final MineProfileModel data;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDCEEF9), Color(0xFFEEF6FB)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: topPadding + 20,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          if (showBackButton)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  size: 20),
                              onPressed: () => Get.back<void>(),
                            )
                          else
                            const SizedBox(width: 8),
                          const Spacer(),
                          _TopIcon(
                            icon: Icons.info_outline,
                            onTap: controller.onInfoTap,
                          ),
                          _TopIcon(
                            icon: Icons.event_available_outlined,
                            onTap: controller.onCalendarTap,
                          ),
                          _TopIcon(
                            icon: Icons.settings_outlined,
                            onTap: controller.openSettings,
                          ),
                          Obx(() {
                            final loggedIn =
                                Get.find<UserService>().isLoggedIn;
                            return _TopIcon(
                              icon: loggedIn
                                  ? Icons.logout_rounded
                                  : Icons.login_rounded,
                              onTap: loggedIn
                                  ? controller.logout
                                  : controller.goLogin,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      data.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _RoleBadge(label: data.roleBadge),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: controller.onStoreTap,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        data.storeName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: controller.onElectronicCardTap,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '电子名片',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    data.maskedPhone,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: controller.onAvatarTap,
                          child: _Avatar(url: data.avatarUrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -28,
          child: MineStatsBarWidget(stats: data.stats),
        ),
      ],
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22, color: const Color(0xFF333333)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3B8CFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarImage(url),
      ),
    );
  }

  Widget _buildAvatarImage(String? url) {
    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    if (_isLocalPath(url)) {
      return Image.file(
        File(url.replaceFirst('file:', '')),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return CacheImageUtils.network(url, width: 72, height: 72, fit: BoxFit.cover);
  }

  bool _isLocalPath(String url) =>
      url.startsWith('/') || url.startsWith('file:');

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Icon(Icons.person, size: 36, color: Colors.white),
    );
  }
}
