import 'package:flutter/material.dart';

/// 主 Tab 描述，供主工程 [MainPage] 动态装配。
class ModuleTabItem {
  const ModuleTabItem({
    required this.moduleId,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pageBuilder,
    this.order = 0,
  });

  final String moduleId;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() pageBuilder;
  final int order;
}
