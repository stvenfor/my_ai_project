import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class ShortVideoEmptyState extends StatelessWidget {
  const ShortVideoEmptyState({
    super.key,
    required this.onShootTap,
    required this.onHelpTap,
  });

  final VoidCallback onShootTap;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieUtils.asset(
            'assets/lotties/short_video_empty.json',
            width: 180.w,
            height: 180.w,
            repeat: true,
            errorBuilder: (_, __, ___) => _FallbackIllustration(size: 140.w),
          ),
          SizedBox(height: 16.h),
          Text(
            '还没发过小视频，去发一个试试吧~',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton.icon(
              onPressed: onShootTap,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1890FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                '拍摄小视频',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: onHelpTap,
            icon: Icon(Icons.help_outline, size: 16.sp, color: const Color(0xFF1890FF)),
            label: Text(
              '如何拍摄小视频',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1890FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0F4F8),
            ),
          ),
          Icon(
            Icons.videocam_outlined,
            size: size * 0.35,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
