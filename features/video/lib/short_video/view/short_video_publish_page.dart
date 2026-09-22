import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/view/topic_select_page.dart';
import 'package:module_community/community/view/video_play_page.dart';
import 'package:module_http/module_http.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/controller/short_video_controller.dart';
import 'package:module_video/short_video/repository/http_short_video_repository.dart';
import 'package:module_video/short_video/utils/short_video_capture_permission.dart';
import 'package:video_player/video_player.dart';

/// 发布小视频：本地视频预览 + 封面 + 标题 + 话题；片源仍由服务端默认填充（不上传）。
class ShortVideoPublishPage extends StatefulWidget {
  const ShortVideoPublishPage({super.key});

  @override
  State<ShortVideoPublishPage> createState() => _ShortVideoPublishPageState();
}

class _ShortVideoPublishPageState extends State<ShortVideoPublishPage> {
  final _titleCtrl = TextEditingController();
  TopicModel? _topic;
  bool _busy = false;
  String? _localVideoPath;
  String? _localCoverPath;

  @override
  void initState() {
    super.initState();
    ShortVideoController.ensureCommunityTopicsRepo();
    final args = Get.arguments;
    if (args is Map && args['local_video_path'] is String) {
      _localVideoPath = args['local_video_path'] as String;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTopic() async {
    final selected = await Get.to<TopicModel>(
      () => TopicSelectPage(selectedId: _topic?.id),
    );
    if (selected != null) setState(() => _topic = selected);
  }

  Future<void> _pickVideo() async {
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final ok = await ShortVideoCapturePermission.ensureForCameraCapture();
        if (!ok) return;
      }
      final path = await ImagePickerUtils.pickVideo(
        source,
        skipPermissionCheck: source == MediaPickSource.camera,
      );
      if (path == null || path.isEmpty) return;
      setState(() {
        _localVideoPath = path;
        _localCoverPath = null;
      });
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择视频，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择视频失败');
    }
  }

  Future<void> _pickCover() async {
    if (_localVideoPath == null || _localVideoPath!.isEmpty) {
      UiKitInitializer.toastError('请先选择视频');
      return;
    }
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final ok = await ShortVideoCapturePermission.ensureForCameraCapture(
          withMicrophone: false,
        );
        if (!ok) return;
      }
      final path = await ImagePickerUtils.pickImage(source, maxWidth: 1280);
      if (path == null || path.isEmpty) return;
      setState(() => _localCoverPath = path);
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择图片，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择封面失败');
    }
  }

  void _previewVideo() {
    final path = _localVideoPath;
    if (path == null || path.isEmpty) return;
    Get.to<void>(
      () => VideoPlayPage(videoUrl: path),
      transition: Transition.fadeIn,
    );
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      UiKitInitializer.toast('请输入标题');
      return;
    }
    if (title.characters.length > 50) {
      UiKitInitializer.toast('标题最多 50 字');
      return;
    }
    if (_localVideoPath == null || _localVideoPath!.isEmpty) {
      UiKitInitializer.toast('请先选择或拍摄视频');
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = HttpShortVideoRepository();
      await repo.create(title: title, topicId: _topic?.id);
      if (Get.isRegistered<ShortVideoController>()) {
        await Get.find<ShortVideoController>().refreshAll();
      }
      UiKitInitializer.toast('发布成功（本地预览不上传，使用默认片源）');
      if (mounted) Get.back(result: true);
    } catch (e) {
      final msg = e is HttpRequestException
          ? (e.message.isNotEmpty ? e.message : '发布失败')
          : '发布失败';
      UiKitInitializer.toast(msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = _localVideoPath;

    return AppPageScaffold(
      backgroundColor: Colors.white,
      navBar: AppNavBar(
        title: '发布小视频',
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton(
              onPressed: _busy ? null : _publish,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1677FF),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: _busy
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('发布'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (path != null && path.isNotEmpty) ...[
            _LocalVideoPreview(
              videoPath: path,
              coverPath: _localCoverPath,
              onTapPreview: _previewVideo,
              onRemove: () => setState(() {
                _localVideoPath = null;
                _localCoverPath = null;
              }),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _busy ? null : _pickVideo,
                  icon: Icon(Icons.videocam_outlined, size: 18.sp),
                  label: const Text('重选视频'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _pickCover,
                  icon: Icon(Icons.image_outlined, size: 18.sp),
                  label: Text(
                    (_localCoverPath == null || _localCoverPath!.isEmpty)
                        ? '设置封面'
                        : '更换封面',
                  ),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _previewVideo,
                  icon: Icon(Icons.play_circle_outline, size: 18.sp),
                  label: const Text('预览'),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: _busy ? null : _pickVideo,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 180.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 36.sp, color: const Color(0xFF0070F3)),
                    SizedBox(height: 8.h),
                    Text(
                      '从相册选择或拍摄视频',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0070F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            '本地视频与封面仅供预览确认，不会上传；发布后使用服务端默认片源与封面',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _titleCtrl,
            maxLength: 50,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '写个标题吧',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          SizedBox(height: 12.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _topic == null ? '关联话题（可选）' : _topic!.displayName,
              style: TextStyle(
                fontSize: 15.sp,
                color: _topic == null
                    ? Colors.grey.shade600
                    : const Color(0xFF1677FF),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTopic,
          ),
          if (_topic != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _topic = null),
                child: const Text('清除话题'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 本地视频封面预览：有封面图则显示图，否则取视频首帧；点击可全屏预览。
class _LocalVideoPreview extends StatefulWidget {
  const _LocalVideoPreview({
    required this.videoPath,
    required this.coverPath,
    required this.onTapPreview,
    required this.onRemove,
  });

  final String videoPath;
  final String? coverPath;
  final VoidCallback onTapPreview;
  final VoidCallback onRemove;

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  VideoPlayerController? _controller;
  bool _loading = false;

  bool get _hasCover =>
      widget.coverPath != null && widget.coverPath!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (!_hasCover) _loadFrame();
  }

  @override
  void didUpdateWidget(covariant _LocalVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath ||
        oldWidget.coverPath != widget.coverPath) {
      if (_hasCover) {
        _disposeController();
      } else if (oldWidget.videoPath != widget.videoPath ||
          _controller == null) {
        _loadFrame();
      }
    }
  }

  Future<void> _loadFrame() async {
    _disposeController();
    setState(() => _loading = true);
    try {
      final c = await AppVideoPlayer.createFileController(
        widget.videoPath,
        autoPlay: false,
      );
      if (!mounted || _hasCover) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapPreview,
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildCover(),
            ),
            Center(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(Icons.close, size: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _hasCover ? '自定义封面' : '视频首帧',
                  style: TextStyle(fontSize: 11.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (_hasCover) {
      return Image.file(
        File(widget.coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      return ColoredBox(
        color: Colors.black,
        child: AppVideoPlayer.surface(c, fit: BoxFit.cover),
      );
    }
    if (_loading) {
      return ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.videocam, size: 40.sp, color: Colors.grey),
      ),
    );
  }
}
