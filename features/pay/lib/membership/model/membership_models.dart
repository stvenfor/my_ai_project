import 'package:flutter/material.dart';

enum MembershipTier { svip, aiSvip }

enum PaymentMethodType { wechat, alipay }

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.tier,
    required this.title,
    required this.price,
    required this.originalPrice,
    this.badge,
    this.dailyHint,
    this.showRedPacket = false,
  });

  final String id;
  final MembershipTier tier;
  final String title;
  final double price;
  final double originalPrice;
  final String? badge;
  final String? dailyHint;
  final bool showRedPacket;
}

class MembershipPromoBanner {
  const MembershipPromoBanner({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.countdownLabel,
  });

  final MembershipTier tier;
  final String title;
  final String subtitle;
  final String countdownLabel;
}

class MembershipFeatureItem {
  const MembershipFeatureItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class MembershipUserProfile {
  const MembershipUserProfile({
    required this.displayName,
    required this.levelBadge,
    required this.statusText,
    required this.avatarUrl,
  });

  final String displayName;
  final String levelBadge;
  final String statusText;
  final String avatarUrl;
}
