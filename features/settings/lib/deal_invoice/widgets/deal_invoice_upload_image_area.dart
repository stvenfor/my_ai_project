import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_settings/deal_invoice/viewmodel/deal_invoice_upload_viewmodel.dart';
import 'package:module_utils/module_utils.dart';

/// 发票图片区：新建虚线框 / 预览 / 审核通过戳 / 重新上传遮罩。
class DealInvoiceUploadImageArea extends StatelessWidget {
  const DealInvoiceUploadImageArea({super.key, required this.controller});

  final DealInvoiceUploadViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasImage = controller.hasInvoiceImage.value;
      final uploading = controller.isUploading;
      final showStamp = controller.showApprovedStamp;
      final showReupload = controller.showReuploadOverlay;
      final showPending = controller.showPendingPlaceholder;
      final isEditing = controller.isEditing;

      if (!hasImage && isEditing) {
        return _DashedUploadBox(
          uploading: uploading,
          onTap: controller.pickInvoiceImage,
        );
      }

      if (showPending) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1.45,
            child: ColoredBox(
              color: const Color(0xFFF0F0F0),
              child: Icon(
                Icons.file_upload_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: showReupload
            ? controller.pickInvoiceImage
            : (isEditing ? controller.pickInvoiceImage : null),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CacheImageUtils.network(
                  DealInvoiceUploadViewModel.invoicePreviewUrl,
                  fit: BoxFit.cover,
                ),
                if (uploading)
                  Container(
                    color: Colors.black38,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                if (showStamp) const _ApprovedStamp(),
                if (showReupload) const _ReuploadOverlay(),
                if (isEditing && hasImage && !uploading)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => controller.hasInvoiceImage.value = false,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DashedUploadBox extends StatelessWidget {
  const _DashedUploadBox({
    required this.uploading,
    required this.onTap,
  });

  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFB8C9F0),
          radius: 8,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (uploading)
                const CircularProgressIndicator(strokeWidth: 2)
              else ...[
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
                  '上传发票',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '请保证发票清晰可识别、避免模糊和遮挡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovedStamp extends StatelessWidget {
  const _ApprovedStamp();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE53935), width: 3),
        ),
        alignment: Alignment.center,
        child: const Text(
          '审核\n通过',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE53935),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ReuploadOverlay extends StatelessWidget {
  const _ReuploadOverlay();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: Colors.black.withValues(alpha: 0.55),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              '重新上传',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
