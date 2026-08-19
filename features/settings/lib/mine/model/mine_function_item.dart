import 'package:flutter/material.dart';

class MineFunctionItem {
  const MineFunctionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.iconColor,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color iconColor;
  final IconData icon;
}
