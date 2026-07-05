import 'package:flutter/material.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingCoverImage extends StatelessWidget {
  const DubbingCoverImage({
    super.key,
    required this.asset,
    required this.width,
    required this.height,
    this.borderRadius,
    this.duration,
    this.badge,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final String? duration;
  final String? badge;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(DubbingHomeTheme.thumbRadius.r);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              DubbingHomeAssets.path(asset),
              package: DubbingHomeAssets.package,
              fit: fit,
            ),
            if (duration != null)
              Positioned(
                left: 6.w,
                bottom: 6.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        DubbingHomeAssets.path('icon_play_badge.png'),
                        package: DubbingHomeAssets.package,
                        width: 10.w,
                        height: 10.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        duration!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (badge != null)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: badge == 'AD'
                        ? DubbingHomeTheme.primaryGreen
                        : const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
