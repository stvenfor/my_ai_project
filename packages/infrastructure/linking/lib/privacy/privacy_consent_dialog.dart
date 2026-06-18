import 'package:flutter/material.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';

/// 首次启动隐私协议弹窗。
class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({
    super.key,
    required this.onGranted,
  });

  final VoidCallback onGranted;

  static Future<bool> showIfNeeded(BuildContext context) async {
    final service = PrivacyConsentService();
    if (service.isGranted) return true;

    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PrivacyConsentDialog(
        onGranted: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (granted == true) {
      await service.grant();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('隐私政策与用户协议'),
      content: const SingleChildScrollView(
        child: Text(
          '为保障推送、链接跳转等基础服务，我们需要在您同意后初始化相关 SDK（含极光推送）。'
          '您可在「设置」中查看完整隐私政策。拒绝将无法继续使用本应用。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('不同意'),
        ),
        FilledButton(
          onPressed: onGranted,
          child: const Text('同意并继续'),
        ),
      ],
    );
  }
}
