import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeHeader extends GetView<DubbingHomeController> {
  const DubbingHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back<void>(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: DubbingHomeTheme.titleBlack,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: controller.openSearch,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: DubbingHomeTheme.searchFieldBackground,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      DubbingHomeAssets.path('icon_search.png'),
                      package: DubbingHomeAssets.package,
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '学英语',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: DubbingHomeTheme.subtitleGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _HeaderIconButton(
            icon: Icons.history_rounded,
            onTap: () {},
          ),
          _HeaderIconButton(
            asset: 'icon_notification.png',
            showBadge: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    this.asset,
    this.icon,
    this.showBadge = false,
    required this.onTap,
  });

  final String? asset;
  final IconData? icon;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (asset != null)
              Image.asset(
                DubbingHomeAssets.path(asset!),
                package: DubbingHomeAssets.package,
                width: 22.w,
                height: 22.w,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(icon, size: 22.sp, color: DubbingHomeTheme.titleBlack),
            if (showBadge)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D4F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
