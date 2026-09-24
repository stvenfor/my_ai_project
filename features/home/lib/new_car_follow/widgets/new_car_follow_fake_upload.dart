import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

/// 假上传：仅本地选图预览，不接 OSS。
class NewCarFollowFakeUpload extends StatelessWidget {
  const NewCarFollowFakeUpload({
    super.key,
    required this.localPath,
    this.readOnly = false,
    this.title = '客户资料图（可选）',
    this.hint = '本地预览，不会上传到服务器',
  });

  final RxnString localPath;
  final bool readOnly;
  final String title;
  final String hint;

  Future<void> _pick() async {
    final action = await Get.bottomSheet<String>(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Get.back(result: 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照'),
              onTap: () => Get.back(result: 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('使用占位图'),
              onTap: () => Get.back(result: 'placeholder'),
            ),
            if (localPath.value != null && localPath.value!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                title: const Text('清除', style: TextStyle(color: Color(0xFFE53935))),
                onTap: () => Get.back(result: 'clear'),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
    if (action == null) return;
    if (action == 'clear') {
      localPath.value = null;
      return;
    }
    if (action == 'placeholder') {
      localPath.value = 'placeholder://follow';
      return;
    }
    final source = action == 'camera'
        ? MediaPickSource.camera
        : MediaPickSource.gallery;
    if (action == 'camera') {
      final ok = await CameraPermissionGate.ensure(
        deniedToast: '需要相机权限才能拍摄，请在系统弹窗中允许',
        settingsMessage: '相机权限已被关闭。请在系统设置中开启后，再回来拍摄。',
      );
      if (!ok) return;
    }
    final path = await ImagePickerUtils.pickImage(source, maxWidth: 1600);
    if (path != null && path.isNotEmpty) {
      localPath.value = path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final path = localPath.value;
          final has = path != null && path.isNotEmpty;
          if (!has) {
            return GestureDetector(
              onTap: readOnly ? null : _pick,
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: const Color(0xFFB8C9F0),
                  radius: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF6EB4FF), Color(0xFF3B8CFF)],
                          ),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '添加图片',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: readOnly ? null : _pick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (path.startsWith('placeholder:'))
                      ColoredBox(
                        color: const Color(0xFFE8EEF8),
                        child: Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                      )
                    else
                      Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: const Color(0xFFF0F0F0),
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    if (!readOnly)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => localPath.value = null,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Text(
                          hint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
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
