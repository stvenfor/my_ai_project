import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/model/mine_profile_model.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
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
        return SizedBox(height: 180 + AppSafeInsets.top(context));
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
    final topPadding = AppSafeInsets.top(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      size: 24,
                      color: MineTheme.accent,
                    ),
                  ),
                )
              else
                Expanded(child: Text('我的', style: MineTheme.largeTitle)),
              if (showBackButton) const Spacer(),
              _TopIcon(icon: CupertinoIcons.info, onTap: controller.onInfoTap),
              _TopIcon(
                icon: CupertinoIcons.calendar,
                onTap: controller.onCalendarTap,
              ),
              _TopIcon(
                icon: CupertinoIcons.settings,
                onTap: controller.openSettings,
              ),
              Obx(() {
                final loggedIn = Get.find<UserService>().isLoggedIn;
                return _TopIcon(
                  icon: loggedIn
                      ? CupertinoIcons.square_arrow_right
                      : CupertinoIcons.person_crop_circle_badge_plus,
                  onTap: loggedIn ? controller.logout : controller.goLogin,
                );
              }),
            ],
          ),
          if (!showBackButton) const SizedBox(height: 8),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: MineTheme.groupedCardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: controller.onAvatarTap,
                    child: _Avatar(url: data.avatarUrl),
                  ),
                  const SizedBox(width: 16),
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
                                style: MineTheme.headline,
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
                                  style: MineTheme.caption,
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                size: 14,
                                color: MineTheme.labelSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _MetaChip(
                              icon: CupertinoIcons.creditcard,
                              label: '电子名片',
                              onTap: controller.onElectronicCardTap,
                            ),
                            Text(
                              data.maskedPhone,
                              style: MineTheme.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          MineStatsBarWidget(stats: data.stats),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Icon(icon, size: 22, color: MineTheme.accent),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: MineTheme.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: MineTheme.accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: MineTheme.caption.copyWith(color: MineTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MineTheme.accent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.checkmark_seal_fill,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
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
        border: Border.all(color: MineTheme.surface, width: 2),
        boxShadow: MineTheme.cardShadow,
      ),
      child: ClipOval(child: _buildAvatarImage(url)),
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
      color: MineTheme.fillSecondary,
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 36,
        color: MineTheme.labelTertiary,
      ),
    );
  }
}
