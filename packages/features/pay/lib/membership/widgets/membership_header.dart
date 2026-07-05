import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';

class MembershipHeader extends GetView<MembershipRenewController> {
  const MembershipHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final profile = controller.profile;
      final top = AppSafeInsets.top(context);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.headerGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: top,
              child: Image.asset(
                tier == MembershipTier.svip
                    ? MembershipAssets.headerSvipWatermark
                    : MembershipAssets.headerAiSvipWatermark,
                package: MembershipAssets.package,
                width: 140,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, top + 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconButton(
                        asset: MembershipAssets.iconBack,
                        onTap: () => Get.back<void>(),
                      ),
                      const Spacer(),
                      _IconButton(
                        asset: MembershipAssets.iconService,
                        onTap: controller.openCustomerService,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(profile.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  profile.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: MembershipPalette.titleBlack,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    profile.levelBadge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: palette.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.statusText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MembershipPalette.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            asset,
            package: MembershipAssets.package,
            width: 22,
            height: 22,
          ),
        ),
      ),
    );
  }
}
