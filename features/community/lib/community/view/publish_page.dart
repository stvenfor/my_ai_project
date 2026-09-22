import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/view/community_convention_dialog.dart';
import 'package:module_community/community/view/topic_select_page.dart';
import 'package:module_community/community/viewmodel/publish_viewmodel.dart';
import 'package:module_utils/module_utils.dart';
import 'package:video_player/video_player.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  late final PublishViewModel _vm;
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = Get.put(PublishViewModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) CommunityConventionDialog.maybeShow(context);
    });
    _textCtrl.addListener(() => _vm.content.value = _textCtrl.text);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    if (Get.isRegistered<PublishViewModel>()) {
      Get.delete<PublishViewModel>();
    }
    super.dispose();
  }

  Future<void> _pickTopic() async {
    final selected = await Get.to<TopicModel>(
      () => TopicSelectPage(selectedId: _vm.selectedTopic.value?.id),
    );
    if (selected != null) {
      _vm.setTopic(selected);
    }
  }

  Future<void> _onPublish() async {
    final ok = await _vm.publish();
    if (ok && mounted) Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: AppNavBar(
        title: '',
        showBackButton: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back<void>(),
        ),
        actions: [
          Obx(() {
            final busy = _vm.publishing.value;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: busy ? null : _onPublish,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1677FF),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('发布'),
              ),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _textCtrl,
            maxLines: 8,
            minLines: 5,
            decoration: const InputDecoration(
              hintText: '记录一下吧',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final mt = _vm.mediaType.value;
            return Wrap(
              spacing: 8,
              children: [
                _MediaChip(
                  label: '无媒体',
                  selected: mt == 'none',
                  onTap: _vm.clearMedia,
                ),
                _MediaChip(
                  label: '图片',
                  selected: mt == 'image',
                  onTap: _vm.pickImageMedia,
                ),
                _MediaChip(
                  label: '视频',
                  selected: mt == 'video',
                  onTap: _vm.pickVideoMedia,
                ),
              ],
            );
          }),
          Obx(() => _buildMediaPreview()),
          const SizedBox(height: 8),
          Text(
            '发布后将使用默认示例媒体（不上传所选文件）',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final topic = _vm.selectedTopic.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tag),
              title: Text(topic == null ? '关联话题' : topic.displayName),
              subtitle:
                  topic?.isAskEveryone == true ? const Text('问大家') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickTopic,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    final mt = _vm.mediaType.value;
    if (mt == 'image' && _vm.imagePaths.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: _PublishImageGrid(),
      );
    }
    if (mt == 'video' && (_vm.videoPath.value?.isNotEmpty ?? false)) {
      final cover = _vm.videoCoverPath.value;
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LocalVideoCover(
              videoPath: _vm.videoPath.value!,
              coverPath: cover,
              onTap: _vm.previewVideo,
              onRemove: _vm.clearMedia,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _vm.pickVideoCover,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(
                cover == null || cover.isEmpty ? '设置封面' : '更换封面',
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// 发布页图片九宫格：满宽 3 列，格子随屏宽放大。
class _PublishImageGrid extends StatelessWidget {
  const _PublishImageGrid();

  static const _gap = 8.0;
  static const _cols = 3;

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<PublishViewModel>();
    final paths = vm.imagePaths;
    final showAdd = paths.length < PublishViewModel.maxImages;
    final count = paths.length + (showAdd ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth - _gap * (_cols - 1)) / _cols;
        final rows = (count / _cols).ceil();
        final height = rows * cell + (rows - 1) * _gap;

        return SizedBox(
          height: height,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _cols,
              crossAxisSpacing: _gap,
              mainAxisSpacing: _gap,
              childAspectRatio: 1,
            ),
            itemCount: count,
            itemBuilder: (context, index) {
              if (showAdd && index == paths.length) {
                return _AddTile(onTap: vm.pickImageMedia);
              }
              return _ImageThumb(
                path: paths[index],
                onTap: () => vm.previewImages(index),
                onRemove: () => vm.removeImageAt(index),
              );
            },
          ),
        );
      },
    );
  }
}

/// 本地视频封面：优先自定义封面，否则用首帧画面。
class _LocalVideoCover extends StatefulWidget {
  const _LocalVideoCover({
    required this.videoPath,
    required this.coverPath,
    required this.onTap,
    required this.onRemove,
  });

  final String videoPath;
  final String? coverPath;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_LocalVideoCover> createState() => _LocalVideoCoverState();
}

class _LocalVideoCoverState extends State<_LocalVideoCover> {
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
  void didUpdateWidget(covariant _LocalVideoCover oldWidget) {
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
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCover(),
            ),
            const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _RemoveBtn(onTap: widget.onRemove),
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
      child: const Center(
        child: Icon(Icons.videocam, size: 36, color: Colors.grey),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.path,
    required this.onTap,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
        Positioned(top: 2, right: 2, child: _RemoveBtn(onTap: onRemove)),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}

class _RemoveBtn extends StatelessWidget {
  const _RemoveBtn({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _MediaChip extends StatelessWidget {
  const _MediaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
