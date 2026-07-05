import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/membership_assets.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';
import 'package:module_pay/membership/widgets/membership_header.dart';

class MembershipCollapsedNavBar extends GetView<MembershipRenewController> {
  const MembershipCollapsedNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final top = AppSafeInsets.top(context);
    final profile = controller.profile;

    return Obx(() {
      final visible = controller.showCollapsedNav.value;

      return IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Material(
            color: MembershipPalette.cardWhite,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MembershipPalette.cardWhite,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
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
                        MembershipHeaderBackButton(
                          onTap: () => Get.back<void>(),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage:
                                    NetworkImage(profile.avatarUrl),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  profile.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: MembershipPalette.titleBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        MembershipHeaderIconButton(
                          asset: MembershipAssets.iconService,
                          onTap: controller.openCustomerService,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
