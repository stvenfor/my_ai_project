import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeFeatureRow extends GetView<DubbingHomeController> {
  const DubbingHomeFeatureRow({
    super.key,
    required this.features,
  });

  final List<DubbingHomeFeatureItem> features;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 12.h),
      child: Row(
        children: [
          for (final feature in features)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.onFeatureTap(feature),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Image.asset(
                      DubbingHomeAssets.path(feature.iconAsset),
                      package: DubbingHomeAssets.package,
                      width: 52.w,
                      height: 52.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      feature.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DubbingHomeTheme.titleBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
