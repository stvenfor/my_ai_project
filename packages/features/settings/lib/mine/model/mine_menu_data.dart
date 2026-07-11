import 'package:flutter/cupertino.dart';

class MineQuickServiceItem {
  const MineQuickServiceItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.badge,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String? badge;
}

abstract final class MineQuickServiceData {
  static const items = [
    MineQuickServiceItem(
      id: 'mall',
      label: '商城',
      icon: CupertinoIcons.bag,
      iconColor: Color(0xFF007AFF),
      badge: 'HOT',
    ),
    MineQuickServiceItem(
      id: 'wallet',
      label: '我的钱包',
      icon: CupertinoIcons.creditcard,
      iconColor: Color(0xFF5856D6),
    ),
    MineQuickServiceItem(
      id: 'course',
      label: '我的课程',
      icon: CupertinoIcons.play_rectangle,
      iconColor: Color(0xFFFF9500),
    ),
    MineQuickServiceItem(
      id: 'order',
      label: '我的订单',
      icon: CupertinoIcons.doc_text,
      iconColor: Color(0xFF34C759),
    ),
  ];
}

class MineMenuItem {
  const MineMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.showBadge = false,
    this.destructive = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final bool showBadge;
  final bool destructive;
}

abstract final class MineMenuData {
  static const items = [
    MineMenuItem(
      id: 'cooperation',
      label: '商务合作',
      icon: CupertinoIcons.person_add,
    ),
    MineMenuItem(
      id: 'reminder',
      label: '提醒事项',
      icon: CupertinoIcons.bell,
    ),
    MineMenuItem(
      id: 'invite',
      label: '邀请好友',
      icon: CupertinoIcons.person_2,
    ),
    MineMenuItem(
      id: 'fan_group',
      label: '粉丝群',
      icon: CupertinoIcons.chat_bubble_2,
      showBadge: true,
    ),
    MineMenuItem(
      id: 'feedback',
      label: '意见反馈',
      icon: CupertinoIcons.tag,
    ),
    MineMenuItem(
      id: 'settings',
      label: '设置',
      icon: CupertinoIcons.gear,
    ),
  ];
}
