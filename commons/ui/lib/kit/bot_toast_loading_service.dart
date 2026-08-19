import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:module_common_ui/kit/ui_kit_config.dart';
import 'package:module_core/core.dart';

/// [AppLoading] 的 BotToast 实现（唯一依赖 bot_toast 的文件）。
class BotToastAppLoading extends AppLoading {
  BotToastAppLoading(this._config);

  final UiKitConfig _config;
  CancelFunc? _loadingCancel;

  @override
  void show([String? message]) {
    dismiss();
    _loadingCancel = BotToast.showCustomLoading(
      toastBuilder: (_) => _LoadingToast(message: message, config: _config),
      crossPage: true,
      clickClose: false,
      allowClick: _config.userInteractions,
      backButtonBehavior: BackButtonBehavior.ignore,
    );
  }

  @override
  void dismiss() {
    _loadingCancel?.call();
    _loadingCancel = null;
    BotToast.closeAllLoading();
  }

  @override
  void showSuccess(String message) {
    _showStatusToast(
      message: message,
      icon: Icons.check_circle_outline,
      accent: const Color(0xFF4CAF50),
    );
  }

  @override
  void showError(String message) {
    _showStatusToast(
      message: message,
      icon: Icons.error_outline,
      accent: const Color(0xFFE53935),
    );
  }

  @override
  void showInfo(String message) {
    _showStatusToast(
      message: message,
      icon: Icons.info_outline,
      accent: const Color(0xFF2196F3),
    );
  }

  @override
  void showToast(String message) {
    BotToast.showText(
      text: message,
      duration: _config.displayDuration,
      contentColor: _config.toastBackgroundColor,
      textStyle: TextStyle(
        color: _config.textColor,
        fontSize: 15,
      ),
      align: Alignment.center,
    );
  }

  @override
  Future<T> run<T>(
    Future<T> Function() task, {
    String? message,
  }) async {
    show(message);
    try {
      return await task();
    } finally {
      dismiss();
    }
  }

  void _showStatusToast({
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    BotToast.showCustomText(
      duration: _config.displayDuration,
      align: Alignment.center,
      toastBuilder: (_) => _StatusToast(
        message: message,
        icon: icon,
        accent: accent,
        config: _config,
      ),
    );
  }
}

void applyBotToastConfig([UiKitConfig config = const UiKitConfig()]) {
  BotToast.defaultOption.text
    ..align = Alignment.center
    ..contentColor = config.toastBackgroundColor
    ..textStyle = TextStyle(color: config.textColor, fontSize: 15);
}

class _LoadingToast extends StatelessWidget {
  const _LoadingToast({
    required this.config,
    this.message,
  });

  final UiKitConfig config;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message?.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: config.loadingBackgroundColor,
        borderRadius: BorderRadius.circular(config.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: config.indicatorSize,
            height: config.indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: config.indicatorColor,
            ),
          ),
          if (text != null && text.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              text,
              style: TextStyle(
                color: config.textColor,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusToast extends StatelessWidget {
  const _StatusToast({
    required this.message,
    required this.icon,
    required this.accent,
    required this.config,
  });

  final String message;
  final IconData icon;
  final Color accent;
  final UiKitConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: config.loadingBackgroundColor,
        borderRadius: BorderRadius.circular(config.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: config.textColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
