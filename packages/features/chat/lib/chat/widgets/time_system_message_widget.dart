import 'package:flutter/material.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';

class TimeMessageWidget extends StatelessWidget {
  const TimeMessageWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          label,
          style: ChatTheme.caption.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}

class SystemMessageWidget extends StatelessWidget {
  const SystemMessageWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: ChatTheme.caption,
        ),
      ),
    );
  }
}
