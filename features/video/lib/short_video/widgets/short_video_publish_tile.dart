import 'package:flutter/material.dart';
import 'package:module_utils/module_utils.dart';

class ShortVideoPublishTile extends StatelessWidget {
  const ShortVideoPublishTile({
    super.key,
    required this.aspectRatio,
    required this.onTap,
  });

  final double aspectRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth * aspectRatio;
        return SizedBox(
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8.r),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: const Color(0xFF91D5FF),
                  radius: 8.r,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1890FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 28.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '发布小视频',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1890FF),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '拍视频，增加人气（长按已发布小视频可删除）',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
