import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:wys_common/src/wys_screen_protector.dart';
import 'package:wys_common/src/wys_image_downloader.dart';

/// 图片预览页面
///
/// 对齐安卓 `SimpleImagePreviewActivity`：
/// - 多图左右滑动 (ViewPager2 → PhotoViewGallery)
/// - 双指缩放 (PhotoView → PhotoView)
/// - 防截屏 (FLAG_SECURE → setWindowPrivacyMode)
/// - 可选下载按钮 (allowToDownload)
/// - 点击关闭
class WysImagePreview extends StatefulWidget {
  const WysImagePreview({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.allowToDownload = false,
    this.isDisableScreenShot = false,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final bool allowToDownload;
  final bool isDisableScreenShot;

  /// 单图预览（兼容旧调用）
  static void show(
    BuildContext context,
    String imageUrl, {
    bool allowToDownload = false,
    bool isDisableScreenShot = false,
  }) {
    showList(
      context,
      [imageUrl],
      initialIndex: 0,
      allowToDownload: allowToDownload,
      isDisableScreenShot: isDisableScreenShot,
    );
  }

  /// 多图预览
  static void showList(
    BuildContext context,
    List<String> imageUrls, {
    int initialIndex = 0,
    bool allowToDownload = false,
    bool isDisableScreenShot = false,
  }) {
    if (imageUrls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WysImagePreview(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          allowToDownload: allowToDownload,
          isDisableScreenShot: isDisableScreenShot,
        ),
      ),
    );
  }

  @override
  State<WysImagePreview> createState() => _WysImagePreviewState();
}

class _WysImagePreviewState extends State<WysImagePreview> {
  late PageController _pageController;
  late int _currentIndex;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.isDisableScreenShot) {
      // skipInDebug: false 保持预览页 Debug 包也生效，便于真机验证防截屏
      WysScreenProtector.enable(skipInDebug: false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (widget.isDisableScreenShot) {
      WysScreenProtector.disable(skipInDebug: false);
    }
    super.dispose();
  }

  Future<void> _downloadImage(String url) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final localPath = await WysImageDownloader.downloadToCache(url);
      if (localPath == null || localPath.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片下载失败'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      final name = 'wys_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ok = await WysImageDownloader.saveFileToAlbum(localPath, name: name)
          .timeout(const Duration(seconds: 30), onTimeout: () => false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? '已保存到系统相册' : '保存到系统相册失败'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[WysImagePreview] download failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存到系统相册失败'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PhotoViewGallery — 多图滑动 + 缩放
          PhotoViewGallery.builder(
            pageController: _pageController,
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'image_$index',
                ),
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 80,
                    ),
                  );
                },
              );
            },
            loadingBuilder: (context, event) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            enableRotation: false,
          ),
          // 关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          // 页码指示器
          if (widget.imageUrls.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          // 下载按钮
          if (widget.allowToDownload)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: GestureDetector(
                onTap: _downloading
                    ? null
                    : () => _downloadImage(widget.imageUrls[_currentIndex]),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: _downloading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download,
                          color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
