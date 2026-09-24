import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/services/voice_pipeline_self_check.dart';
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
          _MoreAction(
            icon: Icons.hearing,
            label: '语音自检',
            onTap: () => _runVoiceSelfCheck(context),
          ),
        ],
      ),
    );
  }

  Future<void> _runVoiceSelfCheck(BuildContext context) async {
    UiKitInitializer.toast('语音自检中…请稍候');
    final check = VoicePipelineSelfCheck(recordMs: 1500);
    try {
      final report = await check.run(playBack: true);
      // ignore: avoid_print
      print('[DEBUG-voice] UI report $report');
      if (!context.mounted) return;
      if (report.passed) {
        UiKitInitializer.toast(report.message);
      } else {
        UiKitInitializer.toastError(
          '${report.message} [${report.symptomCode}]'
          '${report.bytes != null ? ' bytes=${report.bytes}' : ''}',
        );
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[DEBUG-voice] UI check threw $e\n$st');
      UiKitInitializer.toastError('语音自检异常: $e');
    } finally {
      await check.dispose();
    }
  }

  Future<void> _pickImage(
    ChatDetailViewModel controller,
    MediaPickSource source,
  ) async {
    try {
      if (source == MediaPickSource.camera) {
        final ok = await CameraPermissionGate.ensure(
          deniedToast: '需要相机权限才能拍摄，请在系统弹窗中允许',
          settingsMessage: '相机权限已被关闭。请在系统设置中开启后，再回来拍摄。',
        );
        if (!ok) return;
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
