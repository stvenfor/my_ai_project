import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_utils/module_utils.dart';

/// 相册 / 相机来源选择底部弹框。
class MediaSourceBottomSheet extends StatelessWidget {
  const MediaSourceBottomSheet({super.key});

  static Future<MediaPickSource?> show() {
    return Get.bottomSheet<MediaPickSource>(
      const MediaSourceBottomSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            _OptionTile(
              icon: Icons.photo_library_outlined,
              label: '相册',
              onTap: () => Get.back(result: MediaPickSource.gallery),
            ),
            Divider(height: 1.h, indent: 56.w, color: const Color(0xFFF0F0F0)),
            _OptionTile(
              icon: Icons.camera_alt_outlined,
              label: '相机',
              onTap: () => Get.back(result: MediaPickSource.camera),
            ),
            Divider(height: 8.h, color: const Color(0xFFF5F5F5)),
            _OptionTile(
              label: '取消',
              onTap: () => Get.back<void>(),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22.sp, color: const Color(0xFF333333)),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Text(
                label,
                textAlign: icon == null ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: icon == null
                      ? const Color(0xFF666666)
                      : const Color(0xFF1A1A1A),
                  fontWeight: icon == null ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
            if (icon != null) SizedBox(width: 38.w),
          ],
        ),
      ),
    );
  }
}
