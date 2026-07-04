import 'package:flutter/material.dart';

class MusicControlButton extends StatelessWidget {
  const MusicControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 50,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: iconSize,
      icon: Icon(icon),
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
