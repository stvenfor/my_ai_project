import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/models/topic_model.dart';
import 'package:module_community/community/view/community_convention_dialog.dart';
import 'package:module_community/community/view/topic_select_page.dart';
import 'package:module_community/community/viewmodel/publish_viewmodel.dart';

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
                  backgroundColor: Colors.blue,
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
          Obx(() {
            final mt = _vm.mediaType.value;
            final path = _vm.localPreviewPath.value;
            if (mt == 'none' || path == null || path.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      if (mt == 'image')
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _videoPlaceholder(),
                          ),
                        )
                      else
                        _videoPlaceholder(),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _vm.clearMedia,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '发布后将使用默认示例媒体（不上传所选文件）',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final topic = _vm.selectedTopic.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tag),
              title: Text(topic == null ? '关联话题' : topic.displayName),
              subtitle: topic?.isAskEveryone == true
                  ? const Text('问大家')
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickTopic,
            );
          }),
        ],
      ),
    );
  }

  Widget _videoPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 36, color: Colors.grey),
          SizedBox(height: 4),
          Text('已选视频', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
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
