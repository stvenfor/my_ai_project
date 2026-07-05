import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeBannerCarousel extends GetView<DubbingHomeController> {
  const DubbingHomeBannerCarousel({
    super.key,
    required this.banners,
  });

  final List<DubbingHomeBannerItem> banners;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Column(
        children: [
          SizedBox(
            height: 156.h,
            child: PageView.builder(
              itemCount: banners.length,
              onPageChanged: controller.onBannerChanged,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(DubbingHomeTheme.cardRadius.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        DubbingHomeAssets.path(banner.imageAsset),
                        package: DubbingHomeAssets.package,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: DubbingHomeTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'AD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final index = controller.bannerIndex.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == index ? 14.w : 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: i == index
                          ? DubbingHomeTheme.primaryGreen
                          : DubbingHomeTheme.divider,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
