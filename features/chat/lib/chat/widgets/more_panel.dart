import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class MorePanel extends StatelessWidget {
  const MorePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailViewModel>();

    return Container(
      height: 220,
      color: ChatTheme.background,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MoreAction(
            icon: Icons.photo_library_outlined,
            label: '相册',
            onTap: () => _pickImage(controller, MediaPickSource.gallery),
          ),
          _MoreAction(
            icon: Icons.camera_alt_outlined,
            label: '拍摄',
            onTap: () => _pickImage(controller, MediaPickSource.camera),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    ChatDetailViewModel controller,
    MediaPickSource source,
  ) async {
    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }

      final path = await ImagePickerUtils.pickImage(source);
      if (path == null) return;
      controller.inputPanelMode.value = InputPanelMode.text;
      await controller.sendImageMessage(path);
    } catch (error) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }
}

class _MoreAction extends StatelessWidget {
  const _MoreAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
