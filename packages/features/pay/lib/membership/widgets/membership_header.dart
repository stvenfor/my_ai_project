import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';
import 'package:module_pay/membership/widgets/membership_tier_tabs.dart';

class MembershipHeader extends GetView<MembershipRenewController> {
  const MembershipHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tier = controller.selectedTier.value;
      final palette = MembershipPalette.of(tier);
      final profile = controller.profile;
      final top = AppSafeInsets.top(context);
      final width = MediaQuery.sizeOf(context).width;
      final headerAsset = tier == MembershipTier.svip
          ? MembershipAssets.headerSvip
          : MembershipAssets.headerAiSvip;

      return SizedBox(
        height: MembershipDimens.headerTotalHeight(context, width),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Stack(
            key: ValueKey<MembershipTier>(tier),
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  headerAsset,
                  package: MembershipAssets.package,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: palette.headerGradient,
                      ),
                    ),
                  ),
                ),
              ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        top + MembershipDimens.headerTopPadding,
                        16,
                        MembershipDimens.headerBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MembershipHeaderBackButton(
                                onTap: () => Get.back<void>(),
                              ),
                              const Spacer(),
                              MembershipHeaderIconButton(
                                asset: MembershipAssets.iconService,
                                onTap: controller.openCustomerService,
                              ),
                            ],
                          ),
                          SizedBox(height: MembershipDimens.headerProfileGap),
                          SizedBox(
                            height: MembershipDimens.headerAvatarSize,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius:
                                      MembershipDimens.headerAvatarSize / 2,
                                  backgroundImage:
                                      NetworkImage(profile.avatarUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            profile.displayName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              height: 1.1,
                                              color:
                                                  MembershipPalette.titleBlack,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: palette.accent
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              profile.levelBadge,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                height: 1.1,
                                                color: palette.accent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile.statusText,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.1,
                                          color: MembershipPalette.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const MembershipTierTabs(),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MembershipHeaderIconButton extends StatelessWidget {
  const MembershipHeaderIconButton({
    super.key,
    this.asset,
    this.icon,
    required this.onTap,
  }) : assert(asset != null || icon != null);

  final String? asset;
  final Widget? icon;
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
          child: icon ??
              Image.asset(
                asset!,
                package: MembershipAssets.package,
                width: 22,
                height: 22,
              ),
        ),
      ),
    );
  }
}

class MembershipHeaderBackButton extends StatelessWidget {
  const MembershipHeaderBackButton({
    super.key,
    required this.onTap,
    this.color,
  });

  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MembershipHeaderIconButton(
      onTap: onTap,
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 18,
        color: color ?? MembershipPalette.titleBlack,
      ),
    );
  }
}
